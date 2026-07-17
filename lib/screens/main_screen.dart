import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/sidebar_drawer.dart';
import 'timeline_page.dart';
import 'privileges_page.dart';
import 'profile_page.dart';

class MainScreen extends StatefulWidget {
  final int initialTab;
  const MainScreen({Key? key, this.initialTab = 0}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  // Lists out our three core pages
  final List<Widget> _pages = [
    const TimelinePage(),
    const PrivilegesPage(),
    const ProfilePage(),
  ];

  final List<String> _titles = [
    "Hane Timeline",
    "Ayrıcalıklar",
    "Profilim",
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            fontFamily: 'DINPro',
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          // Display a notification icon that points to Profile if they click it, or does nothing for aesthetics
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              setState(() {
                _currentIndex = 2; // Jump to profile page where admin panel is
              });
            },
          ),
        ],
      ),
      drawer: SidebarDrawer(
        onNavigateToTab: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.surfaceLight, width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard, color: AppColors.accent),
              label: "Akış",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_outline),
              activeIcon: Icon(Icons.star, color: AppColors.accent),
              label: "Ayrıcalıklar",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person, color: AppColors.accent),
              label: "Profil",
            ),
          ],
        ),
      ),
    );
  }
}
