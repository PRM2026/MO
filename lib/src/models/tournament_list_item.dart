import '../utils/image_url_resolver.dart';

enum TournamentBadgeStyle { gold, navy, none }

class TournamentListItem {
  const TournamentListItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.location,
    required this.startLabel,
    required this.registrationLabel,
    required this.racesLabel,
    this.badgeLabel,
    this.badgeStyle = TournamentBadgeStyle.none,
    this.isLive = false,
    this.status = '',
    this.startAt,
    this.maxTeams,
  });

  final String id;
  final String title;
  final String imageUrl;
  final String location;
  final String startLabel;
  final String registrationLabel;
  final String racesLabel;
  final String? badgeLabel;
  final TournamentBadgeStyle badgeStyle;
  final bool isLive;
  final String status;
  final DateTime? startAt;
  final int? maxTeams;

  String get homeDateLabel => _formatHomeDate(startAt);

  String get homeStatusBadge {
    switch (status) {
      case 'OPEN_REGISTRATION':
        return 'MỞ ĐĂNG KÝ';
      case 'REGISTRATION_CLOSED':
        return 'ĐÓNG ĐĂNG KÝ';
      case 'ONGOING':
        return 'ĐANG DIỄN RA';
      case 'COMPLETED':
        return 'ĐÃ KẾT THÚC';
      case 'CANCELLED':
        return 'ĐÃ HỦY';
      case 'PUBLISHED':
        return 'ĐÃ CÔNG BỐ';
      default:
        return 'SẮP DIỄN RA';
    }
  }

  factory TournamentListItem.fromJson(Map<String, dynamic> json) {
    final status = (json['status'] as String?) ?? '';
    final startAt = json['startAt'] as String?;
    final endAt = json['endAt'] as String?;
    final regOpen = json['registrationOpenAt'] as String?;
    final isLive = status == 'ONGOING';

    return TournamentListItem(
      id: '${json['id']}',
      title: (json['name'] as String?)?.trim() ?? '',
      imageUrl: ImageUrlResolver.resolve(json['bannerUrl'] as String?),
      location: (json['location'] as String?)?.trim() ?? '—',
      startLabel: isLive
          ? 'Kết thúc: ${_formatDate(endAt)}'
          : 'Bắt đầu: ${_formatDate(startAt)}',
      registrationLabel: _registrationLabel(status, regOpen),
      racesLabel: '— cuộc đua',
      badgeLabel: _badgeLabel(status),
      badgeStyle: _badgeStyle(status),
      isLive: isLive,
      status: status,
      startAt: _parseDate(startAt),
      maxTeams: (json['maxTeams'] as num?)?.toInt(),
    );
  }

  String get ownerDateLabel {
    if (startAt == null) return '—';
    final month = startAt!.month.toString().padLeft(2, '0');
    return '${startAt!.day} Tháng $month, ${startAt!.year}';
  }

  String get ownerPortalBadge {
    return switch (status) {
      'ONGOING' => 'Đang diễn ra',
      'COMPLETED' => 'Đã kết thúc',
      'CANCELLED' => 'Đã hủy',
      _ => 'Sắp diễn ra',
    };
  }

  bool get isOwnerOngoing => status == 'ONGOING';

  bool get isOwnerUpcoming =>
      !isOwnerOngoing && status != 'COMPLETED' && status != 'CANCELLED';

  bool get isOwnerCompleted =>
      status == 'COMPLETED' || status == 'CANCELLED';

  bool get canOwnerJoin =>
      status == 'ONGOING' || status == 'OPEN_REGISTRATION';

  int get ownerParticipantExtra {
    final seed = int.tryParse(id) ?? title.hashCode;
    return (seed.abs() % 80) + 8;
  }

  static DateTime? _parseDate(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    try {
      return DateTime.parse(iso).toLocal();
    } catch (_) {
      return null;
    }
  }

  static String _formatHomeDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.day} Thg ${date.month}, ${date.year}';
  }

  static String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      final date = DateTime.parse(iso).toLocal();
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      return '$day/$month';
    } catch (_) {
      return iso;
    }
  }

  static String _registrationLabel(String status, String? regOpen) {
    switch (status) {
      case 'OPEN_REGISTRATION':
        return 'Đang mở';
      case 'REGISTRATION_CLOSED':
      case 'COMPLETED':
      case 'CANCELLED':
        return 'Đã đóng';
      case 'ONGOING':
        return 'Đã đóng';
      default:
        final open = _formatDate(regOpen);
        return open == '—' ? 'Sắp mở' : 'Mở đăng ký: $open';
    }
  }

  static String? _badgeLabel(String status) {
    if (status == 'ONGOING') return null;
    if (status == 'OPEN_REGISTRATION') return 'Premium';
    return 'Grade 1';
  }

  static TournamentBadgeStyle _badgeStyle(String status) {
    if (status == 'ONGOING') return TournamentBadgeStyle.none;
    if (status == 'OPEN_REGISTRATION') {
      return TournamentBadgeStyle.navy;
    }
    return TournamentBadgeStyle.gold;
  }

  static List<TournamentListItem> sampleData() => const [
        TournamentListItem(
          id: '1',
          title: 'Summer Sprint Cup 2026',
          location: 'Phu Tho Racecourse',
          startLabel: 'Bắt đầu: 15/07',
          registrationLabel: 'Mở đăng ký: 01/06',
          racesLabel: '3 cuộc đua',
          badgeLabel: 'Grade 1',
          badgeStyle: TournamentBadgeStyle.gold,
          status: 'SCHEDULED',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCFd3f91RHXTECyT_RJ0i1PuPp_mpWoGsCnPrGO6GLF_BhWADi1swNsczBIy0xLBVeO5UdRoRE3b6YOsZHt2JLpccxA4lZTYFeq7Yd7cBawTfN6Ki_iHykNtE3pZUxag12IVSjf2oGLRmcR_zXtfoQ8UE6QAlv3Y4p3q9EdHG8AhJZmNF-4BrmLTDD2Aqba1slfnNCogDhhx50vZHy7jqighYEkdyElJUUhToHNhah3wM2pUDtw71e6q8KTtOQTnqdYniaDkhbpHw',
        ),
        TournamentListItem(
          id: '2',
          title: 'Viet Nam Open 2026',
          location: 'tp.hcm',
          startLabel: 'Bắt đầu: 20/08',
          registrationLabel: 'Đang mở',
          racesLabel: '1 cuộc đua',
          badgeLabel: 'Premium',
          badgeStyle: TournamentBadgeStyle.navy,
          status: 'OPEN_REGISTRATION',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDlFRCRbOaxyx5zajcSR8zEQJMgxKu9gFFvAZVcjjQB0s1_WdWJiWuF6ZAun2O1r1xGF0xB_2qrbkvXMizjeVMaHFAXP_R3q2Y2SVhXYO9Tk2k9K3PR0-LD8kVHlk2TJkVsTrvIlo0QbQy0cwd2paiUp9m3e0VRYh1rBJUl-2Nnis0E8J2UlY4JBETArYcmid4Mtlunywynda8FTs_bExbfxHIn2eS1ID0f1gBxm1CQEOa2bV4DFnCHGsOMGCAQOebyw1rJx5qp1Q',
        ),
        TournamentListItem(
          id: '3',
          title: 'Ongoing Night Race 2026',
          location: 'Vung Tau Racecourse',
          startLabel: 'Kết thúc: 22/06',
          registrationLabel: 'Đã đóng',
          racesLabel: '1 cuộc đua',
          isLive: true,
          status: 'ONGOING',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDjiFlakABxKp8H6nJLdmoAoIKse82i7beWgce5LUtSEl3zq0qShM_2hB_Io-pQAroWd59XSrcFG0Kvawq1HMhaoMG9Sxkq2LUQZzbXOZk-N3KppMTx-dSTVXD9g8gfJq71WE3gTFz90pdKk9eTf-ntP1DBf3VpgtHEh0HDDTm3aJOXa9srHufPNXDh9ldIpWoMvKuxoIuKuqg1v1emez3rWIxBsigFB2UF66AnRX9GECScPSgOGzwJ27oTCLsq-vkXPjmV30Jzpg',
        ),
      ];
}
