import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_theme_tokens.dart';
import '../repositories/auth_repository.dart';
import '../routes/app_routes.dart';
import '../utils/role_utils.dart';
import 'personal_info_screen.dart';
import 'role_request_screen.dart';
import '../widgets/home/home_app_bar.dart';

enum AccountSubTab { info, roleRequest }

class UserAccountScreen extends StatefulWidget {
  const UserAccountScreen({
    super.key,
    this.initialSubTab = AccountSubTab.info,
  });

  final AccountSubTab initialSubTab;

  @override
  State<UserAccountScreen> createState() => UserAccountScreenState();
}

class UserAccountScreenState extends State<UserAccountScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final AuthRepository _authRepository = AuthRepository();
  bool _portalRedirectScheduled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialSubTab.index,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirectToPortalIfNeeded();
    });
  }

  Future<void> _redirectToPortalIfNeeded() async {
    if (_portalRedirectScheduled) return;
    _portalRedirectScheduled = true;

    if (!await _authRepository.isLoggedIn()) return;

    final role = await _authRepository.resolveNavigationRole();
    if (!mounted || !hasDedicatedPortal(role)) return;

    AppRoutes.openDedicatedPortal(context, role);
  }

  void selectSubTab(AccountSubTab subTab) {
    if (_tabController.index == subTab.index) return;
    _tabController.animateTo(subTab.index);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      extendBody: false,
      backgroundColor: AppColors.surface,
      appBar: const HomeAppBar(title: 'Tài khoản'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.onSurfaceVariant,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: AppTypography.labelCaps(AppColors.primary)
                  .copyWith(fontSize: 13, letterSpacing: 0.2),
              unselectedLabelStyle: AppTypography.labelCaps(
                AppColors.onSurfaceVariant,
              ).copyWith(
                fontSize: 13,
                letterSpacing: 0.2,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Thông tin cá nhân'),
                Tab(text: 'Yêu cầu vai trò'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                PersonalInfoScreen(embedded: true),
                RoleRequestScreen(embedded: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
