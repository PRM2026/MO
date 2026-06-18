import 'role_application_validation.dart';

abstract final class JockeyProfileUpdateValidation {
  static const fieldNames = [
    'licenseNumber',
    'experienceYears',
    'heightCm',
    'weightKg',
    'bio',
    'awards',
    'specialties',
  ];

  static String? validateFields(Map<String, String> values) {
    final license = values['licenseNumber'] ?? '';
    if (license.length > 100) {
      return 'License number toi da 100 ky tu.';
    }

    final experience = values['experienceYears']?.trim() ?? '';
    if (experience.isNotEmpty) {
      final parsed = int.tryParse(experience);
      if (parsed == null || parsed < 0) {
        return 'So nam kinh nghiem phai la so nguyen lon hon hoac bang 0.';
      }
    }

    for (final field in ['heightCm', 'weightKg']) {
      final value = values[field]?.trim() ?? '';
      if (value.isNotEmpty && double.tryParse(value) == null) {
        return field == 'heightCm'
            ? 'Chieu cao khong hop le.'
            : 'Can nang khong hop le.';
      }
    }

    final bio = values['bio'] ?? '';
    if (bio.length > 1000) return 'Bio toi da 1000 ky tu.';

    final awards = values['awards'] ?? '';
    if (awards.length > 2000) return 'Giai thuong toi da 2000 ky tu.';

    final specialties = values['specialties'] ?? '';
    if (specialties.length > 1000) {
      return 'Chuyen mon toi da 1000 ky tu.';
    }

    return null;
  }

  static String? validateFile(
    String fieldName,
    int sizeBytes,
    String extension,
  ) {
    return RoleApplicationValidation.validateFile(
      fieldName,
      sizeBytes,
      extension,
    );
  }
}
