import 'package:flutter/material.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'dash_rounded_border_painter.dart';

class AddPageTile extends StatelessWidget {
  const AddPageTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SizedBox(
      width: 150,
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: DashedRoundedBorderPainter(
            color: cs.primary.withValues(alpha: 0.55),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: cs.primary.withValues(alpha: 0.04),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add_rounded, size: 26, color: cs.primary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.l10n.scanAddPage,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      context.l10n.scanAddPageHint,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}