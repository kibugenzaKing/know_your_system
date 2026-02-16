import 'package:flutter/material.dart';
import 'package:know_your_system/models/system_info.dart';
import 'package:know_your_system/widgets/info_card.dart';

class NetworkCard extends StatelessWidget {
  final SystemInfo info;

  const NetworkCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: 'Network',
      icon: Icons.network_wifi,
      child: ListView.separated(
        itemCount: info.networks.length,
        separatorBuilder: (c, i) => const Divider(),
        itemBuilder: (context, index) {
          final net = info.networks[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                net.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Status: ${net.status}'),
                  Text('${net.linkSpeedMbps} Mbps'),
                ],
              ),
              Text(
                'MAC: ${net.macAddress}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}
