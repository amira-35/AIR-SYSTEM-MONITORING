import 'package:flutter/material.dart';
class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 4,
          color: color,
        ),
        SizedBox(width: 8),
        Text(label),
        SizedBox(width: 8),
      ],
    );
  }
}