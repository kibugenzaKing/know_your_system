class SystemInfo {
  final String deviceName;
  final String osVersion;
  final String uptime;
  final String manufacturer;
  final String model;
  final String processorName;
  final int physicalCores;
  final int logicCores;
  final int totalRamMB;
  final int freeRamMB;
  final List<DiskInfo> disks;
  final List<GpuInfo> gpus;
  final List<NetworkInfo> networks;
  final List<DisplayInfo> displays;
  final BatteryInfo? battery;

  SystemInfo({
    this.deviceName = 'Unknown',
    this.osVersion = 'Unknown',
    this.uptime = 'Unknown',
    this.manufacturer = 'Unknown',
    this.model = 'Unknown',
    this.processorName = 'Unknown',
    this.physicalCores = 0,
    this.logicCores = 0,
    this.totalRamMB = 0,
    this.freeRamMB = 0,
    this.disks = const [],
    this.gpus = const [],
    this.networks = const [],
    this.displays = const [],
    this.battery,
  });

  SystemInfo copyWith({
    String? deviceName,
    String? osVersion,
    String? uptime,
    String? manufacturer,
    String? model,
    String? processorName,
    int? physicalCores,
    int? logicCores,
    int? totalRamMB,
    int? freeRamMB,
    List<DiskInfo>? disks,
    List<GpuInfo>? gpus,
    List<NetworkInfo>? networks,
    List<DisplayInfo>? displays,
    BatteryInfo? battery,
  }) {
    return SystemInfo(
      deviceName: deviceName ?? this.deviceName,
      osVersion: osVersion ?? this.osVersion,
      uptime: uptime ?? this.uptime,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      processorName: processorName ?? this.processorName,
      physicalCores: physicalCores ?? this.physicalCores,
      logicCores: logicCores ?? this.logicCores,
      totalRamMB: totalRamMB ?? this.totalRamMB,
      freeRamMB: freeRamMB ?? this.freeRamMB,
      disks: disks ?? this.disks,
      gpus: gpus ?? this.gpus,
      networks: networks ?? this.networks,
      displays: displays ?? this.displays,
      battery: battery ?? this.battery,
    );
  }
}

class DiskInfo {
  final String name;
  final String model;
  final int sizeBytes;
  final int freeBytes;
  final String driveType;
  final String interface;
  final String mediaType;

  DiskInfo({
    required this.name,
    required this.model,
    required this.sizeBytes,
    required this.freeBytes,
    this.driveType = 'Unknown',
    this.interface = 'Unknown',
    this.mediaType = 'Unknown',
  });
}

class GpuInfo {
  final String name;
  final String driverVersion;
  final int vramMB;

  GpuInfo({
    required this.name,
    required this.driverVersion,
    required this.vramMB,
  });
}

class NetworkInfo {
  final String name;
  final String status;
  final String ipAddress;
  final String macAddress;
  final int linkSpeedMbps;

  NetworkInfo({
    required this.name,
    required this.status,
    required this.ipAddress,
    required this.macAddress,
    required this.linkSpeedMbps,
  });
}

class DisplayInfo {
  final String name;
  final int width;
  final int height;
  final int refreshRate;

  DisplayInfo({
    required this.name,
    required this.width,
    required this.height,
    required this.refreshRate,
  });
}

class BatteryInfo {
  final int designCapacity;
  final int fullChargeCapacity;
  final int estimatedChargeRemaining; // Percentage
  final int estimatedRunTime; // Minutes
  final String status; // Charging/Discharging/Full

  BatteryInfo({
    required this.designCapacity,
    required this.fullChargeCapacity,
    required this.estimatedChargeRemaining,
    required this.estimatedRunTime,
    required this.status,
  });
}
