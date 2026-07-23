import 'package:flutter/material.dart';

import '../models/about_content.dart';

class AboutRepository {
  const AboutRepository();

  static const heroBadge = 'Tournament Management';
  static const heroTitle = 'Giới thiệu hệ thống';
  static const heroDescription =
      'Nền tảng quản lý giải đua chuyên nghiệp - Hỗ trợ toàn diện từ tổ chức giải đấu, '
      'đăng ký ngựa, phối hợp jockey đến theo dõi kết quả thi đấu.';

  List<AboutFeature> getFeatures() => const [
    AboutFeature(
      icon: Icons.workspace_premium_outlined,
      title: 'Quản lý giải đấu',
      description:
          'Tổ chức và quản lý các giải đua ngựa chuyên nghiệp với quy trình rõ ràng, minh bạch.',
    ),
    AboutFeature(
      icon: Icons.how_to_reg_outlined,
      title: 'Đăng ký ngựa tham gia',
      description:
          'Hệ thống đăng ký ngựa đua minh bạch với quản lý thông tin chi tiết và chính xác.',
    ),
    AboutFeature(
      icon: Icons.groups_outlined,
      title: 'Phối hợp Jockey',
      description:
          'Quản lý và phối hợp các jockeys chuyên nghiệp cho từng giải đấu một cách hiệu quả.',
    ),
    AboutFeature(
      icon: Icons.insights_outlined,
      title: 'Theo dõi kết quả',
      description:
          'Cập nhật kết quả thi đấu và bảng xếp hạng ngựa theo thời gian thực.',
    ),
  ];

  List<AboutBenefit> getBenefits() => const [
    AboutBenefit(
      icon: Icons.ads_click_outlined,
      title: 'Chuyên nghiệp',
      description:
          'Nền tảng được thiết kế theo tiêu chuẩn quốc tế cho mọi đối tác.',
    ),
    AboutBenefit(
      icon: Icons.bolt_outlined,
      title: 'Hiệu quả',
      description: 'Tối ưu hóa quy trình quản lý và vận hành nhanh chóng.',
    ),
    AboutBenefit(
      icon: Icons.verified_user_outlined,
      title: 'Bảo mật',
      description: 'Đảm bảo an toàn thông tin và dữ liệu người dùng tuyệt đối.',
    ),
  ];

  List<AboutProcessStep> getProcessSteps() => const [
    AboutProcessStep(
      step: 1,
      title: 'Đăng ký tài khoản',
      description:
          'Tạo tài khoản với vai trò phù hợp (Spectator, Owner, Jockey).',
    ),
    AboutProcessStep(
      step: 2,
      title: 'Tham gia giải đấu',
      description: 'Đăng ký ngựa hoặc jockey tham gia các giải đấu phù hợp.',
    ),
    AboutProcessStep(
      step: 3,
      title: 'Theo dõi diễn biến',
      description: 'Cập nhật kết quả và bảng xếp hạng theo thời gian thực.',
    ),
    AboutProcessStep(
      step: 4,
      title: 'Xem kết quả',
      description:
          'Kiểm tra kết quả cuối cùng và thống kê chi tiết sau mỗi giải đấu.',
    ),
  ];
}
