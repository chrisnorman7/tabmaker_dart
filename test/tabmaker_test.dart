import 'dart:io';

import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

void main() {
  group('TabMaker', () {
    final outFile = File('test.out');
    tearDown(() {
      if (outFile.existsSync()) {
        outFile.deleteSync();
      }
    });
    test('stdout', () async {
      final process = await TestProcess.start('dart', [
        'bin/tabmaker_dart.dart',
        'small.in',
      ]);
      await expectLater(process.stdout, emits('# Untitled Song'));
      await expectLater(process.stdout, emits(''));
      await expectLater(process.stdout, emits('## Unknown Artist'));
      await expectLater(process.stdout, emits(''));
      await expectLater(process.stdout, emits('Key: C'));
      await process.shouldExit(0);
    });
    test('Write to file', () async {
      expect(outFile.existsSync(), isFalse);
      final process = await TestProcess.start(
          'dart', ['bin/tabmaker_dart.dart', 'small.in', outFile.path]);
      await expectLater(process.stdout, emits('small.in -> ${outFile.path}.'));
      await process.shouldExit(0);
      expect(outFile.existsSync(), isTrue);
    });
    test('Full file', () async {
      final process = await TestProcess.start('dart', [
        'bin/tabmaker_dart.dart',
        'faithful.in',
        '-t',
        'O Come, All Ye Faithful',
        '-a',
        'Pentatonix'
      ]);
      final lines = File('faithful.test').readAsLinesSync();
      while (lines.isNotEmpty) {
        final line = lines.removeAt(0);
        await expectLater(process.stdout, emitsThrough(line));
      }
      await process.shouldExit(0);
    });
  });
}
