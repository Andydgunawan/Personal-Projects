import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:share_plus/share_plus.dart' hide XFile;

class ResultExportService {
  ResultExportService({this.chooseSavePath});

  // Optional save-dialog substitute for tests. Production uses file_selector.
  final Future<String?> Function(String suggestedName)? chooseSavePath;
  bool get supportsImageClipboard => !kIsWeb;

  bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<Uint8List> capturePng(GlobalKey boundaryKey) async {
    try {
      RenderRepaintBoundary locateBoundary() {
        final context = boundaryKey.currentContext;
        if (context == null || !context.mounted) {
          throw StateError('The result content is not mounted.');
        }
        final renderObject = context.findRenderObject();
        if (renderObject is! RenderRepaintBoundary || !renderObject.attached) {
          throw StateError('The result RepaintBoundary is unavailable.');
        }
        if (!renderObject.hasSize || renderObject.size.isEmpty) {
          throw StateError('The result content has not been laid out.');
        }
        return renderObject;
      }

      var boundary = locateBoundary();
      if (boundary.debugNeedsPaint) {
        WidgetsBinding.instance.scheduleFrame();
        await WidgetsBinding.instance.endOfFrame;
        boundary = locateBoundary();
      }
      if (boundary.debugNeedsPaint) {
        throw StateError(
          'The result content has not finished painting. Keep the Results tab visible and try again.',
        );
      }
      final image = await boundary.toImage(pixelRatio: 2);
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        if (data == null || data.lengthInBytes == 0) {
          throw StateError('PNG encoding returned no image data.');
        }
        return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      } finally {
        image.dispose();
      }
    } catch (error, stack) {
      _fail('capture the result image', error, stack);
    }
  }

  Future<String?> save(Uint8List png, String fileName, Rect origin) async {
    try {
      if (_isMobile) {
        await share(png, fileName, origin);
        return null;
      }
      final file = XFile.fromData(png, mimeType: 'image/png', name: fileName);
      if (kIsWeb) {
        await file.saveTo(fileName);
        return 'PNG download started.';
      }
      final String? selectedPath;
      if (chooseSavePath != null) {
        selectedPath = await chooseSavePath!(fileName);
      } else {
        final location = await getSaveLocation(
          suggestedName: fileName,
          acceptedTypeGroups: const [
            XTypeGroup(
              label: 'PNG image',
              extensions: ['png'],
              uniformTypeIdentifiers: ['public.png'],
            ),
          ],
        );
        selectedPath = location?.path;
      }
      // Canceling the native dialog is a normal outcome.
      if (selectedPath == null) return null;
      final path = selectedPath.toLowerCase().endsWith('.png')
          ? selectedPath
          : '$selectedPath.png';
      // XFile.fromData writes these PNG bytes to the selected desktop path.
      await file.saveTo(path);
      if (await XFile(path).length() != png.lengthInBytes) {
        throw StateError(
          'The saved file size does not match the generated PNG.',
        );
      }
      return 'Result image saved to $path';
    } catch (error, stack) {
      _fail('save the result image', error, stack);
    }
  }

  Future<void> copy(Uint8List png) async {
    try {
      if (!supportsImageClipboard) {
        throw UnsupportedError('Use Save as Image in this browser.');
      }
      final clipboard = SystemClipboard.instance;
      if (clipboard == null) {
        throw UnsupportedError(
          'Native image clipboard is unavailable. Try Save as Image instead.',
        );
      }
      final item = DataWriterItem();
      item.add(Formats.png(png));
      await clipboard.write([item]);
    } catch (error, stack) {
      _fail('copy the result image', error, stack);
    }
  }

  Never _fail(String operation, Object error, StackTrace stack) {
    debugPrint('MooseTime export: failed to $operation: $error');
    debugPrintStack(stackTrace: stack);
    throw ResultExportException(operation, error);
  }

  Future<void> share(Uint8List png, String fileName, Rect origin) async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.linux) {
      throw UnsupportedError(
        'Image sharing is unavailable on Linux. Use Save as Image instead.',
      );
    }
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(png, mimeType: 'image/png', name: fileName)],
        fileNameOverrides: [fileName],
        title: 'MooseTime result',
        sharePositionOrigin: origin,
      ),
    );
  }
}

class ResultExportException implements Exception {
  const ResultExportException(this.operation, this.cause);
  final String operation;
  final Object cause;

  @override
  String toString() => 'Could not $operation: $cause';
}
