import 'package:flutter/material.dart';
import 'package:know_your_system/models/system_info.dart';
import 'package:know_your_system/widgets/info_card.dart';

class BatteryCard extends StatelessWidget {
  final BatteryInfo battery;

  const BatteryCard({super.key, required this.battery});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: 'Battery',
      icon: Icons.battery_full,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${battery.estimatedChargeRemaining}%',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (battery.estimatedRunTime > 0 &&
                  battery.estimatedRunTime < 1000000)
                Text(
                  '${(battery.estimatedRunTime / 60).toStringAsFixed(1)} hr remaining',
                ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: battery.estimatedChargeRemaining / 100,
            color: battery.estimatedChargeRemaining < 20
                ? Colors.red
                : Colors.green,
            backgroundColor: Colors.grey[300],
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 16),
          // Health calc?
          if (battery.designCapacity > 0 && battery.fullChargeCapacity > 0) ...[
            Text('Health', style: Theme.of(context).textTheme.titleSmall),
            LinearProgressIndicator(
              value: battery.fullChargeCapacity / battery.designCapacity > 1
                  ? 1
                  : battery.fullChargeCapacity / battery.designCapacity,
              color: Colors.blue,
              backgroundColor: Colors.grey[300],
            ),
            Text(
              '${((battery.fullChargeCapacity / battery.designCapacity) * 100).toStringAsFixed(1)}% of Original Capacity',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
