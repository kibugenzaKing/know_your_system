import 'package:flutter/material.dart';
import 'package:know_your_system/models/system_info.dart';
import 'package:know_your_system/widgets/info_card.dart';

class DisplayCard extends StatelessWidget {
  final SystemInfo info;

  const DisplayCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: 'Display',
      icon: Icons.monitor,
      child: ListView.builder(
        itemCount: info.displays.length,
        itemBuilder: (context, index) {
          final d = info.displays[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${d.width} x ${d.height}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '${d.refreshRate} Hz Refresh Rate',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          );
        },
      ),
    );
  }
}
