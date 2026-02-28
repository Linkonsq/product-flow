import 'package:flutter/material.dart';

import '../account/account_view.dart';
import '../landing/landing_view.dart';

/// Main shell with bottom navigation: Home (landing) and Account (login).
class MainShellView extends StatefulWidget {
  const MainShellView({super.key});

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView> {
  int _currentIndex = 0;

  static const List<_NavItem> _navItems = [
    _NavItem(label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home),
    _NavItem(
      label: 'Account',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          LandingView(),
          AccountView(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: [
          for (int i = 0; i < _navItems.length; i++)
            NavigationDestination(
              icon: Icon(_navItems[i].icon),
              selectedIcon: Icon(_navItems[i].activeIcon),
              label: _navItems[i].label,
            ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
