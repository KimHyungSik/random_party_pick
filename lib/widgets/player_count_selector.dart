import 'package:flutter/material.dart';

class PlayerCountSelector extends StatelessWidget {
  final int value;
  final Function(int) onChanged;
  final int minValue;
  final int maxValue;
  final String label;
  final String unit;

  const PlayerCountSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.minValue = 2,
    this.maxValue = 20,
    required this.label,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: value > minValue
                    ? () => onChanged(value - 1)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: Text(
                  '$value$unit',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              IconButton(
                onPressed: value < maxValue
                    ? () => onChanged(value + 1)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }
}