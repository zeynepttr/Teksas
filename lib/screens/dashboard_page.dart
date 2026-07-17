import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/firebase_service.dart';
import 'marketplace_screen.dart';
import 'doctor_booking_screen.dart';
import 'directory_screen.dart';

class DashboardPage extends StatefulWidget {
  final Function(int) onNavigateToTab;

  const DashboardPage({
    Key? key,
    required this.onNavigateToTab,
  }) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirebaseService _firebaseService = FirebaseService();
  int _carouselIndex = 0;

  final List<Map<String, String>> _carouselItems = [
    {
      "title": "Kozmetik Alışverişinde\n300 TL Ek İndirim!",
      "desc": "Seçili kozmetik markalarında 600 TL üzeri alışverişlerinizde geçerlidir.",
      "image": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?q=80&w=300&auto=format&fit=crop"
    },
    {
      "title": "Aramızda İkinci El Pazarı\nYayında! 🚗📱",
      "desc": "Kullanmadığınız eşyaları çalışma arkadaşlarınıza satın veya uygun fiyatlı ilanları inceleyin.",
      "image": "https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?q=80&w=300&auto=format&fit=crop"
    },
    {
      "title": "Hane Sağlık & Esenlik\nAI Asistanı Aktif! 🩺🧠",
      "desc": "Şikayetlerinizi asistanımıza yazın, sizi doğru hekime veya psikoloğa yönlendirsin.",
      "image": "https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?q=80&w=300&auto=format&fit=crop"
    }
  ];

  @override
  Widget build(BuildContext context) {
    final user = _firebaseService.currentUser;
    final name = user?.name ?? "Kullanıcı";

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Let gradient show through
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Logo Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Logo with elegant font style
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.darkGreen,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Hane",
                          style: TextStyle(
                            fontFamily: 'DINPro',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    // Action Icons
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.qr_code_scanner, color: AppColors.textSecondary, size: 24),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("QR Kod Okuyucu başlatılıyor...", style: TextStyle(fontFamily: 'DINPro')),
                                backgroundColor: AppColors.darkGreen,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_none_outlined, color: AppColors.textSecondary, size: 26),
                              onPressed: () {
                                widget.onNavigateToTab(3); // Navigate to Profile tab where admin panel is
                              },
                            ),
                            // Red indicator for admins
                            if (user?.isAdmin == true)
                              Positioned(
                                right: 12,
                                top: 12,
                                child: CircleAvatar(
                                  radius: 5,
                                  backgroundColor: AppColors.error,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 2. Welcome & Avatar Section
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.buttonLight,
                      child: Text(
                        name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'DINPro',
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "İyi Günler, $name!",
                      style: const TextStyle(
                        fontFamily: 'DINPro',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 3. Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: TextField(
                    readOnly: true,
                    onTap: () {
                      // Navigate to Directory or Search
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DirectoryScreen()),
                      );
                    },
                    decoration: InputDecoration(
                      hintText: "Hane'de ara...",
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: AppColors.darkGreen, size: 22),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.surfaceLight, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.surfaceLight, width: 1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 4. "SANA ÖZEL" Section Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.surfaceLight, thickness: 1)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "SANA ÖZEL",
                        style: TextStyle(
                          fontFamily: 'DINPro',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.surfaceLight, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 16),

                // 5. Banners Horizontal Carousel Slider
                _buildBannerSlider(),
                const SizedBox(height: 28),

                // 6. Wide Card: Ayrıcalıklar (Banners Style)
                _buildWideCard(
                  title: "Ayrıcalıklar",
                  subtitle: "Anlaşmalı indirimler & hediye kodları",
                  imageUrl: "https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=600&auto=format&fit=crop",
                  onTap: () {
                    widget.onNavigateToTab(1); // Navigates to tab 1 (Ayrıcalıklar)
                  },
                ),
                const SizedBox(height: 16),

                // 7. Grid section for other cards (Aramızda, Doktorum Nerede, Rehber, Kanka)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.15,
                  children: [
                    _buildGridCard(
                      title: "Aramızda",
                      subtitle: "İkinci el pazarı",
                      icon: Icons.handshake_outlined,
                      imageUrl: "https://images.unsplash.com/photo-1516259762381-22954d7d3ad2?q=80&w=300&auto=format&fit=crop",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MarketplaceScreen()),
                        );
                      },
                    ),
                    _buildGridCard(
                      title: "Doktorum Nerede",
                      subtitle: "AI Wellness Triage",
                      icon: Icons.psychology_outlined,
                      imageUrl: "https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=300&auto=format&fit=crop",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DoctorBookingScreen()),
                        );
                      },
                    ),
                    _buildGridCard(
                      title: "Rehber",
                      subtitle: "Kurumsal iletişim",
                      icon: Icons.contact_phone_outlined,
                      imageUrl: "https://images.unsplash.com/photo-1423666639041-f56000c27a9a?q=80&w=300&auto=format&fit=crop",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DirectoryScreen()),
                        );
                      },
                    ),
                    _buildGridCard(
                      title: "Kanka",
                      subtitle: "Acil kan talebi",
                      icon: Icons.favorite_border,
                      imageUrl: "https://images.unsplash.com/photo-1615461066841-4a10de78f9a8?q=80&w=300&auto=format&fit=crop",
                      onTap: () {
                        _showKankaDialog(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSlider() {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            itemCount: _carouselItems.length,
            onPageChanged: (idx) {
              setState(() {
                _carouselIndex = idx;
              });
            },
            itemBuilder: (context, index) {
              final item = _carouselItems[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00ACC1), Color(0xFF007A87)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF007A87).withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Text elements
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['title']!,
                            style: const TextStyle(
                              fontFamily: 'DINPro',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Text(
                              item['desc']!,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Oval image display on the right
                    Positioned(
                      right: -10,
                      top: -10,
                      bottom: -10,
                      child: Center(
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: const BoxDecoration(
                            color: Colors.white10,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(item['image']!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_carouselItems.length, (index) {
            final isSelected = _carouselIndex == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isSelected ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.darkGreen : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildWideCard({
    required String title,
    required String subtitle,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            // Dark gradient overlay for text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.1),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            // Text Details
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'DINPro',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Image with soft opacity
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            // Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.65),
                      Colors.black.withOpacity(0.2),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(icon, color: AppColors.accent, size: 24),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'DINPro',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showKankaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.favorite, color: AppColors.error),
              const SizedBox(width: 8),
              const Text("Hane Kanka", style: TextStyle(fontFamily: 'DINPro', fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            "Anca beraber, kanca beraber! Çok yakında aktif kan bağışı ve acil kan ihtiyaçlarınızı koordine edebileceğiniz portalımız yayında olacaktır. Desteğiniz için teşekkürler!",
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tamam", style: TextStyle(fontFamily: 'DINPro', color: AppColors.accent, fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }
}
