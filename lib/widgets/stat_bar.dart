import 'package:flutter/material.dart';

class StatBar extends StatelessWidget {
  final String label;
  final double percentage; // 0.0 to 100.0
  final bool showPercentage;

  const StatBar({
    super.key,
    required this.label,
    required this.percentage,
    this.showPercentage = true,
  });

  Color _getColor(double pct) {
    if (pct >= 70.0) {
      return Colors.green;
    } else if (pct >= 50.0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final clamped = percentage.clamp(0.0, 100.0);
    final progressValue = clamped / 100.0;
    final color = _getColor(clamped);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showPercentage)
                Text(
                  '${clamped.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
