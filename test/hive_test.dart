import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
  });

  test('Hive Test - Save & Read', () async {
    final box = await Hive.openBox('test_box');

    await box.put('key', 'value');

    final result = box.get('key');

    expect(result, 'value');
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });
}