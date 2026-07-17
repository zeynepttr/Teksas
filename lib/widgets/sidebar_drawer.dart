import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/firebase_service.dart';
import '../screens/login_screen.dart';
import '../screens/doctor_booking_screen.dart';
import '../screens/directory_screen.dart';

class SidebarDrawer extends StatelessWidget {
  final Function(int)? onNavigateToTab;

  const SidebarDrawer({
    Key? key,
    this.onNavigateToTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    final user = firebaseService.currentUser;

    return Drawer(
      child: Column(
        children: [
          // Header
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.surfaceLight,
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'H',
                style: const TextStyle(
                  fontFamily: 'DINPro',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ),
            accountName: Text(
              user?.fullName ?? 'Misafir Kullanıcı',
              style: const TextStyle(
                fontFamily: 'DINPro',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            accountEmail: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    fontFamily: 'DINPro',
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                // Role Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: user?.isAdmin == true ? AppColors.error.withOpacity(0.3) : AppColors.buttonDark.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: user?.isAdmin == true ? AppColors.error : AppColors.buttonDark,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    user?.role ?? '',
                    style: TextStyle(
                      color: user?.isAdmin == true ? AppColors.error : AppColors.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Doktorum Nerede
                ListTile(
                  leading: const Icon(Icons.local_hospital, color: AppColors.accent),
                  title: const Text(
                    "Doktorum Nerede",
                    style: TextStyle(
                      fontFamily: 'DINPro',
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: const Text(
                    "AI Triage ve Randevu Planlama",
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DoctorBookingScreen(),
                      ),
                    );
                  },
                ),
                
                // Rehber
                ListTile(
                  leading: const Icon(Icons.contact_phone, color: AppColors.accent),
                  title: const Text(
                    "Kurumsal Rehber",
                    style: TextStyle(
                      fontFamily: 'DINPro',
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: const Text(
                    "Hane İletişim Rehberi",
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DirectoryScreen(),
                      ),
                    );
                  },
                ),
                
                const Divider(color: AppColors.surfaceLight),
                
                // Profil (opens profile tab)
                ListTile(
                  leading: const Icon(Icons.person, color: AppColors.textSecondary),
                  title: const Text(
                    "Profilim",
                    style: TextStyle(
                      fontFamily: 'DINPro',
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    if (onNavigateToTab != null) {
                      onNavigateToTab!(3); // MainScreen has Profile at index 3
                    }
                  },
                ),
              ],
            ),
          ),

          // Footer / Logout
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.bottomCenter,
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text(
                "Çıkış Yap",
                style: TextStyle(
                  fontFamily: 'DINPro',
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              onTap: () async {
                await firebaseService.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
