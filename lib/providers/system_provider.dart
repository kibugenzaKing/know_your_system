import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:know_your_system/models/system_info.dart';
import 'package:know_your_system/services/powershell_service.dart';

class SystemProvider with ChangeNotifier {
  SystemInfo _systemInfo = SystemInfo();
  bool _isLoading = true;
  String? _error;

  SystemInfo get systemInfo => _systemInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SystemProvider() {
    refreshData();
  }

  Future<void> refreshData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      SystemInfo newInfo = SystemInfo();

      final results = await Future.wait([
        _fetchBasicInfo(),
        _fetchCpuInfo(),
        _fetchMemoryInfo(),
        _fetchDiskInfo(),
        _fetchGpuInfo(),
        _fetchNetworkInfo(),
        _fetchDisplayInfo(),
        _fetchBatteryInfo(),
      ]);

      final basic = results[0] as SystemInfo;
      final cpu = results[1] as SystemInfo;
      final ram = results[2] as SystemInfo;
      final disks = results[3] as List<DiskInfo>;
      final gpus = results[4] as List<GpuInfo>;
      final networks = results[5] as List<NetworkInfo>;
      final displays = results[6] as List<DisplayInfo>;
      final battery = results[7] as BatteryInfo?;

      newInfo = newInfo.copyWith(
        deviceName: basic.deviceName,
        manufacturer: basic.manufacturer,
        model: basic.model,
        osVersion: basic.osVersion,
        uptime: basic.uptime,
        processorName: cpu.processorName,
        physicalCores: cpu.physicalCores,
        logicCores: cpu.logicCores,
        totalRamMB: ram.totalRamMB,
        freeRamMB: ram.freeRamMB,
        disks: disks,
        gpus: gpus,
        networks: networks,
        displays: displays,
        battery: battery,
      );

      _systemInfo = newInfo;
    } catch (e) {
      _error = "Failed to load system info: $e";
      debugPrint("SystemProvider Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<SystemInfo> _fetchBasicInfo() async {
    try {
      final computerSystemList = await PowerShellService.runJsonCommand(
        'Get-CimInstance Win32_ComputerSystem',
      );
      final osList = await PowerShellService.runJsonCommand(
        'Get-CimInstance Win32_OperatingSystem',
      );

      String deviceName = 'Unknown';
      String manufacturer = 'Unknown';
      String model = 'Unknown';
      String osVersion = 'Unknown';
      String uptime = 'Unknown';

      if (computerSystemList.isNotEmpty) {
        final cs = computerSystemList.first;
        deviceName = cs['Name']?.toString() ?? 'Unknown';
        manufacturer = cs['Manufacturer']?.toString() ?? 'Unknown';
        model = cs['Model']?.toString() ?? 'Unknown';
      }

      if (osList.isNotEmpty) {
        final os = osList.first;
        osVersion = '${os['Caption']} (Build ${os['BuildNumber']})';
      }

      try {
        final uptimeStr = await PowerShellService.runCommand(
          '(Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime | Select-Object -ExpandProperty TotalMinutes',
        );
        if (uptimeStr.isNotEmpty) {
          final double minutes = double.tryParse(uptimeStr) ?? 0;
          final duration = Duration(minutes: minutes.round());
          final days = duration.inDays;
          final hours = duration.inHours % 24;
          uptime = '$days days, $hours hours';
        }
      } catch (e) {
        // ignore
      }

      return SystemInfo(
        deviceName: deviceName,
        manufacturer: manufacturer,
        model: model,
        osVersion: osVersion,
        uptime: uptime,
      );
    } catch (e) {
      debugPrint('Error in _fetchBasicInfo: $e');
      return SystemInfo();
    }
  }

  Future<SystemInfo> _fetchCpuInfo() async {
    try {
      final cpuList = await PowerShellService.runJsonCommand(
        'Get-CimInstance Win32_Processor',
      );
      String name = 'Unknown';
      int physical = 0;
      int logical = 0;

      if (cpuList.isNotEmpty) {
        final cpu = cpuList.first;
        name = cpu['Name']?.toString() ?? 'Unknown';
        physical = int.tryParse(cpu['NumberOfCores']?.toString() ?? '0') ?? 0;
        logical =
            int.tryParse(cpu['NumberOfLogicalProcessors']?.toString() ?? '0') ??
            0;
      }

      return SystemInfo(
        processorName: name,
        physicalCores: physical,
        logicCores: logical,
      );
    } catch (e) {
      debugPrint('Error in _fetchCpuInfo: $e');
      return SystemInfo();
    }
  }

  Future<SystemInfo> _fetchMemoryInfo() async {
    try {
      final osList = await PowerShellService.runJsonCommand(
        'Get-CimInstance Win32_OperatingSystem',
      );
      int total = 0;
      int free = 0;

      if (osList.isNotEmpty) {
        final os = osList.first;
        free =
            ((double.tryParse(os['FreePhysicalMemory']?.toString() ?? '0') ??
                        0) /
                    1024)
                .round();
        total =
            ((double.tryParse(
                          os['TotalVisibleMemorySize']?.toString() ?? '0',
                        ) ??
                        0) /
                    1024)
                .round();
      }

      return SystemInfo(totalRamMB: total, freeRamMB: free);
    } catch (e) {
      debugPrint('Error in _fetchMemoryInfo: $e');
      return SystemInfo();
    }
  }

  Future<List<DiskInfo>> _fetchDiskInfo() async {
    try {
      final disks = await PowerShellService.runJsonCommand(
        'Get-PSDrive -PSProvider FileSystem',
      );
      List<DiskInfo> diskList = [];

      for (var d in disks) {
        if (d['Used'] == null || d['Free'] == null) continue;

        final used = double.tryParse(d['Used']?.toString() ?? '0') ?? 0;
        final free = double.tryParse(d['Free']?.toString() ?? '0') ?? 0;
        final total = used + free;

        diskList.add(
          DiskInfo(
            name: d['Name']?.toString() ?? '',
            model: d['Description']?.toString() ?? '',
            sizeBytes: total.round(),
            freeBytes: free.round(),
            driveType: 'Fixed',
          ),
        );
      }
      return diskList;
    } catch (e) {
      debugPrint('Error in _fetchDiskInfo: $e');
      return [];
    }
  }

  Future<List<GpuInfo>> _fetchGpuInfo() async {
    try {
      final gpus = await PowerShellService.runJsonCommand(
        'Get-CimInstance Win32_VideoController',
      );
      List<GpuInfo> list = [];

      for (var g in gpus) {
        int vram = 0;
        if (g['AdapterRAM'] != null) {
          final bytes = double.tryParse(g['AdapterRAM'].toString()) ?? 0;
          vram = (bytes / 1024 / 1024).round();
        }

        list.add(
          GpuInfo(
            name: g['Name']?.toString() ?? 'Unknown',
            driverVersion: g['DriverVersion']?.toString() ?? 'Unknown',
            vramMB: vram,
          ),
        );
      }
      return list;
    } catch (e) {
      debugPrint('Error in _fetchGpuInfo: $e');
      return [];
    }
  }

  Future<List<NetworkInfo>> _fetchNetworkInfo() async {
    try {
      final adapters = await PowerShellService.runJsonCommand(
        'Get-NetAdapter | Where-Object { \$_.Status -eq "Up" }',
      );
      List<NetworkInfo> list = [];

      for (var a in adapters) {
        String speedStr = a['LinkSpeed']?.toString() ?? '0';
        double speed = 0;
        if (speedStr.contains('Gbps')) {
          speed =
              (double.tryParse(speedStr.replaceAll(' Gbps', '')) ?? 0) * 1000;
        } else if (speedStr.contains('Mbps')) {
          speed = double.tryParse(speedStr.replaceAll(' Mbps', '')) ?? 0;
        }

        list.add(
          NetworkInfo(
            name: a['Name']?.toString() ?? 'Unknown',
            status: a['Status']?.toString() ?? 'Unknown',
            macAddress: a['MacAddress']?.toString() ?? 'Unknown',
            linkSpeedMbps: speed.round(),
            ipAddress: 'Unknown',
          ),
        );
      }
      return list;
    } catch (e) {
      debugPrint('Error in _fetchNetworkInfo: $e');
      return [];
    }
  }

  Future<List<DisplayInfo>> _fetchDisplayInfo() async {
    try {
      final gpus = await PowerShellService.runJsonCommand(
        'Get-CimInstance Win32_VideoController',
      );
      List<DisplayInfo> list = [];

      for (var g in gpus) {
        if (g['CurrentHorizontalResolution'] != null) {
          list.add(
            DisplayInfo(
              name: 'Connected Display',
              width:
                  int.tryParse(g['CurrentHorizontalResolution'].toString()) ??
                  0,
              height:
                  int.tryParse(g['CurrentVerticalResolution'].toString()) ?? 0,
              refreshRate:
                  int.tryParse(g['CurrentRefreshRate'].toString()) ?? 60,
            ),
          );
        }
      }
      return list;
    } catch (e) {
      debugPrint('Error in _fetchDisplayInfo: $e');
      return [];
    }
  }

  Future<BatteryInfo?> _fetchBatteryInfo() async {
    try {
      final battery = await PowerShellService.runJsonCommand(
        'Get-CimInstance Win32_Battery',
      );
      // On desktops this returns empty
      if (battery.isEmpty) return null;

      final b = battery.first;

      // Status codes: 1=Discharging, 2=AC, etc.
      // But Win32_Battery often has confusing status codes.
      // 2 = Unknown, 6 = Charging, 1 = Discharging?
      // Let's rely on BatteryStatus
      final status = b['BatteryStatus'].toString();

      return BatteryInfo(
        designCapacity:
            int.tryParse(b['DesignCapacity']?.toString() ?? '0') ?? 0,
        fullChargeCapacity:
            int.tryParse(b['FullChargeCapacity']?.toString() ?? '0') ?? 0,
        estimatedChargeRemaining:
            int.tryParse(b['EstimatedChargeRemaining']?.toString() ?? '0') ?? 0,
        estimatedRunTime:
            int.tryParse(b['EstimatedRunTime']?.toString() ?? '0') ?? 0,
        status:
            status, // Decoding this requires mapping, keep raw for now or map 1-2 common ones
      );
    } catch (e) {
      debugPrint('Error in _fetchBatteryInfo: $e');
      return null;
    }
  }
}
