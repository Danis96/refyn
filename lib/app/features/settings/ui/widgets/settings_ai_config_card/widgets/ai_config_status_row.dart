import 'package:flutter/material.dart';

class AiConfigStatusRow extends StatelessWidget {
  const AiConfigStatusRow({
    required Key super.key,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconTheme(data: IconThemeData(color: color), child: icon),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}