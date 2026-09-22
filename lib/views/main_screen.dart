import 'dart:async';

import 'package:aprende_mas/services/update_service.dart';
import 'package:aprende_mas/views/force_update_screen.dart';
import 'package:aprende_mas/views/code_runner_screen.dart';
import 'package:aprende_mas/views/grades_screen.dart';
import 'package:aprende_mas/views/settings/settings_screen.dart';
import 'package:aprende_mas/views/subject_list_screen.dart';
import 'package:aprende_mas/views/test_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const SubjectListScreen(),
    const TestListScreen(),
    const CodeRunnerScreen(),
    const GradesScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    unawaited(_checkAppUpdate());
  }

  Future<void> _checkAppUpdate() async {
    final updateInfo = await UpdateService.checkForUpdate();
    if (updateInfo != null && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => ForceUpdateScreen(updateInfo: updateInfo),
        ),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavigationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 640;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _onNavigationSelected,
                  labelType: NavigationRailLabelType.all,
                  groupAlignment: -0.85,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Icon(
                      Icons.school_rounded,
                      size: 32,
                      color: scheme.primary,
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.auto_stories_outlined),
                      selectedIcon: Icon(Icons.auto_stories),
                      label: Text('Aprende'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.quiz_outlined),
                      selectedIcon: Icon(Icons.quiz),
                      label: Text('Tests'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.terminal_outlined),
                      selectedIcon: Icon(Icons.terminal_rounded),
                      label: Text('Código'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.insights_outlined),
                      selectedIcon: Icon(Icons.insights),
                      label: Text('Notas'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.tune_outlined),
                      selectedIcon: Icon(Icons.tune),
                      label: Text('Ajustes'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    children: _screens,
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: _screens,
          ),
          bottomNavigationBar: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainer.withValues(alpha: 0.94),
              border: Border(top: BorderSide(color: scheme.outlineVariant)),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onNavigationSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.auto_stories_outlined),
                  selectedIcon: Icon(Icons.auto_stories),
                  label: 'Aprende',
                ),
                NavigationDestination(
                  icon: Icon(Icons.quiz_outlined),
                  selectedIcon: Icon(Icons.quiz),
                  label: 'Tests',
                ),
                NavigationDestination(
                  icon: Icon(Icons.terminal_outlined),
                  selectedIcon: Icon(Icons.terminal_rounded),
                  label: 'Código',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights),
                  label: 'Notas',
                ),
                NavigationDestination(
                  icon: Icon(Icons.tune_outlined),
                  selectedIcon: Icon(Icons.tune),
                  label: 'Ajustes',
                ),
              ],
            ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.12, end: 0),
          ),
        );
      },
    );
  }
}
