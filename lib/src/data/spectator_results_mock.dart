import 'package:flutter/material.dart';

enum SpectatorResultsFilter {
  all,
  championshipSeries,
  g1Derby,
  speedChallenge,
}

class SpectatorResultFinisher {
  const SpectatorResultFinisher({
    required this.rank,
    required this.horseName,
    required this.jockeyName,
    required this.time,
    this.delta,
    this.isPersonalBest = false,
  });

  final int rank;
  final String horseName;
  final String jockeyName;
  final String time;
  final String? delta;
  final bool isPersonalBest;
}

class SpectatorRaceResultGroup {
  const SpectatorRaceResultGroup({
    required this.title,
    required this.meta,
    required this.category,
    required this.finishers,
    this.verified = false,
    this.accentColor,
    this.showLeaderboardAction = false,
  });

  final String title;
  final String meta;
  final SpectatorResultsFilter category;
  final List<SpectatorResultFinisher> finishers;
  final bool verified;
  final Color? accentColor;
  final bool showLeaderboardAction;
}

abstract final class SpectatorResultsMock {
  static const profileImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDXrhrgCRX6PDucM5GD6REE4Z5gaHriosweFUFYeXlckMRx8gBMvId2pjpe0G--zX0_BPRrB1CIFdItrpBAKZXw1Pg3uyvn_AL6aEVmkHT6uGMG6nWnLrYzyCJehCkPbRHgvrM_6dYcxIe-q_5bpVw-Vx9779EFKIN7kOGZQR2-Eoq5dIVmCZIgZfugv2lpNi8p29CyCyh4rnIRvq1tfDd76nuSDz20tQ0vQHRAizUoWFTGsXzgQA_Jm3C9Kt71xpAxq-ZXR5hRcToS';

  static const heroImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAZOivVT2QIW0NtEhUaEhgto1JUioD4gjkcux6FRXRK3_EL0NSD0ddfQukEQ3WRpFGP4mS5p3vOAVLa4SPTK7v_et1PXbV2LWFS9YGQYaqksbvJdTznwNkD1gL0fMJ-H9Xo8-Z-6aNZlLnVPzG9u9GMXCuuU8G39XyOz24gxIYqNBAq70ZSD8uj9GsnT83asXsQO1NUjnPYXN0HRR-53K-juN7r2WbxnyvH_IJjKVxp-FH_KAbfUAwqcChAJ2udOIt46sQrpfS3iMk5';

  static const primaryContainerAccent = Color(0xFFBBC7E0);

  static const filters = [
    (SpectatorResultsFilter.all, 'Tất cả'),
    (SpectatorResultsFilter.championshipSeries, 'Championship Series'),
    (SpectatorResultsFilter.g1Derby, 'G1 Derby'),
    (SpectatorResultsFilter.speedChallenge, 'Thử thách Tốc độ'),
  ];

  static const raceResults = [
    SpectatorRaceResultGroup(
      title: 'Grand Prix Singapore',
      meta: '14 THÁNG 5, 2024 • 1,200m Dirt Track',
      category: SpectatorResultsFilter.championshipSeries,
      verified: true,
      finishers: [
        SpectatorResultFinisher(
          rank: 1,
          horseName: 'Shadow Weaver',
          jockeyName: 'Marcus Aurelius',
          time: '01:08.42',
          delta: '-0.12s PB',
          isPersonalBest: true,
        ),
        SpectatorResultFinisher(
          rank: 2,
          horseName: 'Golden Horizon',
          jockeyName: 'Elena Rossi',
          time: '01:08.59',
          delta: '+0.17s',
        ),
        SpectatorResultFinisher(
          rank: 3,
          horseName: 'Thunder Bolt',
          jockeyName: 'David Smith',
          time: '01:09.11',
          delta: '+0.69s',
        ),
      ],
    ),
    SpectatorRaceResultGroup(
      title: 'Midnight Cup Invitational',
      meta: '12 THÁNG 5, 2024 • 1,600m Turf',
      category: SpectatorResultsFilter.g1Derby,
      accentColor: primaryContainerAccent,
      showLeaderboardAction: true,
      finishers: [
        SpectatorResultFinisher(
          rank: 1,
          horseName: 'Night Rider',
          jockeyName: 'Sam King',
          time: '01:34.22',
        ),
        SpectatorResultFinisher(
          rank: 2,
          horseName: 'Silver Bullet',
          jockeyName: 'Lisa Brown',
          time: '01:34.50',
        ),
      ],
    ),
    SpectatorRaceResultGroup(
      title: 'Velocity Challenge Final',
      meta: '8 THÁNG 5, 2024 • 1,000m Sand',
      category: SpectatorResultsFilter.speedChallenge,
      verified: true,
      finishers: [
        SpectatorResultFinisher(
          rank: 1,
          horseName: 'Flash Point',
          jockeyName: 'Kenji Tan',
          time: '00:58.91',
          delta: '-0.05s PB',
          isPersonalBest: true,
        ),
        SpectatorResultFinisher(
          rank: 2,
          horseName: 'Rocket Wind',
          jockeyName: 'Anna Cole',
          time: '00:59.04',
          delta: '+0.13s',
        ),
        SpectatorResultFinisher(
          rank: 3,
          horseName: 'Blaze Runner',
          jockeyName: 'Tom Reed',
          time: '00:59.22',
          delta: '+0.31s',
        ),
      ],
    ),
  ];
}
