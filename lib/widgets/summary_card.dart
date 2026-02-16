import 'package:flutter/material.dart';
import 'package:know_your_system/models/system_info.dart';

class SummaryCard extends StatelessWidget {
  final SystemInfo info;

  const SummaryCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.computer, size: 32, color: Colors.white),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.deviceName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${info.manufacturer} ${info.model}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.window, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Text(
                        info.osVersion,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.timer, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Uptime: ${info.uptime}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
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
