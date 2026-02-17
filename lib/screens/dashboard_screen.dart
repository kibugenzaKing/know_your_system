import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:know_your_system/models/system_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:know_your_system/providers/system_provider.dart';
import 'package:know_your_system/widgets/summary_card.dart';
import 'package:know_your_system/widgets/cpu_card.dart';
import 'package:know_your_system/widgets/memory_card.dart';
import 'package:know_your_system/widgets/storage_card.dart';
import 'package:know_your_system/widgets/gpu_card.dart';
import 'package:know_your_system/widgets/network_card.dart';
import 'package:know_your_system/widgets/display_card.dart';
import 'package:know_your_system/widgets/battery_card.dart';
import 'package:know_your_system/widgets/advanced_section.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> hovered = ValueNotifier(false);

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onHover: (bool value) => hovered.value = value,
          onTap: () => launchUrl(Uri.parse('https://king-kibugenza.web.app/')),
          child: ValueListenableBuilder<bool>(
            valueListenable: hovered,
            builder: (_, bool value, _) {
              return Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: value ? Colors.blueGrey : null,
                ),
                child: Text(
                  'Contact DEVELOPER',
                  style: TextStyle(
                    color: value ? Colors.white : Colors.blue,
                    fontSize: value ? 20 : 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy Specs to Clipboard',
            onPressed: () {
              final info = context.read<SystemProvider>().systemInfo;
              _copyToClipboard(context, info);
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Report',
            onPressed: () {
              final info = context.read<SystemProvider>().systemInfo;
              _exportReport(context, info);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SystemProvider>().refreshData();
            },
          ),
        ],
      ),
      body: Consumer<SystemProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading data:\n${provider.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refreshData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final info = provider.systemInfo;
          // Determine if battery card should be shown
          final hasBattery = info.battery != null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SummaryCard(info: info),
                const SizedBox(height: 16),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final crossAxisCount = width > 900
                        ? 3
                        : (width > 600 ? 2 : 1);

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.4,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        CpuCard(info: info),
                        MemoryCard(info: info),
                        StorageCard(info: info),
                        GpuCard(info: info),
                        NetworkCard(info: info),
                        DisplayCard(info: info),
                        if (hasBattery) BatteryCard(battery: info.battery!),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                const AdvancedSection(),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _copyToClipboard(BuildContext context, SystemInfo info) {
    final text = _generateReport(info);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('System specs copied to clipboard')),
    );
  }

  Future<void> _exportReport(BuildContext context, SystemInfo info) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/system_report_${DateTime.now().millisecondsSinceEpoch}.txt',
      );
      await file.writeAsString(_generateReport(info));

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Report saved to ${file.path}')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  String _generateReport(SystemInfo info) {
    StringBuffer sb = StringBuffer();
    sb.writeln('SYSTEM TRANSPARENCY REPORT');
    sb.writeln('===========================');
    sb.writeln('Device: ${info.deviceName}');
    sb.writeln('OS: ${info.osVersion}');
    sb.writeln('Model: ${info.manufacturer} ${info.model}');
    sb.writeln('Uptime: ${info.uptime}');
    sb.writeln('');
    sb.writeln('PROCESSOR');
    sb.writeln('Name: ${info.processorName}');
    sb.writeln(
      'Cores: ${info.physicalCores} Physical, ${info.logicCores} Logical',
    );
    sb.writeln('');
    sb.writeln('MEMORY');
    sb.writeln('Total: ${info.totalRamMB} MB');
    sb.writeln('Free: ${info.freeRamMB} MB');
    sb.writeln('');
    sb.writeln('STORAGE');
    for (var d in info.disks) {
      sb.writeln(
        '- ${d.name} (${d.model}): ${d.freeBytes ~/ 1024 ~/ 1024 ~/ 1024} GB Free / ${d.sizeBytes ~/ 1024 ~/ 1024 ~/ 1024} GB Total',
      );
    }
    sb.writeln('');
    sb.writeln('GRAPHICS');
    for (var g in info.gpus) {
      sb.writeln(
        '- ${g.name}, Driver: ${g.driverVersion}, VRAM: ${g.vramMB} MB',
      );
    }
    return sb.toString();
  }
}
