import 'package:flutter/material.dart';

import '../models/jockey_profile_response.dart';
import '../repositories/auth_repository.dart';
import '../utils/role_utils.dart';
import '../views/account_screen.dart';
import '../views/login_screen.dart';
import '../views/main_shell.dart';
import '../views/user_account_screen.dart';
import '../views/jockey/jockey_change_password_screen.dart';
import '../views/jockey/jockey_invitations_screen.dart';
import '../views/jockey/jockey_deposit_screen.dart';
import '../views/jockey/jockey_notifications_screen.dart';
import '../views/jockey/jockey_profile_edit_screen.dart';
import '../views/jockey/jockey_profile_screen.dart';
import '../views/jockey/jockey_race_detail_screen.dart';
import '../views/jockey/jockey_race_results_screen.dart';
import '../views/jockey/jockey_shell.dart';
import '../views/jockey/jockey_wallet_screen.dart';
import '../views/jockey/jockey_withdrawal_screen.dart';
import '../views/owner/owner_change_password_screen.dart';
import '../views/owner/owner_shell.dart';
import '../views/referee/referee_change_password_screen.dart';
import '../views/referee/referee_profile_screen.dart';
import '../views/referee/referee_shell.dart';
import '../views/register_screen.dart';
import '../views/spectator/spectator_shell.dart';
import '../widgets/home/home_bottom_nav.dart';

abstract final class AppRoutes {
  static Route<void> login() {
    return MaterialPageRoute<void>(builder: (_) => const LoginScreen());
  }

  static Route<void> register() {
    return MaterialPageRoute<void>(builder: (_) => const RegisterScreen());
  }

  static Route<void> account() {
    return MaterialPageRoute<void>(builder: (_) => const AccountScreen());
  }

  static Route<void> jockeyChangePassword({String? profileImageUrl}) {
    return MaterialPageRoute<void>(
      builder: (_) =>
          JockeyChangePasswordScreen(profileImageUrl: profileImageUrl),
    );
  }

  static Route<void> jockeyProfile() {
    return MaterialPageRoute<void>(builder: (_) => const JockeyProfileScreen());
  }

  static Route<JockeyProfileResponse> jockeyProfileEdit(
    JockeyProfileResponse profile,
  ) {
    return MaterialPageRoute<JockeyProfileResponse>(
      builder: (_) => JockeyProfileEditScreen(profile: profile),
    );
  }

  static Route<void> jockeyPortal() {
    return MaterialPageRoute<void>(builder: (_) => const JockeyShell());
  }

  static Route<void> jockeyWallet() {
    return MaterialPageRoute<void>(builder: (_) => const JockeyWalletScreen());
  }

  static Route<void> jockeyNotifications() {
    return MaterialPageRoute<void>(
      builder: (_) => const JockeyNotificationsScreen(),
    );
  }

  static Route<bool> jockeyDeposit() {
    return MaterialPageRoute<bool>(builder: (_) => const JockeyDepositScreen());
  }

  static Route<bool> jockeyWithdrawal() {
    return MaterialPageRoute<bool>(
      builder: (_) => const JockeyWithdrawalScreen(),
    );
  }

  static Route<void> jockeyRaceDetail(String raceId) {
    return MaterialPageRoute<void>(
      builder: (_) => JockeyRaceDetailScreen(raceId: raceId),
    );
  }

  static Route<bool> jockeyInvitationDetail(String invitationId) {
    return MaterialPageRoute<bool>(
      builder: (_) => JockeyInvitationDetailScreen(invitationId: invitationId),
    );
  }

  static Route<void> jockeyRaceResults({
    required String raceId,
    String? tournamentId,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) =>
          JockeyRaceResultsScreen(raceId: raceId, tournamentId: tournamentId),
    );
  }

  static Route<void> ownerPortal() {
    return MaterialPageRoute<void>(builder: (_) => const OwnerShell());
  }

  static Route<void> ownerChangePassword({String? profileImageUrl}) {
    return MaterialPageRoute<void>(
      builder: (_) =>
          OwnerChangePasswordScreen(profileImageUrl: profileImageUrl),
    );
  }

  static Route<void> refereeChangePassword({String? profileImageUrl}) {
    return MaterialPageRoute<void>(
      builder: (_) =>
          RefereeChangePasswordScreen(profileImageUrl: profileImageUrl),
    );
  }

  static Route<void> refereeProfile() {
    return MaterialPageRoute<void>(
      builder: (_) => const RefereeProfileScreen(),
    );
  }

  static Route<void> refereePortal() {
    return MaterialPageRoute<void>(builder: (_) => const RefereeShell());
  }

  static Route<void> spectatorPortal() {
    return MaterialPageRoute<void>(builder: (_) => const SpectatorShell());
  }

  static Route<void> main({HomeTab initialTab = HomeTab.home}) {
    return MaterialPageRoute<void>(
      builder: (_) => MainShell(initialTab: initialTab),
    );
  }

  static Route<void> accountTab() => main(initialTab: HomeTab.account);

  static Route<void> home() => main();

  static Route<void> news() => main(initialTab: HomeTab.news);

  static Route<void> about() => main(initialTab: HomeTab.about);

  static void openLogin(BuildContext context, {bool replace = false}) {
    _pushAuth(context, login(), replace: replace);
  }

  static void openRegister(BuildContext context, {bool replace = false}) {
    _pushAuth(context, register(), replace: replace);
  }

  static void openAccount(BuildContext context) {
    final shell = MainShell.of(context);
    if (shell != null) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
      shell.onLoggedIn();
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(accountTab(), (route) => false);
  }

  static Route<void> _portalRouteForRole(String role) {
    switch (normalizePortalRole(role)) {
      case 'JOCKEY':
        return jockeyPortal();
      case 'REFEREE':
        return refereePortal();
      case 'OWNER':
        return ownerPortal();
      case 'SPECTATOR':
        return spectatorPortal();
      default:
        return main(initialTab: HomeTab.home);
    }
  }

  /// After login/register: route to role portal or main home.
  static Future<void> openAfterAuth(BuildContext context) async {
    final repository = AuthRepository();
    final role = await repository.resolveNavigationRole();

    if (!context.mounted) return;

    final navigator = Navigator.of(context, rootNavigator: true);
    if (hasDedicatedPortal(role)) {
      navigator.pushAndRemoveUntil(_portalRouteForRole(role), (_) => false);
      return;
    }

    navigator.pushAndRemoveUntil(main(initialTab: HomeTab.home), (_) => false);
  }

  /// Clears navigation stack and returns to public home after logout.
  static void openAfterLogout(BuildContext context) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushAndRemoveUntil(main(initialTab: HomeTab.home), (_) => false);
  }

  static void openDedicatedPortal(BuildContext context, String role) {
    if (!hasDedicatedPortal(role)) return;
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushAndRemoveUntil(_portalRouteForRole(role), (_) => false);
  }

  static void openOwnerPortal(BuildContext context) {
    Navigator.of(context).push(ownerPortal());
  }

  static void openRefereePortal(BuildContext context) {
    Navigator.of(context).push(refereePortal());
  }

  static void openJockeyPortal(BuildContext context) {
    Navigator.of(context).push(jockeyPortal());
  }

  static void openJockeyProfile(BuildContext context) {
    Navigator.of(context).push(jockeyProfile());
  }

  static void openJockeyWallet(BuildContext context) {
    Navigator.of(context).push(jockeyWallet());
  }

  static Future<void> openJockeyNotifications(BuildContext context) {
    return Navigator.of(context).push(jockeyNotifications());
  }

  static Future<bool?> openJockeyDeposit(BuildContext context) {
    return Navigator.of(context).push(jockeyDeposit());
  }

  static Future<bool?> openJockeyWithdrawal(BuildContext context) {
    return Navigator.of(context).push(jockeyWithdrawal());
  }

  static void openJockeyRaceDetail(BuildContext context, String raceId) {
    Navigator.of(context).push(jockeyRaceDetail(raceId));
  }

  static Future<bool?> openJockeyInvitationDetail(
    BuildContext context,
    String invitationId,
  ) {
    return Navigator.of(context).push(jockeyInvitationDetail(invitationId));
  }

  static void openJockeyRaceResults(
    BuildContext context, {
    required String raceId,
    String? tournamentId,
  }) {
    Navigator.of(
      context,
    ).push(jockeyRaceResults(raceId: raceId, tournamentId: tournamentId));
  }

  static Future<JockeyProfileResponse?> openJockeyProfileEdit(
    BuildContext context,
    JockeyProfileResponse profile,
  ) {
    return Navigator.of(context).push(jockeyProfileEdit(profile));
  }

  static void openJockeyChangePassword(
    BuildContext context, {
    String? profileImageUrl,
  }) {
    Navigator.of(
      context,
    ).push(jockeyChangePassword(profileImageUrl: profileImageUrl));
  }

  static void openOwnerChangePassword(
    BuildContext context, {
    String? profileImageUrl,
  }) {
    Navigator.of(
      context,
    ).push(ownerChangePassword(profileImageUrl: profileImageUrl));
  }

  static void openRefereeProfile(BuildContext context) {
    Navigator.of(context).push(refereeProfile());
  }

  static void openRefereeChangePassword(
    BuildContext context, {
    String? profileImageUrl,
  }) {
    Navigator.of(
      context,
    ).push(refereeChangePassword(profileImageUrl: profileImageUrl));
  }

  static void openHome(BuildContext context) {
    if (MainShell.of(context) != null) {
      MainShell.selectTab(context, HomeTab.home);
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    Navigator.of(context).pushReplacement(main());
  }

  static void openNews(BuildContext context) {
    _switchTabOrReplace(context, HomeTab.news);
  }

  static void openProfile(BuildContext context) {
    if (MainShell.of(context)?.isLoggedIn != true) {
      openLogin(context);
      return;
    }
    _switchTabOrReplace(context, HomeTab.account);
    MainShell.selectAccountSubTab(context, AccountSubTab.info);
  }

  static void openRoleRequest(BuildContext context) {
    if (MainShell.of(context)?.isLoggedIn != true) {
      openLogin(context);
      return;
    }
    _switchTabOrReplace(context, HomeTab.account);
    MainShell.selectAccountSubTab(context, AccountSubTab.roleRequest);
  }

  static void openAbout(BuildContext context) {
    _switchTabOrReplace(context, HomeTab.about);
  }

  static void _pushAuth(
    BuildContext context,
    Route<void> route, {
    required bool replace,
  }) {
    final navigator = Navigator.of(context);
    if (replace) {
      navigator.pushReplacement(route);
    } else {
      navigator.push(route);
    }
  }

  static void _switchTabOrReplace(BuildContext context, HomeTab tab) {
    if (MainShell.of(context) != null) {
      MainShell.selectTab(context, tab);
      return;
    }
    Navigator.of(context).pushReplacement(main(initialTab: tab));
  }
}
