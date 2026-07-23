import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/owner_horse_item.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_toast.dart';
import '../../viewmodels/owner_horse_detail_viewmodel.dart';
import '../../widgets/news/news_network_image.dart';
import '../../widgets/owner/owner_app_bar.dart';
import '../../widgets/owner/owner_dashboard_widgets.dart';
import '../../widgets/referee/referee_glass_card.dart';
import 'owner_horse_form_screen.dart';

class OwnerHorseDetailScreen extends StatefulWidget {
  const OwnerHorseDetailScreen({
    super.key,
    required this.horseId,
    this.initialName,
    this.viewModel,
  });

  final String horseId;
  final String? initialName;
  final OwnerHorseDetailViewModel? viewModel;

  @override
  State<OwnerHorseDetailScreen> createState() => _OwnerHorseDetailScreenState();
}

class _OwnerHorseDetailScreenState extends State<OwnerHorseDetailScreen> {
  late final OwnerHorseDetailViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel =
        widget.viewModel ?? OwnerHorseDetailViewModel(horseId: widget.horseId);
    _viewModel.addListener(_onChanged);
    _viewModel.loadDetail();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openEditForm(OwnerHorseDetail detail) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OwnerHorseFormScreen(initialDetail: detail),
      ),
    );
    if (!mounted || changed != true) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa ngựa'),
        content: const Text('Bạn có chắc muốn xóa ngựa này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final success = await _viewModel.deleteHorse();
    if (!mounted) return;
    if (success) {
      AppToast.showSuccess(context, 'Đã xóa ngựa.');
      Navigator.of(context).pop(true);
      return;
    }

    final message = _viewModel.deleteError ?? 'Không thể xóa ngựa.';
    AppToast.showError(context, message);
  }

  Future<void> _openInviteJockey(OwnerHorseDetail detail) async {
    final changed = await AppRoutes.openOwnerCreateJockeyInvitation(
      context,
      initialHorseId: detail.id,
      initialHorseName: detail.name,
    );
    if (!mounted || changed != true) return;
    AppToast.showSuccess(context, 'Đã tạo lời mời jockey.');
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    if (_ownsViewModel) _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = _viewModel.detail;
    final title = detail?.name ?? widget.initialName ?? 'Chi tiết ngựa';

    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: OwnerAppBar(
        showBack: true,
        titleOverride: title,
        profileImageUrl: detail?.imageUrl,
      ),
      body: OwnerPortalBackground(child: _buildBody(detail)),
    );
  }

  Widget _buildBody(OwnerHorseDetail? detail) {
    if (_viewModel.isLoading && detail == null) {
      return const Center(
        child: CircularProgressIndicator(color: RefereeColors.championshipGold),
      );
    }

    if (_viewModel.errorMessage != null || detail == null) {
      return RefreshIndicator(
        color: RefereeColors.championshipGold,
        onRefresh: _viewModel.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(32),
          children: [
            const SizedBox(height: 120),
            Icon(
              Icons.error_outline,
              color: RefereeColors.onSurfaceVariant.withValues(alpha: 0.7),
              size: 42,
            ),
            const SizedBox(height: 16),
            Text(
              _viewModel.errorMessage ?? 'Không thể tải chi tiết ngựa.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: _viewModel.refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: RefereeColors.championshipGold,
      onRefresh: _viewModel.refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeroCard(detail: detail),
                      const SizedBox(height: 16),
                      _ActionBar(
                        isDeleting: _viewModel.isDeleting,
                        onEdit: () => _openEditForm(detail),
                        onDelete: _confirmDelete,
                      ),
                      if (detail.statusCode == 'APPROVED') ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _viewModel.isDeleting
                              ? null
                              : () => _openInviteJockey(detail),
                          icon: const Icon(Icons.mail_outline),
                          label: const Text('Mời jockey'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: RefereeColors.championshipGold,
                            side: const BorderSide(
                              color: RefereeColors.championshipGold,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _InfoSection(
                        title: 'Thông tin cơ bản',
                        children: [
                          _InfoRow('Giống', detail.breed),
                          _InfoRow('Tuổi', _ageLabel(detail.age)),
                          _InfoRow('Giới tính', _emptyLabel(detail.gender)),
                          _InfoRow('Màu lông', _emptyLabel(detail.color)),
                          _InfoRow('Thể trạng', _bodyMetricsLabel(detail)),
                          if (detail.ownerUsername?.isNotEmpty == true)
                            _InfoRow('Chủ sở hữu', detail.ownerUsername!),
                          if (detail.ownerId != null)
                            _InfoRow('Owner ID', '${detail.ownerId}'),
                          if (detail.createdAt != null)
                            _InfoRow('Ngày tạo', _formatDate(detail.createdAt)),
                          if (detail.updatedAt != null)
                            _InfoRow('Cập nhật', _formatDate(detail.updatedAt)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _PerformanceSection(performance: detail.performance),
                      const SizedBox(height: 16),
                      _DocumentSection(documentUrl: detail.documentUrl),
                      const SizedBox(height: 16),
                      _RaceHistorySection(items: detail.raceHistory),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.detail});

  final OwnerHorseDetail detail;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 260,
            child: detail.imageUrl.isNotEmpty
                ? NewsNetworkImage(imageUrl: detail.imageUrl)
                : ColoredBox(
                    color: RefereeColors.surfaceContainer,
                    child: Icon(
                      Icons.art_track_outlined,
                      size: 64,
                      color: RefereeColors.onSurfaceVariant.withValues(
                        alpha: 0.45,
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        detail.name,
                        style: AppTypography.displayMd(RefereeColors.onSurface),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _StatusBadge(
                      label: detail.statusLabel,
                      color: _statusColor(detail.statusCode),
                    ),
                  ],
                ),
                if (detail.reviewReason?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: RefereeColors.statusRed.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: RefereeColors.statusRed.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: RefereeColors.statusRed,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            detail.reviewReason!,
                            style: AppTypography.bodySm(
                              RefereeColors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.isDeleting,
    required this.onEdit,
    required this.onDelete,
  });

  final bool isDeleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: isDeleting ? null : onEdit,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Sửa'),
            style: FilledButton.styleFrom(
              backgroundColor: RefereeColors.championshipGold,
              foregroundColor: RefereeColors.background,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isDeleting ? null : onDelete,
            icon: isDeleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline),
            label: const Text('Xóa'),
            style: OutlinedButton.styleFrom(
              foregroundColor: RefereeColors.statusRed,
              side: BorderSide(
                color: RefereeColors.statusRed.withValues(alpha: 0.6),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTypography.headlineSm(RefereeColors.onSurface)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(
              label,
              style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMd(RefereeColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceSection extends StatelessWidget {
  const _PerformanceSection({required this.performance});

  final OwnerHorsePerformance performance;

  @override
  Widget build(BuildContext context) {
    return _InfoSection(
      title: 'Thành tích',
      children: [
        Row(
          children: [
            _MetricBox(label: 'Cuộc đua', value: '${performance.totalRaces}'),
            const SizedBox(width: 12),
            _MetricBox(label: 'Thắng', value: '${performance.wins}'),
            const SizedBox(width: 12),
            _MetricBox(label: 'Tỷ lệ thắng', value: performance.winRateLabel),
          ],
        ),
      ],
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTypography.headlineSm(RefereeColors.championshipGold),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentSection extends StatelessWidget {
  const _DocumentSection({required this.documentUrl});

  final String documentUrl;

  @override
  Widget build(BuildContext context) {
    return _InfoSection(
      title: 'Tài liệu',
      children: [
        Row(
          children: [
            const Icon(
              Icons.description_outlined,
              color: RefereeColors.championshipGold,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                documentUrl.isEmpty
                    ? 'Chưa có tài liệu'
                    : _existingFileLabel(documentUrl),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMd(RefereeColors.onSurface),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RaceHistorySection extends StatelessWidget {
  const _RaceHistorySection({required this.items});

  final List<OwnerHorseRaceHistoryItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _InfoSection(
        title: 'Lịch sử thi đấu',
        children: [
          Text(
            'Chưa có lịch sử thi đấu.',
            style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
          ),
        ],
      );
    }

    return _InfoSection(
      title: 'Lịch sử thi đấu',
      children: [
        for (final item in items) ...[
          _RaceHistoryTile(item: item),
          if (item != items.last)
            Divider(color: Colors.white.withValues(alpha: 0.08)),
        ],
      ],
    );
  }
}

class _RaceHistoryTile extends StatelessWidget {
  const _RaceHistoryTile({required this.item});

  final OwnerHorseRaceHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final meta = [
      if (item.tournamentName.isNotEmpty) item.tournamentName,
      if (item.racedAt != null) _formatDate(item.racedAt),
      if (item.rank != null) 'Hạng ${item.rank}',
      if (item.status?.isNotEmpty == true) item.status!,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.raceName,
            style: AppTypography.bodyMd(
              RefereeColors.onSurface,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            meta.isEmpty ? 'Chưa có thông tin' : meta.join(' • '),
            style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
          ),
          if (item.result?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              item.result!,
              style: AppTypography.bodySm(RefereeColors.onSurface),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: AppTypography.labelCaps(color).copyWith(fontSize: 11),
      ),
    );
  }
}

Color _statusColor(String status) {
  return switch (status) {
    'APPROVED' => RefereeColors.successEmerald,
    'REJECTED' => RefereeColors.statusRed,
    'SUSPENDED' => RefereeColors.statusRed,
    _ => RefereeColors.championshipGold,
  };
}

String _ageLabel(int? age) => age == null ? 'Chưa cập nhật' : '$age tuổi';

String _emptyLabel(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? 'Chưa cập nhật' : trimmed;
}

String _bodyMetricsLabel(OwnerHorseDetail detail) {
  final values = <String>[];
  if (detail.heightCm != null) {
    values.add('${_formatNumber(detail.heightCm!)} cm');
  }
  if (detail.weightKg != null) {
    values.add('${_formatNumber(detail.weightKg!)} kg');
  }
  return values.isEmpty ? 'Chưa cập nhật' : values.join(' • ');
}

String _formatNumber(double value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}

String _formatDate(DateTime? value) {
  if (value == null) return 'Chưa cập nhật';
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}

String _existingFileLabel(String url) {
  final slash = url.lastIndexOf('/');
  return slash >= 0 && slash < url.length - 1 ? url.substring(slash + 1) : url;
}
