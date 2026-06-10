import 'package:flutter/material.dart';

import '../constants/referee_colors.dart';

enum JockeyHorseBadgeType {
  bestResult,
  training,
}

class JockeyHorseItem {
  const JockeyHorseItem({
    required this.id,
    required this.name,
    required this.breed,
    required this.ownerName,
    required this.ageLabel,
    required this.imageUrl,
    required this.badgeType,
    required this.badgeLabel,
    required this.speed,
    required this.stamina,
    required this.health,
    required this.trainerNotes,
  });

  final String id;
  final String name;
  final String breed;
  final String ownerName;
  final String ageLabel;
  final String imageUrl;
  final JockeyHorseBadgeType badgeType;
  final String badgeLabel;
  final int speed;
  final int stamina;
  final int health;
  final String trainerNotes;

  Color get badgeColor {
    return switch (badgeType) {
      JockeyHorseBadgeType.bestResult => RefereeColors.successEmerald,
      JockeyHorseBadgeType.training => RefereeColors.championshipGold,
    };
  }
}

class JockeyHorsesData {
  const JockeyHorsesData({
    required this.horses,
    this.profileImageUrl,
  });

  final List<JockeyHorseItem> horses;
  final String? profileImageUrl;

  static JockeyHorsesData sample() {
    return JockeyHorsesData(
      profileImageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB_XW-Y7FnEzejz6EYMerFSspLgasM-atIrSSXKLU7EL6GNqW3FCqr2eR_b7E3IUZ6tv-i7hEtCYPMEvOYyl8iGt1HlnutSFNLT-zrL3wlCvukBDym-Wed_vETgeDkJwK4KgpksSWd7SOAIyqAZzDf-i2Pei7y8h9OUnJux0axRNoVXtLLf0Pin9KTIE-WrSSBO1PW6Ixeark_27vZygAuBtqtA7sQkQz5dst0dPP8gki_mEKled4tClu3WJmCzcIputzJfEgt7wDc',
      horses: const [
        JockeyHorseItem(
          id: 'horse-001',
          name: 'Silver Storm',
          breed: 'Thoroughbred',
          ownerName: 'Elite Stable',
          ageLabel: '5 tuổi',
          badgeType: JockeyHorseBadgeType.bestResult,
          badgeLabel: 'Best Result: 1st Place',
          speed: 92,
          stamina: 88,
          health: 100,
          trainerNotes: 'Thắng chặng GP tháng trước.',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBMolJ0D3jHHrlSs4Rww9onAAu2q8yeMQQ0lm3teNSYTBywY-vcii5qzUmeJr6dxTwqG07yW_43ZXDaatomFetSqQndyMFaTU93hzS2JnD47Yvzcb1IM9vAZHO8toGovVI3Fzaoeep2x44FHuMeRDZB3-mucLZPr5kNEGeu_-nA4Fc0fEKb4YjtFYOIeD095lRAW7P4WU6IOuoyClB49xtKeUBiiCjDpMbvm5P4csFts8fpWrXE7i6ASCipDrCGwUxfAIHxxqzb3_U',
        ),
        JockeyHorseItem(
          id: 'horse-002',
          name: 'Midnight Shadow',
          breed: 'Arabian',
          ownerName: 'Royal Stables',
          ageLabel: '4 tuổi',
          badgeType: JockeyHorseBadgeType.training,
          badgeLabel: 'Đang huấn luyện',
          speed: 85,
          stamina: 95,
          health: 90,
          trainerNotes:
              'Đang cải thiện sức bền trong đợt huấn luyện cao độ.',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCVu5yCtW9iM1kvdRYlGTgvm2DfkU-b1bt7cwQrdeobJt9NZVvnwTpUntyCCsGoz8iFeZ7YCYM3OR4DUcX3h-xRyKbhQxMg67jHTllIdUs3K0KlxRPD3G-hyWVBT1KJMyJJNAcoly5opgPm517U1PFTNZc4EqWJn2tPyveYTIAJ3DTfh2uik5AZhyMirUeOOtMR5fRpBiL8I4fnhZRpcQHfhyepgQTXZXYt-fiEd1jezipyi4xYHIgOc4-y1lGbDPJiBcEGqyFLoLU',
        ),
      ],
    );
  }
}
