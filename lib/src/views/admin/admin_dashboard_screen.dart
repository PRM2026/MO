import 'package:flutter/material.dart';

import '../../services/admin_api_service.dart';
import '../../widgets/admin/admin_ui.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminApiService _service = AdminApiService();
  Map<String, dynamic>? _summary;
  List<Map<String, dynamic>> _revenue = const [];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final values = await Future.wait<Object>([
        _service.getDashboardSummary(),
        _service.getRevenue(),
      ]);
      if (!mounted) return;
      setState(() {
        _summary = values[0] as Map<String, dynamic>;
        _revenue = values[1] as List<Map<String, dynamic>>;
      });
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminRefreshHost(
      onRefresh: _load,
      child: AdminPage(
        title: 'Tổng quan',
        subtitle: 'Thống kê hệ thống quản lý giải đua ngựa',
        child: _body(),
      ),
    );
  }

  Widget _body() {
    if (_loading && _summary == null) return const AdminLoading();
    if (_error != null && _summary == null) {
      return AdminErrorCard(message: _error!, onRetry: _load);
    }

    final summary = _summary ?? const <String, dynamic>{};
    final stats = [
      (
        'Tổng giải đấu',
        adminText(summary, 'tournamentCount', '0'),
        Icons.emoji_events_rounded,
        AdminPalette.gold,
      ),
      (
        'Tổng cuộc đua',
        adminText(summary, 'raceCount', '0'),
        Icons.flag_rounded,
        AdminPalette.info,
      ),
      (
        'Lượt đăng ký',
        adminText(summary, 'registrationCount', '0'),
        Icons.groups_rounded,
        AdminPalette.success,
      ),
      (
        'Doanh thu',
        _compactMoney(summary['revenue']),
        Icons.payments_rounded,
        const Color(0xFFC084FC),
      ),
    ];

    return Column(
      children: [
        if (_error != null) ...[
          AdminErrorCard(message: _error!, onRetry: _load),
          const SizedBox(height: 14),
        ],
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.28,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (_, index) {
            final stat = stats[index];
            return AdminStatCard(
              label: stat.$1,
              value: stat.$2,
              icon: stat.$3,
              color: stat.$4,
            );
          },
        ),
        const SizedBox(height: 18),
        AdminCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Doanh thu 6 tháng',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Đơn vị: VNĐ',
                style: TextStyle(color: AdminPalette.muted, fontSize: 12),
              ),
              const SizedBox(height: 20),
              if (_revenue.isEmpty)
                const SizedBox(
                  height: 150,
                  child: Center(
                    child: Text(
                      'Chưa có dữ liệu doanh thu',
                      style: TextStyle(color: AdminPalette.muted),
                    ),
                  ),
                )
              else
                SizedBox(height: 190, child: _RevenueBars(data: _revenue)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                label: 'Tài sản hệ thống',
                value: _compactMoney(summary['treasuryAsset']),
                icon: Icons.account_balance_rounded,
                color: AdminPalette.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AdminStatCard(
                label: 'Công nợ người dùng',
                value: _compactMoney(summary['userLiability']),
                icon: Icons.receipt_long_rounded,
                color: AdminPalette.info,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _compactMoney(Object? raw) {
    final value = raw is num ? raw : num.tryParse('$raw') ?? 0;
    if (value.abs() >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)} tỷ';
    }
    if (value.abs() >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)} tr';
    }
    if (value.abs() >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return '${value.round()} ₫';
  }
}

class _RevenueBars extends StatelessWidget {
  const _RevenueBars({required this.data});

  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context) {
    final maxValue = data.fold<num>(
      1,
      (max, item) =>
          adminNumber(item, 'value') > max ? adminNumber(item, 'value') : max,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((item) {
        final value = adminNumber(item, 'value');
        final height = value == 0 ? 4.0 : 22 + (value / maxValue * 120);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  value == 0 ? '0' : '${(value / 1000000).toStringAsFixed(1)}M',
                  style: const TextStyle(
                    color: AdminPalette.goldLight,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 450),
                  height: height.toDouble(),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AdminPalette.goldLight, AdminPalette.gold],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  adminText(item, 'month'),
                  style: const TextStyle(
                    color: AdminPalette.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
