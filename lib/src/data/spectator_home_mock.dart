enum SpectatorRaceStatus { open, pending }

class SpectatorFeaturedEvent {
  const SpectatorFeaturedEvent({
    required this.title,
    required this.dateLabel,
    required this.location,
    required this.imageUrl,
  });

  final String title;
  final String dateLabel;
  final String location;
  final String imageUrl;
}

class SpectatorRaceItem {
  const SpectatorRaceItem({
    required this.name,
    required this.time,
    required this.distance,
    required this.status,
  });

  final String name;
  final String time;
  final String distance;
  final SpectatorRaceStatus status;
}

class SpectatorFeaturedHorse {
  const SpectatorFeaturedHorse({
    required this.name,
    required this.rider,
    required this.rank,
    required this.imageUrl,
  });

  final String name;
  final String rider;
  final int rank;
  final String imageUrl;
}

class SpectatorRecentResult {
  const SpectatorRecentResult({
    required this.horseName,
    required this.time,
    required this.eventName,
    this.highlight = false,
  });

  final String horseName;
  final String time;
  final String eventName;
  final bool highlight;
}

abstract final class SpectatorHomeMock {
  static const featuredEvent = SpectatorFeaturedEvent(
    title: 'Grand Royal Derby',
    dateLabel: '15/12/2024',
    location: 'Sân vận động Quốc gia',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBDN8SjuOFsyE372DRfNPjaXRJIO5sZPrF2R-zIRzvlGJllTIfPV7nwW4oHtcBLt8SVyLsRjOVhMBovSevcHsyNrkWkVScm8sjYCjdfr4qnUJQvhOrrv10q3iB39__21gwrIU_DOj-mjvbYaLEQXzMJz4OTgEZ5u_JEJPpgVH4GWvLWm_Th8xTcb62XOENbVt-C_HXz0R1wxFl4N281YPpKWHUgVbgcYJ62poXT9IM3sUqYUJCS9UVFW6HjRgOuGM0kI6e2huu-tj_K',
  );

  static const defaultProfileImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAcnVER8NBBA-_vLUXwY0a1ZviaPhb_x4raS16PN80qplCa2u1OVdhgJTYZtRIA1IqwTx48qiwmQATCtCnSEObVrfwcfm2SllGrVqFzPLMp9hBf18tKoEXb0XGpsW-mpI8-OyabRdb2wCmPkOF5nKZoqAKZwg8-07wb0avCSVs2CqKUbq96lIemSldzcdPoIa3tY-wEba9FxrGqgxemwzzGNsFr0fYaUo2RKr1r8Xqa575O3bSZFYrwoHaeKx2yAjtlVqtpn1oVHWIF';

  static const upcomingRaces = [
    SpectatorRaceItem(
      name: 'Cúp Hoàng Gia',
      time: '14:30',
      distance: '2400m',
      status: SpectatorRaceStatus.open,
    ),
    SpectatorRaceItem(
      name: 'Hạng Thử Thách',
      time: '16:15',
      distance: '1800m',
      status: SpectatorRaceStatus.pending,
    ),
    SpectatorRaceItem(
      name: 'Vòng Loại Quốc Gia',
      time: '18:00',
      distance: '3200m',
      status: SpectatorRaceStatus.pending,
    ),
  ];

  static const featuredHorses = [
    SpectatorFeaturedHorse(
      name: 'Thunder Spirit',
      rider: 'Marcus Vane',
      rank: 1,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBtKlonI6DAl8V6i4ZGaJBcUQrN5k9gHms0hYDu_cH3xSMBDBGzKm4L8hSZHVo4sVAJiSercC9w4WgiDRiFi0UBChPen1Tauj45sYoWCyTRgcYrOJqxMW4kf3AUqqh-QNDhvCieV5oy3qEieGndrd2e9EhjaaxVrHzms_FRTLlBwAepHWJdbotD4NrM6Ft8kjKT6nq7CFzFzwEfNwXWOzHVy05oVLsjqaH2qmYv9AyG4fkymdRUSafm-hAF1uJRq-dBaZT78qqcZZK2',
    ),
    SpectatorFeaturedHorse(
      name: 'Golden Arrow',
      rider: 'Elena Rose',
      rank: 4,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBd4s4jI8IkXuLCGbu-10T6Vnrbz6zxyYTA83N1WzTcwwQHg4PnmcsPkkOELrQHoVW_DBzk4WEg3uU3EiFlTmNP2YgQq3wPBOux3QCB8YK3gKzLQxyhQFE8XDEcAg-0AP88kCoXaBSPDyTw3K39Wgmv3LTxBWsgm7pyWfc7zXGVjcMWseoJI-9oHEQgbtmNl50Z9Y0Y9dGrHMmVDt2rMI4vNFTaxC1wWeyCBgQNsGBcGoPK6R9MZ0GB-w4jRf96YBc0ZxboDqoHHPPV',
    ),
    SpectatorFeaturedHorse(
      name: 'Silver Streak',
      rider: 'Julian Thorne',
      rank: 7,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCirTNF2wePTcAloJXAvVQTLkfgAsKf3t7J0DAAoPLxNUqrDphVTRTopanlitfHjaYZ2yo6G7nhzQ8t-eSMFcu1CxA7_0pouVDnirAWYTsxgEGPkGzTpwO7eFAd85kpy8ajBe3g2Iko7JqVTz8HfiDyixRD2e1ZHhFHIuvhEEt4akrUIpPHmOQJtkTrbro_g7DsFZ2cr3qt9XuTsfrJUbU_eFEk7oxUjRJe2Ckzj0TL3ZIZ7Y2ajEFvRm9hT5kN3539eIDnjmb4Ri8m',
    ),
  ];

  static const recentResults = [
    SpectatorRecentResult(
      horseName: 'Midnight Shadow',
      time: '2:45.32',
      eventName: 'Giải Derby Mùa Thu',
      highlight: true,
    ),
    SpectatorRecentResult(
      horseName: 'Desert Wind',
      time: '2:12.08',
      eventName: 'Cúp Tốc Độ 2024',
    ),
    SpectatorRecentResult(
      horseName: 'Storm King',
      time: '3:01.55',
      eventName: 'Đường Đua Thành Phố',
    ),
  ];
}
