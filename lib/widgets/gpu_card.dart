import 'package:flutter/material.dart';
import 'package:know_your_system/models/system_info.dart';
import 'package:know_your_system/widgets/info_card.dart';

class GpuCard extends StatelessWidget {
  final SystemInfo info;

  const GpuCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: 'Graphics',
      icon: Icons.videogame_asset,
      child: ListView.builder(
        itemCount: info.gpus.length,
        itemBuilder: (context, index) {
          final gpu = info.gpus[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gpu.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Driver: ${gpu.driverVersion}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'VRAM: ${gpu.vramMB} MB',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
