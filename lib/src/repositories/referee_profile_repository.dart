import '../models/referee_profile_data.dart';
import '../constants/referee_colors.dart';
import 'package:flutter/material.dart';
import 'auth_repository.dart';

class RefereeProfileRepository {
  RefereeProfileRepository({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  Future<RefereeProfileData> fetchProfile() async {
    final user = await _authRepository.refreshCurrentUser();
    final fullName = user.fullName?.trim().isNotEmpty == true
        ? user.fullName!.trim()
        : (user.username?.trim().isNotEmpty == true
              ? user.username!.trim()
              : user.email ?? 'Trọng tài');

    return RefereeProfileData(
      fullName: fullName,
      refereeId: user.id?.toString() ?? user.username ?? 'Chưa cập nhật',
      rankLabel: 'Trọng tài',
      avatarUrl: user.avatarUrl,
      isOnline: true,
      stats: const [
        RefereeProfileStat(
          label: 'Vai trò',
          value: 'Trọng tài',
          icon: Icons.verified_user_outlined,
          iconColor: RefereeColors.tertiary,
          iconBackgroundColor: Color(0x1AF6BE39),
        ),
        RefereeProfileStat(
          label: 'Trạng thái',
          value: 'Đang hoạt động',
          icon: Icons.online_prediction_rounded,
          iconColor: RefereeColors.successEmerald,
          iconBackgroundColor: Color(0x1A10B981),
        ),
      ],
      settings: const [
        RefereeProfileSettingItem(
          title: 'Thông báo',
          icon: Icons.notifications_outlined,
          iconColor: RefereeColors.tertiary,
        ),
        RefereeProfileSettingItem(
          title: 'Bảo mật & Mật khẩu',
          icon: Icons.security_outlined,
          iconColor: RefereeColors.secondary,
        ),
      ],
    );
  }
}
