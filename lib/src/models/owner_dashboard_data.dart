enum OwnerRaceStatusTone { emerald, gold, muted }

class OwnerHeroTournament {
  const OwnerHeroTournament({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.badgeLabel = 'SẮP DIỄN RA',
  });

  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String badgeLabel;
}

class OwnerFeaturedHorse {
  const OwnerFeaturedHorse({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.imageUrl,
    this.rankLabel,
  });

  final String id;
  final String name;
  final String subtitle;
  final String imageUrl;
  final String? rankLabel;
}

class OwnerUpcomingRace {
  const OwnerUpcomingRace({
    required this.id,
    required this.title,
    required this.detail,
    required this.day,
    required this.monthLabel,
    required this.statusLabel,
    this.tone = OwnerRaceStatusTone.muted,
  });

  final String id;
  final String title;
  final String detail;
  final int day;
  final String monthLabel;
  final String statusLabel;
  final OwnerRaceStatusTone tone;
}

class OwnerDashboardData {
  const OwnerDashboardData({
    required this.hero,
    required this.featuredHorses,
    required this.upcomingRaces,
    this.profileImageUrl,
  });

  final OwnerHeroTournament hero;
  final List<OwnerFeaturedHorse> featuredHorses;
  final List<OwnerUpcomingRace> upcomingRaces;
  final String? profileImageUrl;

  static OwnerDashboardData sample({String? profileImageUrl}) {
    return OwnerDashboardData(
      profileImageUrl: profileImageUrl ??
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCH6abuic9j19Rq_07gwoHUOLWJEMwUUs7sNlwg7pMpBPh6KYhCNcupeyL-PHK9KJ9tXMVJOwIyuVOyssWFb1-bwz25DBXdqAtSXgRgS6ZuD-15v9NH-priZ3pq6GB94AGXogR3qN_nV05jm-ou5ur1DtZAzjYBWOmuC5SpGXVH9d-fymgRueK9pXiRU0IomLTUcViTjHRQ0fVjloIG7I7E2ktEKBwinObQPGP-T-AE5Y20y2zgd0APPX71Y52pKjpZnO5AytjaCswu',
      hero: const OwnerHeroTournament(
        id: '1',
        title: 'Grand Royal Derby',
        subtitle: '15/12/2024 • Sân vận động Quốc gia',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBv_JttpbSUsrxNq9g8yuU8HvLW1oML0_m3pp5Z7k-OYA-PfKxAKTq8RnCjAuoloM5XfhmVADcpL4jGWJRORz18ZMU6To8beskVKMO9mviIl7UWVl-Geh39whviav2lqby83qH3OoaKyYPrmGifkc5NU_hFMQTvMuG9D2cdtkiCDDIXS1UzoOMaWcvcfqXX4KqS9sq4EYCSbE5qqBkETe1p3sGCNzm4Ccs6gNrpLRuv3p3LAtYmSn_BNxZoLPN59RLU6lyp7QOUiaA3',
      ),
      featuredHorses: const [
        OwnerFeaturedHorse(
          id: '1',
          name: 'Thunder Spirit',
          subtitle: 'Marcus Vance',
          rankLabel: '#1 Rank',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuC875cbYPNkDJd1UJwoFkn0EHKpSAcO3Q8P4oVg6DB_eKeiglU43xhjmmwwOKQe1JLE74Cy4FfxH2k9N_N-pMtfdRWsw1hN52dfpQuoE0nRqgAIMb47M0a6n6ytfTP0zsD2fsD-SaAM3UehiLJE6DuZbzf0Ck6cg9U2JQnA39CnEY9IigNukOnmOKXxtHoWirmo_SZkZjTzTsTkPx8cGPXzm1qRkKVUl9ayvUQYj9RlplG-SfKmckT6aNm8pw-NSEoeQ0qeDFievLFR',
        ),
        OwnerFeaturedHorse(
          id: '2',
          name: 'Golden Arrow',
          subtitle: 'Elena Rossi',
          rankLabel: '#3 Rank',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDGyfnhALBvwu8nxnnKAxFxuNXBXLClXttEJObMPerOjNUmpX959JPruoYl_S36rXHRla5HaSqNxHxy3XQuA20MjZel4CFBlkRXmtCPubsBG3WBAuRICGHbgeZv1PPnBO7wChtUa3TdArc8Qam1XqMZ7S4ofbbL7MeZSYu_JBT7E0iyD6ZPRwsc13mlCr2leRyOSR0DzKAJVjnhGGuZb7UKtRN6iuzhvzOmJm_LcwtTkm0dFDBCtwlDCn9BFtbRw6kXwc4A54cs28aw',
        ),
        OwnerFeaturedHorse(
          id: '3',
          name: 'Midnight Shadow',
          subtitle: 'Julian Thorne',
          rankLabel: '#5 Rank',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuC8s66JkJiWEHt-ckec4-O9OJwbEvMbH-POjpv63D0rs5OnNLRyRZBWxoxAmPqADobMgM4CJLQRVdUwQrN0gFX8k1YngNKVltLaVXvHS1mKxh-n32Z5X0CAUDxSw1n68nLhqMHctNNLw7RjjT6qxYju3Fu34kturD3fRknrF54yWSteq6nk-xQ5hmB5duCbvrbZAiqrcHoxq2U1keAjY973sixIAbNM04T8o-EXpprCDoJ5ZFan8OYPCzQH6VNH4UfXXwlKpfgLw25I',
        ),
      ],
      upcomingRaces: const [
        OwnerUpcomingRace(
          id: '1',
          title: 'Cúp Hoàng Gia',
          detail: '14:30 PM • Đường đua số 1',
          day: 14,
          monthLabel: 'TH12',
          statusLabel: 'Mở đăng ký',
          tone: OwnerRaceStatusTone.emerald,
        ),
        OwnerUpcomingRace(
          id: '2',
          title: 'Grand Royal Derby',
          detail: '10:00 AM • Sân vận động QG',
          day: 15,
          monthLabel: 'TH12',
          statusLabel: 'Bán vé',
          tone: OwnerRaceStatusTone.gold,
        ),
        OwnerUpcomingRace(
          id: '3',
          title: 'Vòng Loại Khu Vực',
          detail: '08:00 AM • Đường đua Cát',
          day: 18,
          monthLabel: 'TH12',
          statusLabel: 'Đang chuẩn bị',
          tone: OwnerRaceStatusTone.muted,
        ),
      ],
    );
  }
}
