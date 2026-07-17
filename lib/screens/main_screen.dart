import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/sidebar_drawer.dart';
import 'dashboard_page.dart';
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
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _pages = [
      DashboardPage(onNavigateToTab: _onTabTapped),
      const PrivilegesPage(),
      const TimelinePage(),
      const ProfilePage(),
    ];
  }

  final List<String> _titles = [
    "Hane Ana Sayfa",
    "Ayrıcalıklar",
    "Hane Akış",
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
      appBar: _currentIndex == 0 
          ? null // Hide appbar on dashboard as it has its own custom header
          : AppBar(
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
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {
                    setState(() {
                      _currentIndex = 3; // Jump to profile page where admin panel is
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
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home, color: AppColors.accent),
              label: "Ana Sayfa",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_outline),
              activeIcon: Icon(Icons.star, color: AppColors.accent),
              label: "Ayrıcalıklar",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.campaign_outlined),
              activeIcon: Icon(Icons.campaign, color: AppColors.accent),
              label: "Akış",
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
