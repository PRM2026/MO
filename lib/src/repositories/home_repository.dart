import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../models/horse_ranking.dart';
import '../models/news_highlight.dart';
import '../models/stat_metric.dart';
class HomeRepository {
  const HomeRepository();

  List<HorseRanking> getHorseRankings() => const [
        HorseRanking(
          rank: 1,
          name: 'Thunderbolt',
          owner: 'Lê Văn A',
          winRateLabel: '94% Win Rate',
          isLeader: true,
        ),
        HorseRanking(
          rank: 2,
          name: 'Golden Stallion',
          owner: 'Nguyễn Kim',
          winRateLabel: '88% Win Rate',
        ),
        HorseRanking(
          rank: 3,
          name: 'Midnight Blue',
          owner: 'Trần Hải',
          winRateLabel: '82% Win Rate',
        ),
      ];

  List<StatMetric> getSystemStats() => const [
        StatMetric(
          icon: Icons.emoji_events,
          value: '156',
          label: 'GIẢI ĐẤU',
        ),
        StatMetric(
          icon: Icons.pets,
          value: '328',
          label: 'NGỰA ĐUA',
        ),
        StatMetric(
          icon: Icons.sports,
          value: '145',
          label: 'NÀI NGỰA',
        ),
        StatMetric(
          icon: Icons.groups,
          value: '2,845',
          label: 'KHÁN GIẢ',
        ),
      ];

  List<NewsHighlight> getNewsHighlights() => const [
        NewsHighlight(
          id: '1',
          category: 'KỸ THUẬT',
          title: 'Bí quyết huấn luyện ngựa vô địch...',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAPFX2ATpeLz0jaTYaisohRYtTjhORXp5vO3ugO69d5-HOp8CdPduR4qxQP-R9N0ofxpPEDdUFgzP5n9exryC_PxZHcFBspiOj4cvPrMa_0zxl9iIuFsddmI8FbPT5Dn2Nyi3qBN8wY9ukaWco_VKW3s8PKVRp5ao9G3hUVG7ZpIJCqheFCSmG0mB9IpLqVabko7mAUlg_dVCZ8ja3EVwaL1xF2HwBQCPQOOOXGp8Dk70e-3lNnYFDGarKXs_EI3Ozod-PN3zVlJMk',
        ),
        NewsHighlight(
          id: '2',
          category: 'SỰ KIỆN',
          title: 'Lễ hội đua ngựa mùa thu chuẩn bị...',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuB9UmSCLCfbiRF1YYMaSGsjYy2M-wF6MBSWWtgJsBUwhLEOB92B3vXDjRXRM1BfwOmlY34jUkCdiN4A2vFgTa-7UfIW4PvNifWnKkcEjQWDspaGHoNS8mEqJsXkwh_1yL5LZ7SMifklXvwiIh0M-icB50AA8Pcp_kZ5I5YGnif7nnauhlFwXphBTL1Hvf4ufzcsxLeAKFY5RsFl_OpuM1nf2yen6RRZjwklZ2qh_HCel1n9xnIBJ2BV5vP2ywhP_qlhsc5GtefXS0w',
        ),
        NewsHighlight(
          id: '3',
          category: 'THỊ TRƯỜNG',
          title: 'Cập nhật giá trị các chiến mã...',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCBSJoXm8-Dq59E5ct4IWu9Df2xa4Ut4DZi9ra2y0bMxbQCmZ_5sTyftPAwnNqV7uFZyJrFRH8ymNjHMijplDyH1aYrA9UXcmVpe4UiUfQ96x0kRwgd9p71osHfkWVarvD_64m7jE8gvj7Tmy8HFUION2skNagRjXoeTMTLsX0R_sjPdkBMph_27alwMAJ5ogDUeshxN_49o09kJx7E9BDrDgKcvt4sHX53VXdJkc7GI2HA7dBQ8wCO4DvgZi9ZbFSC_AA9v2QJ4pA',
        ),
      ];

  String get heroImageUrl => AppConstants.heroImageUrl;
}
