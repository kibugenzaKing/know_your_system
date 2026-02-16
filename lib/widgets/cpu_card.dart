import 'package:flutter/material.dart';
import 'package:know_your_system/models/system_info.dart';
import 'package:know_your_system/widgets/info_card.dart';

class CpuCard extends StatelessWidget {
  final SystemInfo info;

  const CpuCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: 'Processor',
      icon: Icons.memory,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            info.processorName,
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('Cores', '${info.physicalCores}'),
              _buildStat('Threads', '${info.logicCores}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
