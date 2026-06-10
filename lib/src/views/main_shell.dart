import 'package:flutter/material.dart';

import '../widgets/home/home_bottom_nav.dart';
import 'about_screen.dart';
import 'home_screen.dart';
import 'news_screen.dart';
import 'tournaments_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = HomeTab.home});

  final HomeTab initialTab;

  static MainShellState? of(BuildContext context) {
    return context.findAncestorStateOfType<MainShellState>();
  }

  static void selectTab(BuildContext context, HomeTab tab) {
    of(context)?.selectTab(tab);
  }

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  late HomeTab _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  void selectTab(HomeTab tab) {
    if (_currentTab == tab) return;
    setState(() => _currentTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentTab.index,
        children: const [
          HomeScreen(),
          TournamentsScreen(),
          NewsScreen(),
          AboutScreen(),
        ],
      ),
      bottomNavigationBar: HomeBottomNav(
        currentTab: _currentTab,
        onTabSelected: selectTab,
      ),
    );
  }
}
