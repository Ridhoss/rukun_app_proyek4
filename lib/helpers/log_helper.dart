import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class LogHelper {
  static Future<void> writeLog(
    String message, {
    String source = "Unknown",
    int level = 2,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    final int configLevel = int.tryParse('2') ?? 2;

    if (level > configLevel) return;

    try {
      final now = DateTime.now();
      final timestamp = DateFormat('HH:mm:ss').format(now);
      final dateFile = DateFormat('dd-MM-yyyy').format(now);

      final label = _getLabel(level);
      final color = _getColor(level);

      final logText = "[$timestamp][$label][$source] -> $message";

      if (kDebugMode) {
        debugPrint('$color$logText\x1B[0m');
      }

      dev.log(
        message,
        name: source,
        time: now,
        level: _mapLevel(level),
        error: error,
        stackTrace: stackTrace,
      );

      _writeToFile(dateFile, logText);
    } catch (e, st) {
      dev.log(
        "Logging failed: $e",
        name: "SYSTEM",
        level: 1000,
        error: e,
        stackTrace: st,
      );
    }
  }

  static Future<void> _writeToFile(String dateFile, String logText) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final logDir = Directory("${appDir.path}/logs");

      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      final file = File("${logDir.path}/$dateFile.log");

      file.writeAsString("$logText\n", mode: FileMode.append);

      _cleanupOldLogs(logDir);
    } catch (_) {}
  }

  static void _cleanupOldLogs(Directory dir) {
    final now = DateTime.now();

    for (var file in dir.listSync()) {
      if (file is File) {
        final stat = file.statSync();
        if (stat.modified.isBefore(now.subtract(const Duration(days: 7)))) {
          file.deleteSync();
        }
      }
    }
  }

  static String _getLabel(int level) {
    switch (level) {
      case 1:
        return "ERROR";
      case 2:
        return "INFO";
      case 3:
        return "VERBOSE";
      default:
        return "LOG";
    }
  }

  static String _getColor(int level) {
    switch (level) {
      case 1:
        return '\x1B[31m'; // merah
      case 2:
        return '\x1B[32m'; // hijau
      case 3:
        return '\x1B[34m'; // biru
      default:
        return '\x1B[0m';
    }
  }

  static int _mapLevel(int level) {
    switch (level) {
      case 1:
        return 1000; // ERROR
      case 2:
        return 500; // INFO
      case 3:
        return 300; // VERBOSE
      default:
        return 0;
    }
  }
}
