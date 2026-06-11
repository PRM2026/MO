import 'package:flutter/material.dart';

import '../constants/referee_colors.dart';

enum SystemRoleType {
  spectator,
  horseOwner,
  jockey,
  referee,
}

enum RoleHistoryStatus {
  rejected,
  approved,
  pending,
}

extension SystemRoleTypeX on SystemRoleType {
  String get label {
    return switch (this) {
      SystemRoleType.spectator => 'Khán giả',
      SystemRoleType.horseOwner => 'Chủ ngựa',
      SystemRoleType.jockey => 'Nài ngựa',
      SystemRoleType.referee => 'Trọng tài',
    };
  }

  IconData get icon {
    return switch (this) {
      SystemRoleType.spectator => Icons.visibility_outlined,
      SystemRoleType.horseOwner => Icons.house_siding_outlined,
      SystemRoleType.jockey => Icons.sports_motorsports_outlined,
      SystemRoleType.referee => Icons.gavel_outlined,
    };
  }

  String get description {
    return switch (this) {
      SystemRoleType.spectator =>
        'Tham gia cộng đồng, đặt cược và theo dõi tin tức.',
      SystemRoleType.horseOwner =>
        'Quản lý chuồng ngựa, đăng ký thi đấu và phát triển chiến mã.',
      SystemRoleType.jockey =>
        'Trực tiếp điều khiển ngựa trên đường đua danh giá.',
      SystemRoleType.referee =>
        'Giám sát tính công bằng và tuân thủ luật lệ giải đấu.',
    };
  }
}

class RoleApplicationHistoryItem {
  const RoleApplicationHistoryItem({
    required this.role,
    required this.submittedDate,
    required this.status,
    required this.adminNote,
  });

  final SystemRoleType role;
  final String submittedDate;
  final RoleHistoryStatus status;
  final String adminNote;

  String get statusLabel {
    return switch (status) {
      RoleHistoryStatus.rejected => 'Từ chối',
      RoleHistoryStatus.approved => 'Phê duyệt',
      RoleHistoryStatus.pending => 'Đang duyệt',
    };
  }

  Color get statusColor {
    return switch (status) {
      RoleHistoryStatus.rejected => RefereeColors.statusRed,
      RoleHistoryStatus.approved => RefereeColors.successEmerald,
      RoleHistoryStatus.pending => RefereeColors.tertiary,
    };
  }
}

class RoleRequestOverview {
  const RoleRequestOverview({
    required this.history,
    this.displayName,
    this.profileImageUrl,
  });

  final List<RoleApplicationHistoryItem> history;
  final String? profileImageUrl;
  final String? displayName;

  static RoleRequestOverview empty({
    String? displayName,
    String? profileImageUrl,
  }) {
    return RoleRequestOverview(
      displayName: displayName ?? 'USER',
      profileImageUrl: profileImageUrl,
      history: const [],
    );
  }

  static RoleRequestOverview sample({
    String? displayName,
    String? profileImageUrl,
  }) {
    return RoleRequestOverview(
      displayName: displayName ?? 'USER',
      profileImageUrl: profileImageUrl ??
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCzPdUxj7Tjm0x_2HS9oJ2FFbaZbqBgS2mTNBXzqOLoD19DPLegynaK3Fnb7ILsILTglzpKOX6oyEHS32TLDSDSfQsN-embyN9fVTrJIx49hUXQeY6ZF034V9zMhyGpFif6KhEvnHlPtpInLZ67AwGNAyT2HgeEDkrjyRIGaRz62G4OqrbkfmaCMS0_5tIajkMayPOxn5btaltowZe3PQOy_d0fHw0GRw3IJTDW7VZfGIT5h1YFX8nkOwOQxRgV06toTB35Pj9xL_6B',
      history: const [
        RoleApplicationHistoryItem(
          role: SystemRoleType.horseOwner,
          submittedDate: '12/05/2024',
          status: RoleHistoryStatus.rejected,
          adminNote: 'Thiếu tài liệu xác minh chuồng ngựa.',
        ),
        RoleApplicationHistoryItem(
          role: SystemRoleType.spectator,
          submittedDate: '20/02/2024',
          status: RoleHistoryStatus.approved,
          adminNote: 'Hoàn tất nâng cấp quyền khán giả VIP.',
        ),
      ],
    );
  }
}
