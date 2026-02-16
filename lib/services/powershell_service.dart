import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class PowerShellService {
  static Future<String> runCommand(String command) async {
    try {
      final result = await Process.run(
        'powershell',
        ['-NoProfile', '-Command', command],
        runInShell: true,
        stdoutEncoding: utf8,
      );

      if (result.exitCode != 0) {
        debugPrint('PowerShell Error: ${result.stderr}');
        return '';
      }
      return result.stdout.toString().trim();
    } catch (e) {
      debugPrint('PowerShell Exception: $e');
      return '';
    }
  }

  static Future<List<Map<String, dynamic>>> runJsonCommand(
    String command,
  ) async {
    // Force JSON output
    final jsonCommand = '$command | ConvertTo-Json -Depth 2 -Compress';
    final output = await runCommand(jsonCommand);

    if (output.isEmpty) return [];

    try {
      final decoded = jsonDecode(output);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      } else if (decoded is Map) {
        return [Map<String, dynamic>.from(decoded)];
      }
      return [];
    } catch (e) {
      debugPrint('JSON Decode Error: $e');
      debugPrint('Raw Output: $output');
      return [];
    }
  }
}
