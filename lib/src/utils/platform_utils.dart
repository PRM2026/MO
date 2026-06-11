import 'package:flutter/foundation.dart';

/// Máy tính (Windows/macOS/Linux) hoặc trình duyệt — chọn file trực tiếp từ ổ local.
bool get supportsLocalComputerFilePicker {
  if (kIsWeb) return true;
  return defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;
}

String get roleUploadPickerHint {
  if (supportsLocalComputerFilePicker) {
    return 'Chọn ảnh hoặc PDF từ máy tính';
  }
  return 'Chọn ảnh hoặc PDF từ thiết bị';
}
