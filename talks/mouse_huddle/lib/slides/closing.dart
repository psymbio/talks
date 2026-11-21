import 'package:deck_engine/deck_engine.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/frame.dart';

class _Takeaway extends StatelessWidget {
  const _Takeaway(this.number, this.head, this.detail);

  final String number;
  final String head;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 34),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              number,
              style: tH1.copyWith(color: accent, height: 1.0),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(head, style: tLead.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(detail, style: tBody.copyWith(color: muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Slide takeaways() => Slide(
      duration: const Duration(seconds: 3),
      builder: (context) => const SlideFrame(
        kicker: 'Summary',
        title: 'A cortical mechanism for collective homeostasis',
        source: 'Raam et al., Nat Neurosci 29, 901–914 (2026) · '
            'doi.org/10.1038/s41593-026-02224-0',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Anim(
              at: 0.4,
              from: Offset(-40, 0),
              child: _Takeaway(
                '1',
                'Cold mice self-organise into huddles',
                'Contacts warm the body surface and keep core temperature '
                    'stable; groups of four huddle more than pairs predict.',
              ),
            ),
            Anim(
              at: 0.9,
              from: Offset(-40, 0),
              child: _Takeaway(
                '2',
                'Huddles are built from active and passive decisions',
                'Separate dmPFC ensembles encode “I act” and “my partner '
                    'acts”, apart from locomotion.',
              ),
            ),
            Anim(
              at: 1.4,
              from: Offset(-40, 0),
              child: _Takeaway(
                '3',
                'The group compensates for its members',
                'Silencing dmPFC in two mice makes them passive; their '
                    'partners become more active and huddling is preserved.',
              ),
            ),
          ],
        ),
      ),
    );
