import 'package:flutter/material.dart';
import 'package:know_your_system/services/powershell_service.dart';

class AdvancedSection extends StatefulWidget {
  const AdvancedSection({super.key});

  @override
  State<AdvancedSection> createState() => _AdvancedSectionState();
}

class _AdvancedSectionState extends State<AdvancedSection> {
  List<Map<String, dynamic>> _startupApps = [];
  bool _loadingApps = false;

  Future<void> _loadStartupApps() async {
    if (_startupApps.isNotEmpty) return;

    setState(() => _loadingApps = true);
    try {
      final apps = await PowerShellService.runJsonCommand(
        'Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, User',
      );
      setState(() => _startupApps = apps);
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loadingApps = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: const Text(
          'Advanced Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: const Icon(Icons.build),
        onExpansionChanged: (expanded) {
          if (expanded) _loadStartupApps();
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Startup Applications',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (_loadingApps)
                  const CircularProgressIndicator()
                else if (_startupApps.isEmpty)
                  const Text('No startup apps found or access denied.')
                else
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: _startupApps.length,
                      itemBuilder: (context, index) {
                        final app = _startupApps[index];
                        return ListTile(
                          leading: const Icon(Icons.run_circle_outlined),
                          title: Text(app['Name']?.toString() ?? 'Unknown'),
                          subtitle: Text(app['Command']?.toString() ?? ''),
                          dense: true,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
