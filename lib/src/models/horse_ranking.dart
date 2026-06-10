class HorseRanking {
  const HorseRanking({
    required this.rank,
    required this.name,
    required this.owner,
    required this.winRateLabel,
    this.isLeader = false,
  });

  final int rank;
  final String name;
  final String owner;
  final String winRateLabel;
  final bool isLeader;
}
