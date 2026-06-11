import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_theme_tokens.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialSubTab.index,
    );
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
      extendBody: true,
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
