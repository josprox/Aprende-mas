import 'package:aprende_mas/views/grades_screen.dart';
import 'package:aprende_mas/views/settings/settings_screen.dart';
import 'package:aprende_mas/views/subject_list_screen.dart';
import 'package:aprende_mas/views/test_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

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
    const GradesScreen(),
    const SettingsScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
            rippleColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            hoverColor: Theme.of(context).colorScheme.surfaceContainer,
            gap: 8,
            activeColor: Theme.of(context).colorScheme.primary,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
            color: Theme.of(context).iconTheme.color,
            tabs: const [
              GButton(icon: LineIcons.book, text: 'Aprende'),
              GButton(icon: LineIcons.graduationCap, text: 'Test'),
              GButton(icon: LineIcons.checkCircle, text: 'Notas'),
              GButton(icon: LineIcons.cog, text: 'Ajustes'),
            ],
            selectedIndex: _currentIndex,
            onTabChange: (index) {
              setState(() {
                _currentIndex = index;
              });
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutQuad,
              );
            },
          ),
        ),
      ),
    );
  }
}
