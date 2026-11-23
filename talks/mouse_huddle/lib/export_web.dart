import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:deck_engine/deck_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 'main.dart' show deckSlides;
import 'theme.dart';

// ---------------------------------------------------------------------------
// The browser version of the PNG export, for the way this deck is actually
// run:
//
//   flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 \
//     -t lib/export_web.dart
//
// Open the page and press Export. It walks the deck in order, fast-forwards
// each slide to its finished state, captures it, and hands you a single
// slides.zip holding slide_01.png … slide_NN.png. A browser cannot write
// into a folder, so one zip is the closest thing to "a directory of PNGs".
//
// lib/export.dart does the same thing on desktop and writes the files
// straight to disk.
//
// Needs the CanvasKit renderer, which Flutter web uses by default; the old
// HTML renderer cannot read pixels back out of a canvas.
// ---------------------------------------------------------------------------

const _scale = int.fromEnvironment('scale', defaultValue: 2);
const _settleMs = int.fromEnvironment('settle', defaultValue: 400);

/// The canvas every slide is laid out on, matching the deck's own.
const _canvas = Size(1920, 1080);

void main() {
  runApp(const _ExporterApp());
}

class _ExporterApp extends StatefulWidget {
  const _ExporterApp();

  @override
  State<_ExporterApp> createState() => _ExporterAppState();
}

class _ExporterAppState extends State<_ExporterApp> {
  final _boundary = GlobalKey();
  final _controller = DeckController();

  bool _running = false;
  String _status = 'ready — ${deckSlides.length} slides';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    if (_running) return;
    setState(() => _running = true);

    final zip = _Zip();
    final digits = deckSlides.length.toString().length;

    for (var i = 0; i < deckSlides.length; i++) {
      _report('capturing slide ${i + 1} of ${deckSlides.length}');
      _controller.goTo(i);
      await _frame();

      // Run the slide to its end state and stop every clock, so the shot
      // is deterministic rather than whatever frame we land on.
      _controller.timeline?.settle();
      await _frame();

      // Give images and shaders time to arrive before the shutter.
      await Future<void>.delayed(const Duration(milliseconds: _settleMs));
      await _frame();

      zip.add(
        'slide_${(i + 1).toString().padLeft(digits, '0')}.png',
        await _capture(),
      );
    }

    _report('packing…');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    _download(zip.finish(), 'slides.zip');

    setState(() {
      _running = false;
      _status = 'done — ${deckSlides.length} slides in slides.zip';
    });
  }

  Future<Uint8List> _capture() async {
    final boundary =
        _boundary.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: _scale.toDouble());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  }

  void _download(Uint8List bytes, String name) {
    final url = html.Url.createObjectUrlFromBlob(
      html.Blob(<Object>[bytes], 'application/zip'),
    );
    html.AnchorElement(href: url)
      ..setAttribute('download', name)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  /// Waits for one painted frame.
  Future<void> _frame() async {
    await SchedulerBinding.instance.endOfFrame;
    await Future<void>.delayed(Duration.zero);
  }

  void _report(String message) {
    if (mounted) setState(() => _status = message);
  }

  @override
  Widget build(BuildContext context) {
    // The deck is laid out at full size inside the boundary and merely
    // shown scaled, so every capture is 1920 × 1080 × scale whatever the
    // browser window happens to be.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF1A1D21),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: FittedBox(
                  child: RepaintBoundary(
                    key: _boundary,
                    child: SizedBox.fromSize(
                      size: _canvas,
                      child: Deck(
                        theme: talkTheme,
                        slides: deckSlides,
                        controller: _controller,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton(
                    onPressed: _running ? null : _export,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      child: Text(_running ? 'Exporting…' : 'Export PNGs'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    _status,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// A minimal zip writer: stored entries, no compression. PNGs are already
// compressed, so there is nothing to gain and no dependency to add.
// ---------------------------------------------------------------------------

class _Zip {
  final BytesBuilder _body = BytesBuilder();
  final List<_Entry> _entries = [];

  void add(String name, Uint8List data) {
    final nameBytes = Uint8List.fromList(utf8.encode(name));
    final crc = _crc32(data);
    final offset = _body.length;

    _body.add(_bytes([
      ..._u32(0x04034b50), // local file header
      ..._u16(20), // version needed
      ..._u16(0), // flags
      ..._u16(0), // method: stored
      ..._u16(0), ..._u16(0), // time, date
      ..._u32(crc),
      ..._u32(data.length), // compressed size
      ..._u32(data.length), // uncompressed size
      ..._u16(nameBytes.length),
      ..._u16(0), // extra length
    ]));
    _body.add(nameBytes);
    _body.add(data);

    _entries.add(_Entry(nameBytes, crc, data.length, offset));
  }

  Uint8List finish() {
    final directory = BytesBuilder();
    for (final e in _entries) {
      directory.add(_bytes([
        ..._u32(0x02014b50), // central directory header
        ..._u16(20), ..._u16(20), // version made by, needed
        ..._u16(0), ..._u16(0), // flags, method
        ..._u16(0), ..._u16(0), // time, date
        ..._u32(e.crc),
        ..._u32(e.size), ..._u32(e.size),
        ..._u16(e.name.length),
        ..._u16(0), ..._u16(0), // extra, comment
        ..._u16(0), ..._u16(0), // disk, internal attrs
        ..._u32(0), // external attrs
        ..._u32(e.offset),
      ]));
      directory.add(e.name);
    }

    final body = _body.toBytes();
    final central = directory.toBytes();
    final out = BytesBuilder()
      ..add(body)
      ..add(central)
      ..add(_bytes([
        ..._u32(0x06054b50), // end of central directory
        ..._u16(0), ..._u16(0), // disk numbers
        ..._u16(_entries.length), ..._u16(_entries.length),
        ..._u32(central.length),
        ..._u32(body.length),
        ..._u16(0), // comment length
      ]));
    return out.toBytes();
  }
}

class _Entry {
  _Entry(this.name, this.crc, this.size, this.offset);

  final Uint8List name;
  final int crc;
  final int size;
  final int offset;
}

Uint8List _bytes(List<int> values) => Uint8List.fromList(values);

List<int> _u16(int v) => [v & 0xff, (v >> 8) & 0xff];

List<int> _u32(int v) =>
    [v & 0xff, (v >> 8) & 0xff, (v >> 16) & 0xff, (v >> 24) & 0xff];

final List<int> _crcTable = List<int>.generate(256, (i) {
  var c = i;
  for (var k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? 0xedb88320 ^ (c >> 1) : c >> 1;
  }
  return c;
});

int _crc32(Uint8List data) {
  var crc = 0xffffffff;
  for (final byte in data) {
    crc = _crcTable[(crc ^ byte) & 0xff] ^ (crc >> 8);
  }
  return (crc ^ 0xffffffff) & 0xffffffff;
}