enum SpectatorRaceFilter { upcoming, finished, date }

class SpectatorScheduleFeatured {
  const SpectatorScheduleFeatured({
    required this.badge,
    required this.title,
    required this.imageUrl,
  });

  final String badge;
  final String title;
  final String imageUrl;
}

class SpectatorScheduleRace {
  const SpectatorScheduleRace({
    required this.category,
    required this.trackInfo,
    required this.title,
    required this.timeBadge,
    required this.time,
    required this.venue,
    this.participantAvatars = const [],
    this.extraParticipants = 0,
    this.featured = false,
    this.isUpcoming = true,
  });

  final String category;
  final String trackInfo;
  final String title;
  final String timeBadge;
  final String time;
  final String venue;
  final List<String> participantAvatars;
  final int extraParticipants;
  final bool featured;
  final bool isUpcoming;
}

abstract final class SpectatorRacesMock {
  static const scheduleHero = SpectatorScheduleFeatured(
    badge: 'Sự kiện nổi bật',
    title: 'Season Championship',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBnuqoTJM2gGMBU-bRSBlkb6hu5de7bEKpecwICNGHjMOwd2Anap7nyIjbP4ebhH8FZ3mUwyuuf6rj9AYfEoz2HnivygDlkdvEh5lqUMW412jXO3G4AoPsSgm4J_KhchAobmarKw4Wq-zNCdbwtyuruNarGFSYYXm5QlIQbpfZ8roYlcLttFhgaTd9TnzHf-58ut4NM604k8onNxX21A6_mWeexyKXaQch0vW-pRPlMJRBxrC5lESy2gQtmb76tP2VvwtsWmGjgFbrR',
  );

  static const profileImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBCoqA6NpXNz_yizMSn5VSLDFcEyUfp9GqxpNt7UpO75n_rlmq7EFt0BlE0kPoDS1OjaniAriq_LKK52-FKKf4quPDHdeVcK3NvgNP-v5x_7kR-LTSkjtIFWDju5Webn0NsP2uBxuWjEpckyHV1xVPKkKw-8I-UkrqRL3VaNbMSMxdy2IYrnAhdrS7XsLkOUTgWha56PtnzfaXZDYe7jjVu07UwEFqpNOF8-qQEhdjNbu9WuR_aHt9iHjBpOanAbaCJomzLIdlUNGZW';

  static const upcomingScheduleRaces = [
    SpectatorScheduleRace(
      category: 'Grade I Stakes',
      trackInfo: '2.4km Turf',
      title: 'The Golden Derby',
      timeBadge: 'Còn 2 ngày',
      time: '15:30 GMT',
      venue: 'Ascot Park',
      participantAvatars: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCUaZy9iNCsXSpc3qLTg81N-OHFEjZC4g7Hem6ikpttXjVD17c9GuYATtk0SE8pqO99s4JXmSl_KUnBBOZ5pCmTAIRoPi3J4Ns_OsNkpknvNzsxh0aH58DgR4qAmGr9Z7Cree4RMyzwsVMOOMfiNE7q_U1cZdstc3NjNiD1pILQIcL1RdO8Hyn6QYKj5VQAWjt-dB05ZpJO0ePayhIePDvKIrNLf4__yocjJqNdZHJtB_N6yafJF_g90fRvHff0X70cAMabDpajd8T8',
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBInYwlnaedWB-6Qb4IhngyBfvaroKHBN_f7I7jL-o1UJn3GpIivwviF_o53RBaDmabY35GDTUWLiG1GUmfK7I5UJit1rV3Be348HF2CrdQCBHTrnb2LdW7svz1R2TO0ElbWvhOwEsdzZNs4T_b4BNhTsGAtj7iejon35AXPh1_u65shxFkukk-jb0EfojjpxaU4Pti8uY0XLLfItSh6vpmCox4ti3XzMnsjTGq2DgH8Kg5zRu2YfX7kAfTT6swu0A46VGOI5ezduGQ',
      ],
      extraParticipants: 12,
      featured: true,
    ),
    SpectatorScheduleRace(
      category: 'International Open',
      trackInfo: '1.6km Sand',
      title: 'Midnight Sprint',
      timeBadge: '14/11',
      time: '20:00 GMT',
      venue: 'Dubai Arena',
      participantAvatars: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuA0NRfmt-nKlA6Bv0EreQ8AFzoOQ8n_L5kRH07aYYIQbKjDJzI00uc5Ve9pJ0xqMqcMPv_O7gDJ5lFvQEcsVPs5BSy8PmDTtJx-2gteGvRxmhpmyxlw3pMPi8_84I4S5PWTYao7pej_HmQLn92WfpgKC8TfBPu-0nB7JNgDu049ebs0Lsi7foTZbUx0toQGNO3xuVHaHvG5BqcHhCe0IXKF__Nc79s9DvXXpNxkffJFjNQNXFw1omDh2UVcmuYXAzP0JZ43lRinR-Tc',
      ],
      extraParticipants: 8,
    ),
    SpectatorScheduleRace(
      category: 'Novice Cup',
      trackInfo: '2.0km Turf',
      title: 'Emerald Plateau',
      timeBadge: '18/11',
      time: '13:15 GMT',
      venue: 'Melbourne Tr.',
      extraParticipants: 24,
    ),
  ];

  static const finishedScheduleRaces = [
    SpectatorScheduleRace(
      category: 'Classic Cup',
      trackInfo: '3.2km Turf',
      title: 'Autumn Crown',
      timeBadge: '28/10',
      time: '16:45 GMT',
      venue: 'Royal Ascot',
      extraParticipants: 18,
      isUpcoming: false,
    ),
    SpectatorScheduleRace(
      category: 'Sprint Series',
      trackInfo: '1.2km Sand',
      title: 'Night Flash',
      timeBadge: '21/10',
      time: '19:30 GMT',
      venue: 'Monaco Circuit',
      participantAvatars: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuA0NRfmt-nKlA6Bv0EreQ8AFzoOQ8n_L5kRH07aYYIQbKjDJzI00uc5Ve9pJ0xqMqcMPv_O7gDJ5lFvQEcsVPs5BSy8PmDTtJx-2gteGvRxmhpmyxlw3pMPi8_84I4S5PWTYao7pej_HmQLn92WfpgKC8TfBPu-0nB7JNgDu049ebs0Lsi7foTZbUx0toQGNO3xuVHaHvG5BqcHhCe0IXKF__Nc79s9DvXXpNxkffJFjNQNXFw1omDh2UVcmuYXAzP0JZ43lRinR-Tc',
      ],
      extraParticipants: 6,
      isUpcoming: false,
    ),
  ];
}
