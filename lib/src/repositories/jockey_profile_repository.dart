import 'package:flutter/material.dart';

import '../constants/referee_colors.dart';
import '../models/referee_profile_data.dart';
import '../models/stored_auth_profile.dart';
import 'auth_repository.dart';

class JockeyProfileRepository {
  JockeyProfileRepository({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  Future<RefereeProfileData> fetchProfile() async {
    final StoredAuthProfile auth = await _authRepository.loadProfile();
    final fullName = auth.fullName?.trim().isNotEmpty == true
        ? auth.fullName!.trim()
        : 'Minh Tuấn';

    return sample(fullName: fullName);
  }

  static RefereeProfileData sample({
    required String fullName,
    String? avatarUrl,
  }) {
    return RefereeProfileData(
      fullName: fullName,
      refereeId: 'JCK-2024-001',
      rankLabel: 'Jockey chuyên nghiệp',
      avatarUrl: avatarUrl ??
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDkLB5jkaxAnb-1BaACS74YAhxqjUIhk9JvA2sQevctS0Yad-wsNYMBrCu-huTsx4ib7XX7A22sirN6O1hgAtKMKcLQtBIyFwUwx81uO45g_G1-4z3gorcF2ciZQPZusU1Rp9bS5cp5FSmWs0Xj5YJdbdkawYe-9sFrL5IefyavnUbsKvR4zXf-sUMFTXERx7r7FqKJ9TiNszdLZLWNwHO-wqBS7ucJg5AfAc37mBdNcQY7qjrg0XWbz0CGPCSKO4A1OfXz85TiO8c',
      stats: const [
        RefereeProfileStat(
          label: 'Cuộc đua đã chạy',
          value: '148',
          icon: Icons.sports_score,
          iconColor: RefereeColors.tertiary,
          iconBackgroundColor: Color(0x1AF6BE39),
          hoverBorderColor: RefereeColors.tertiary,
        ),
        RefereeProfileStat(
          label: 'Số lần thắng',
          value: '32',
          icon: Icons.emoji_events_outlined,
          iconColor: RefereeColors.successEmerald,
          iconBackgroundColor: Color(0x1A10B981),
          hoverBorderColor: RefereeColors.successEmerald,
        ),
      ],
      settings: const [
        RefereeProfileSettingItem(
          title: 'Bảo mật & Mật khẩu',
          icon: Icons.security_outlined,
          iconColor: RefereeColors.secondary,
        ),
      ],
    );
  }
}
