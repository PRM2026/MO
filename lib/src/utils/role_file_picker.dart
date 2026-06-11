import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'platform_utils.dart';

class PickedRoleFile {
  const PickedRoleFile({
    required this.file,
    required this.displayName,
    required this.extension,
    required this.sizeBytes,
  });

  final File file;
  final String displayName;
  final String extension;
  final int sizeBytes;
}

enum _DocumentPickSource { gallery, fileBrowser }

class RoleFilePicker {
  static final _imagePicker = ImagePicker();

  /// Chọn file upload. Trên Windows/macOS/Linux/Web mở hộp thoại chọn file từ ổ máy.
  static Future<PickedRoleFile?> pick({
    required BuildContext context,
    required String fieldName,
    required bool imageOnly,
  }) async {
    try {
      if (supportsLocalComputerFilePicker) {
        return _pickFromFileBrowser(
          fieldName,
          imageOnly: imageOnly,
          dialogTitle: 'Chọn file từ máy tính',
        );
      }

      if (imageOnly) {
        return _pickFromGallery(fieldName);
      }

      final source = await _pickDocumentSource(context);
      if (source == null) return null;
      if (source == _DocumentPickSource.gallery) {
        return _pickFromGallery(fieldName);
      }

      return _pickFromFileBrowser(
        fieldName,
        imageOnly: false,
        dialogTitle: 'Chọn tệp PDF hoặc ảnh',
      );
    } catch (error) {
      if (kDebugMode) debugPrint('RoleFilePicker.pick: $error');
      rethrow;
    }
  }

  static Future<_DocumentPickSource?> _pickDocumentSource(
    BuildContext context,
  ) async {
    return showModalBottomSheet<_DocumentPickSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Chọn tài liệu xác minh',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Chọn ảnh từ thư viện'),
                  subtitle: const Text('JPG, PNG, WEBP'),
                  onTap: () =>
                      Navigator.pop(context, _DocumentPickSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.folder_open_outlined),
                  title: const Text('Chọn tệp PDF hoặc ảnh'),
                  subtitle: const Text('PDF, JPG, PNG, WEBP'),
                  onTap: () =>
                      Navigator.pop(context, _DocumentPickSource.fileBrowser),
                ),
                if (kDebugMode)
                  ListTile(
                    leading: const Icon(Icons.computer_outlined),
                    title: const Text('Chọn từ ổ máy tính (Windows)'),
                    subtitle: const Text(
                      'Chạy app trên PC: flutter run -d windows',
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showDesktopDevHint(context);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _showDesktopDevHint(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn file từ máy tính'),
        content: const Text(
          'Emulator Android không truy cập trực tiếp ổ D:\\ của PC.\n\n'
          'Để chọn ảnh/PDF từ máy tính, chạy app trên Windows:\n'
          'flutter run -d windows\n\n'
          'Hoặc kéo thả ảnh vào cửa sổ emulator rồi chọn từ thư viện.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  static Future<PickedRoleFile?> _pickFromGallery(String fieldName) async {
    final xFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (xFile == null) return null;

    final file = await _materializeXFile(xFile, fieldName);
    final extension = _extensionFromName(xFile.name, fallback: 'jpg');
    final sizeBytes = await file.length();

    return PickedRoleFile(
      file: file,
      displayName: xFile.name,
      extension: extension,
      sizeBytes: sizeBytes,
    );
  }

  static Future<PickedRoleFile?> _pickFromFileBrowser(
    String fieldName, {
    required bool imageOnly,
    String? dialogTitle,
  }) async {
    final result = await FilePicker.pickFiles(
      dialogTitle: dialogTitle,
      type: imageOnly ? FileType.image : FileType.custom,
      allowedExtensions: imageOnly
          ? const ['jpg', 'jpeg', 'png', 'webp']
          : const ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      withData: false,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final picked = result.files.single;
    final file = await _materializePlatformFile(picked, fieldName);
    if (file == null) return null;

    final extension = _extensionFromName(
      picked.name,
      fallback: picked.extension,
    );
    final sizeBytes = picked.size > 0 ? picked.size : await file.length();

    return PickedRoleFile(
      file: file,
      displayName: picked.name,
      extension: extension,
      sizeBytes: sizeBytes,
    );
  }

  static Future<File> _materializeXFile(XFile xFile, String fieldName) async {
    if (!kIsWeb && xFile.path.isNotEmpty) {
      final source = File(xFile.path);
      if (await source.exists()) return source;
    }

    final bytes = await xFile.readAsBytes();
    return _writeTempFile(
      fieldName: fieldName,
      fileName: xFile.name,
      bytes: bytes,
    );
  }

  static Future<File?> _materializePlatformFile(
    PlatformFile picked,
    String fieldName,
  ) async {
    if (!kIsWeb && picked.path != null && picked.path!.isNotEmpty) {
      final source = File(picked.path!);
      if (await source.exists()) return source;
    }

    if (picked.bytes != null && picked.bytes!.isNotEmpty) {
      return _writeTempFile(
        fieldName: fieldName,
        fileName: picked.name,
        bytes: picked.bytes!,
      );
    }

    return null;
  }

  static Future<File> _writeTempFile({
    required String fieldName,
    required String fileName,
    required List<int> bytes,
  }) async {
    final dir = await getTemporaryDirectory();
    final safeName = fileName.replaceAll(RegExp(r'[^\w\.\-]'), '_');
    final outPath =
        '${dir.path}/role_${fieldName}_${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final out = File(outPath);
    await out.writeAsBytes(bytes, flush: true);
    return out;
  }

  static String _extensionFromName(String name, {String? fallback}) {
    final dot = name.lastIndexOf('.');
    if (dot >= 0 && dot < name.length - 1) {
      return name.substring(dot + 1).toLowerCase();
    }
    final fb = fallback?.toLowerCase().trim();
    if (fb != null && fb.isNotEmpty) return fb;
    return 'jpg';
  }
}
