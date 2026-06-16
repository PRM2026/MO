import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../viewmodels/news_viewmodel.dart';
import '../widgets/home/home_app_bar.dart';
import '../widgets/news/featured_news_card.dart';
import '../widgets/news/news_list_tile.dart';
import '../widgets/news/news_search_bar.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key, this.viewModel});

  final NewsViewModel? viewModel;

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late final NewsViewModel _viewModel;
  late final TextEditingController _searchController;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? NewsViewModel();
    _viewModel.addListener(_onViewModelChanged);
    _searchController = TextEditingController();
    _viewModel.loadNews();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    if (_ownsViewModel) _viewModel.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      extendBody: false,
      backgroundColor: AppColors.surface,
      appBar: const HomeAppBar(),
      body: RefreshIndicator(
        onRefresh: _viewModel.refreshNews,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.lg,
                AppSpacing.screenPadding,
                AppSpacing.bottomNavClearance,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  NewsSearchBar(
                    controller: _searchController,
                    onChanged: _viewModel.updateSearch,
                  ),
                  const SizedBox(height: AppSpacing.section),
                  if (_viewModel.isLoading && _viewModel.featuredNews.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_viewModel.errorMessage != null &&
                      _viewModel.featuredNews.isEmpty &&
                      _viewModel.latestNews.isEmpty)
                    _ErrorState(
                      message: _viewModel.errorMessage!,
                      onRetry: _viewModel.loadNews,
                    )
                  else ...[
                    if (_viewModel.featuredNews.isNotEmpty) ...[
                      FeaturedNewsSection(
                        articles: _viewModel.featuredNews,
                        onReadMore: (_) =>
                            _showSnack('Đang mở bài viết...'),
                      ),
                      const SizedBox(height: AppSpacing.section),
                    ],
                    LatestNewsSection(
                      articles: _viewModel.latestNews,
                      onArticleTap: (_) =>
                          _showSnack('Đang mở bài viết...'),
                      onLoadMore: _viewModel.refreshNews,
                    ),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 48,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
