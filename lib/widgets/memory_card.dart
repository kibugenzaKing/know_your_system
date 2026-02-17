import 'package:flutter/material.dart';
import 'package:know_your_system/models/system_info.dart';
import 'package:know_your_system/utils/metrics_utils.dart';
import 'package:know_your_system/widgets/info_card.dart';

class MemoryCard extends StatelessWidget {
  final SystemInfo info;

  const MemoryCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final total = info.totalRamMB * 1024 * 1024;
    final free = info.freeRamMB * 1024 * 1024;
    final used = total - free;
    final percent = total > 0 ? used / total : 0.0;

    return InfoCard(
      title: 'Memory',
      icon: Icons.sd_storage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Usage', style: TextStyle(color: Colors.grey)),
              Text('${(percent * 100).toStringAsFixed(1)}%'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            color: _getColorForUsage(percent),
            borderRadius: BorderRadius.circular(4),
          ),
          const Spacer(),
          Text(
            '${MetricsUtils.formatBytes(used)} used of ${MetricsUtils.formatBytes(total)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Color _getColorForUsage(double percent) {
    if (percent > 0.9) return Colors.red;
    if (percent > 0.75) return Colors.orange;
    return Colors.blue;
  }
}
