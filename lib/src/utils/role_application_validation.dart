import '../models/role_application_field.dart';

const _textMax = {
  'displayName': 100,
  'phone': 30,
  'location': 255,
  'favoriteHorseBreed': 120,
  'bio': 1000,
  'stableName': 160,
  'address': 255,
  'licenseNumber': 100,
  'specialty': 160,
  'awards': 2000,
  'specialties': 1000,
};

const _numberRules = {
  'experienceYears': (min: 0, max: 80, label: 'Số năm kinh nghiệm'),
  'heightCm': (min: 100, max: 250, label: 'Chiều cao (cm)'),
  'weightKg': (min: 30, max: 200, label: 'Cân nặng (kg)'),
};

const _imageFields = {'avatar', 'achievements'};

const documentMime = {
  'application/pdf',
  'image/jpeg',
  'image/png',
  'image/webp',
};

const imageMime = {'image/jpeg', 'image/png', 'image/webp'};

const documentMaxBytes = 10 * 1024 * 1024;
const imageMaxBytes = 5 * 1024 * 1024;

class RoleApplicationValidation {
  static String sanitizePhone(String value) {
    return value.replaceAll(RegExp(r'[^\d+\-\s()]'), '');
  }

  static bool isValidPhone(String value) {
    final text = value.trim();
    if (text.isEmpty) return true;
    final digits = text.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 8 && digits.length <= 15;
  }

  static String? validateFields(
    List<RoleApplicationField> fields,
    Map<String, String> values,
    Map<String, String> fileNames,
  ) {
    for (final field in fields) {
      final text = (values[field.name] ?? '').trim();

      if (field.required && field.type != RoleFieldType.file && text.isEmpty) {
        return '${field.label} là bắt buộc';
      }

      if (field.type == RoleFieldType.file) {
        if (field.required && !fileNames.containsKey(field.name)) {
          return 'Vui lòng chọn ${field.label.toLowerCase()}';
        }
        continue;
      }

      if (field.name == 'phone' && text.isNotEmpty && !isValidPhone(text)) {
        return 'Số điện thoại cần 8–15 chữ số';
      }

      if (field.type == RoleFieldType.number && text.isNotEmpty) {
        final rule = _numberRules[field.name];
        if (rule != null) {
          final num = double.tryParse(text);
          if (num == null) return '${rule.label} không hợp lệ';
          if (num < rule.min) {
            return '${rule.label} không được nhỏ hơn ${rule.min}';
          }
          if (num > rule.max) {
            return '${rule.label} không được lớn hơn ${rule.max}';
          }
        }
      }

      final maxLen = field.maxLength ?? _textMax[field.name];
      if (maxLen != null && text.length > maxLen) {
        return '${field.label} tối đa $maxLen ký tự';
      }
    }
    return null;
  }

  static String? validateFile(
    String fieldName,
    int sizeBytes,
    String? extension,
  ) {
    final isImage = _imageFields.contains(fieldName);
    final ext = (extension ?? '').toLowerCase();
    final allowedExts = isImage
        ? {'jpg', 'jpeg', 'png', 'webp'}
        : {'pdf', 'jpg', 'jpeg', 'png', 'webp'};

    if (!allowedExts.contains(ext)) {
      return isImage
          ? 'Chỉ chấp nhận ảnh JPG, PNG hoặc WEBP'
          : 'Chỉ chấp nhận PDF hoặc ảnh JPG, PNG, WEBP';
    }

    final maxSize = isImage ? imageMaxBytes : documentMaxBytes;
    if (sizeBytes > maxSize) {
      return 'Dung lượng tối đa ${maxSize ~/ (1024 * 1024)}MB';
    }
    return null;
  }

  static String fileHint(String fieldName) {
    final isImage = _imageFields.contains(fieldName);
    return isImage
        ? 'Ảnh JPG, PNG, WEBP — tối đa 5MB'
        : 'PDF hoặc ảnh JPG, PNG, WEBP — tối đa 10MB';
  }
}
