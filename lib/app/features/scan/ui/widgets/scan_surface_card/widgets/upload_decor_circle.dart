import 'package:flutter/material.dart';

class UploadDecorCircle extends StatelessWidget {
  const UploadDecorCircle({
    super.key,
    required this.alignment,
    required this.size,
    this.offset = Offset.zero,
  });

  final Alignment alignment;
  final double size;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: offset,
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .secondary
                .withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}