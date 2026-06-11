import 'role_request_data.dart';

enum RoleFieldType { text, tel, number, textarea, file }

class RoleApplicationField {
  const RoleApplicationField({
    required this.name,
    required this.label,
    this.type = RoleFieldType.text,
    this.required = false,
    this.placeholder,
    this.min,
    this.max,
    this.maxLength,
  });

  final String name;
  final String label;
  final RoleFieldType type;
  final bool required;
  final String? placeholder;
  final num? min;
  final num? max;
  final int? maxLength;
}

const roleApplicationFields = <SystemRoleType, List<RoleApplicationField>>{
  SystemRoleType.spectator: [
    RoleApplicationField(
      name: 'displayName',
      label: 'Họ và tên hiển thị',
      required: true,
      placeholder: 'Nguyễn Văn A',
      maxLength: 100,
    ),
    RoleApplicationField(
      name: 'phone',
      label: 'Số điện thoại',
      type: RoleFieldType.tel,
      placeholder: '+84 901234567',
      maxLength: 30,
    ),
    RoleApplicationField(
      name: 'location',
      label: 'Địa chỉ / Khu vực',
      placeholder: 'TP. Hồ Chí Minh',
      maxLength: 255,
    ),
    RoleApplicationField(
      name: 'favoriteHorseBreed',
      label: 'Giống ngựa yêu thích',
      placeholder: 'Arabian, Thoroughbred...',
      maxLength: 120,
    ),
    RoleApplicationField(
      name: 'bio',
      label: 'Giới thiệu ngắn',
      type: RoleFieldType.textarea,
      placeholder: 'Lý do bạn muốn trở thành khán giả chính thức',
      maxLength: 1000,
    ),
  ],
  SystemRoleType.horseOwner: [
    RoleApplicationField(
      name: 'stableName',
      label: 'Tên trang trại / Chuồng ngựa',
      required: true,
      placeholder: 'Trang trại Phú Mỹ',
      maxLength: 160,
    ),
    RoleApplicationField(
      name: 'address',
      label: 'Địa chỉ trang trại',
      required: true,
      placeholder: 'Số nhà, đường, quận, tỉnh',
      maxLength: 255,
    ),
    RoleApplicationField(
      name: 'experienceYears',
      label: 'Số năm kinh nghiệm',
      type: RoleFieldType.number,
      placeholder: '3',
      min: 0,
      max: 80,
    ),
    RoleApplicationField(
      name: 'bio',
      label: 'Giới thiệu thêm',
      type: RoleFieldType.textarea,
      maxLength: 1000,
    ),
    RoleApplicationField(
      name: 'verificationDocument',
      label: 'Giấy chứng nhận / Xác minh sở hữu',
      type: RoleFieldType.file,
      required: true,
    ),
  ],
  SystemRoleType.jockey: [
    RoleApplicationField(
      name: 'licenseNumber',
      label: 'Số giấy phép Jockey',
      required: true,
      placeholder: 'JK-XXXX',
      maxLength: 100,
    ),
    RoleApplicationField(
      name: 'experienceYears',
      label: 'Số năm kinh nghiệm',
      type: RoleFieldType.number,
      placeholder: '5',
      min: 0,
      max: 80,
    ),
    RoleApplicationField(
      name: 'heightCm',
      label: 'Chiều cao (cm)',
      type: RoleFieldType.number,
      placeholder: '165',
      min: 100,
      max: 250,
    ),
    RoleApplicationField(
      name: 'weightKg',
      label: 'Cân nặng (kg)',
      type: RoleFieldType.number,
      placeholder: '55',
      min: 30,
      max: 200,
    ),
    RoleApplicationField(
      name: 'bio',
      label: 'Giới thiệu',
      type: RoleFieldType.textarea,
      maxLength: 1000,
    ),
    RoleApplicationField(
      name: 'awards',
      label: 'Thành tích / Giải thưởng',
      type: RoleFieldType.textarea,
      maxLength: 2000,
    ),
    RoleApplicationField(
      name: 'specialties',
      label: 'Chuyên môn',
      type: RoleFieldType.textarea,
      maxLength: 1000,
    ),
    RoleApplicationField(
      name: 'licenseDocument',
      label: 'Bản scan giấy phép',
      type: RoleFieldType.file,
      required: true,
    ),
    RoleApplicationField(
      name: 'avatar',
      label: 'Ảnh đại diện',
      type: RoleFieldType.file,
    ),
    RoleApplicationField(
      name: 'achievements',
      label: 'Ảnh thành tích',
      type: RoleFieldType.file,
    ),
  ],
  SystemRoleType.referee: [
    RoleApplicationField(
      name: 'licenseNumber',
      label: 'Số giấy chứng nhận trọng tài',
      required: true,
      placeholder: 'RF-XXXX',
      maxLength: 100,
    ),
    RoleApplicationField(
      name: 'experienceYears',
      label: 'Số năm kinh nghiệm',
      type: RoleFieldType.number,
      placeholder: '8',
      min: 0,
      max: 80,
    ),
    RoleApplicationField(
      name: 'specialty',
      label: 'Chuyên môn',
      required: true,
      placeholder: 'Đua ngựa tốc độ, vượt rào...',
      maxLength: 160,
    ),
    RoleApplicationField(
      name: 'bio',
      label: 'Giới thiệu',
      type: RoleFieldType.textarea,
      maxLength: 1000,
    ),
    RoleApplicationField(
      name: 'certificationDocument',
      label: 'Chứng chỉ đào tạo trọng tài',
      type: RoleFieldType.file,
      required: true,
    ),
  ],
};

extension SystemRoleTypeApi on SystemRoleType {
  List<RoleApplicationField> get applicationFields =>
      roleApplicationFields[this] ?? const [];
}
