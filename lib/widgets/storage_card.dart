import 'package:flutter/material.dart';
import 'package:know_your_system/models/system_info.dart';
import 'package:know_your_system/utils/metrics_utils.dart';
import 'package:know_your_system/widgets/info_card.dart';

class StorageCard extends StatelessWidget {
  final SystemInfo info;

  const StorageCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: 'Storage',
      icon: Icons.storage,
      child: ListView.separated(
        itemCount: info.disks.length,
        separatorBuilder: (c, i) => const Divider(height: 8),
        itemBuilder: (context, index) {
          final disk = info.disks[index];
          final used = disk.sizeBytes - disk.freeBytes;
          final percent = disk.sizeBytes > 0 ? used / disk.sizeBytes : 0.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.drive_file_rename_outline,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    disk.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(MetricsUtils.formatBytes(disk.freeBytes) + ' free'),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.grey[300],
                color: _getUsageColor(percent),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 2),
              Text(
                '${MetricsUtils.formatBytes(used)} / ${MetricsUtils.formatBytes(disk.sizeBytes)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getUsageColor(double percent) {
    if (percent > 0.9) return Colors.red;
    return Colors.blueGrey;
  }
}
