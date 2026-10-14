import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moose_time/services/result_export_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Windows save writes actual PNG bytes and cancellation writes nothing', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    final directory = await Directory.systemTemp.createTemp(
      'moosetime-export-test-',
    );
    addTearDown(() async {
      debugDefaultTargetPlatformOverride = null;
      await directory.delete(recursive: true);
    });
    // A valid one-pixel PNG, used to exercise actual file writing.
    final bytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a/qkAAAAASUVORK5CYII=',
    );
    final path =
        '${directory.path}${Platform.pathSeparator}MooseTime-Airland-Augmented.png';
    final service = ResultExportService(
      chooseSavePath: (name) async {
        expect(name, 'MooseTime-Airland-Augmented.png');
        return path;
      },
    );
    final message = await service.save(
      bytes,
      'MooseTime-Airland-Augmented.png',
      Rect.zero,
    );
    expect(await File(path).readAsBytes(), bytes);
    expect(message, contains(path));
    final cancelled = ResultExportService(chooseSavePath: (_) async => null);
    expect(await cancelled.save(bytes, 'Cancelled.png', Rect.zero), isNull);
    expect(await directory.list().length, 1);
  });

  test(
    'Save failures identify the operation and retain the actual error',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final service = ResultExportService(
        chooseSavePath: (_) async =>
            throw const FileSystemException('Save dialog failed'),
      );
      await expectLater(
        service.save(Uint8List(8), 'Result.png', Rect.zero),
        throwsA(
          isA<ResultExportException>()
              .having(
                (error) => error.operation,
                'operation',
                'save the result image',
              )
              .having(
                (error) => error.cause,
                'cause',
                isA<FileSystemException>(),
              ),
        ),
      );
    },
  );

  test('Capture failures identify a missing RepaintBoundary', () async {
    await expectLater(
      ResultExportService().capturePng(GlobalKey()),
      throwsA(
        isA<ResultExportException>().having(
          (error) => error.operation,
          'operation',
          'capture the result image',
        ),
      ),
    );
  });
}
