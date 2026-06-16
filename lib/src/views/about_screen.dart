import 'package:flutter/material.dart';

import '../constants/about_colors.dart';
import '../constants/app_spacing.dart';
import '../routes/app_routes.dart';
import '../viewmodels/about_viewmodel.dart';
import '../widgets/about/about_benefits_section.dart';
import '../widgets/about/about_cta_section.dart';
import '../widgets/about/about_feature_card.dart';
import '../widgets/about/about_hero_section.dart';
import '../widgets/about/about_process_section.dart';
import '../widgets/home/home_app_bar.dart';
import '../widgets/home/home_bottom_nav.dart';
import 'main_shell.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key, this.viewModel});

  final AboutViewModel? viewModel;

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late final AboutViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? AboutViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      extendBody: false,
      backgroundColor: AboutColors.surface,
      appBar: const HomeAppBar(),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(
              bottom: AppSpacing.bottomNavClearance,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.lg,
                    AppSpacing.screenPadding,
                    AppSpacing.xl,
                  ),
                  child: AboutHeroSection(
                    badge: _viewModel.heroBadge,
                    title: _viewModel.heroTitle,
                    description: _viewModel.heroDescription,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: AboutFeaturesSection(
                    features: _viewModel.features,
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                AboutBenefitsSection(benefits: _viewModel.benefits),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.section,
                    AppSpacing.screenPadding,
                    AppSpacing.section,
                  ),
                  child: AboutProcessSection(
                    steps: _viewModel.processSteps,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: AboutCtaSection(
                    onRegister: () => AppRoutes.openRegister(context),
                    onViewTournaments: () =>
                        MainShell.selectTab(context, HomeTab.tournaments),
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
