import 'dart:math';

class MetricsUtils {
  static String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  static String formatFrequency(int hertz) {
    if (hertz < 1000) return "$hertz MHz";
    return "${(hertz / 1000).toStringAsFixed(2)} GHz";
  }
}
