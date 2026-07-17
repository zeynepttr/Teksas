import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/announcement_model.dart';
import '../models/user_model.dart';
import '../models/payroll_model.dart';
import '../models/leave_request_model.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  int _currentIndex = 0;
  int _crmViewIndex = 0; // 0: List, 1: Reporting & Analytics
  List<AnnouncementModel> _pendingRequests = [];
  bool _isLoadingRequests = false;

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
    _firebaseService.getPayrolls();
    _firebaseService.getLeaveRequests();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadPendingRequests() async {
    setState(() {
      _isLoadingRequests = true;
    });
    try {
      final requests = await _firebaseService.getPendingAnnouncementRequests();
      setState(() {
        _pendingRequests = requests;
      });
    } catch (e) {
      debugPrint("Error loading pending requests: $e");
    } finally {
      setState(() {
        _isLoadingRequests = false;
      });
    }
  }

  Future<void> _handleApprove(String id) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Talep onaylanıyor...", style: TextStyle(fontFamily: 'DINPro')),
        duration: Duration(milliseconds: 500),
      ),
    );
    await _firebaseService.approveAnnouncement(id);
    await _loadPendingRequests();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Paylaşım onaylandı ve akışa eklendi.", style: TextStyle(fontFamily: 'DINPro')),
          backgroundColor: AppColors.buttonDark,
        ),
      );
    }
  }

  Future<void> _handleReject(String id) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Talep reddediliyor...", style: TextStyle(fontFamily: 'DINPro')),
        duration: Duration(milliseconds: 500),
      ),
    );
    await _firebaseService.rejectAnnouncement(id);
    await _loadPendingRequests();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Paylaşım talebi reddedildi.", style: TextStyle(fontFamily: 'DINPro')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 900;

    if (isWideScreen) {
      return Scaffold(
        body: Row(
          children: [
            _buildWebSidebar(),
            Expanded(
              child: Column(
                children: [
                  _buildSectionHeader(_getSectionTitle(_currentIndex)),
                  Expanded(
                    child: IndexedStack(
                      index: _currentIndex,
                      children: [
                        _buildPendingTab(),
                        _buildCrmTab(),
                        _buildPayrollsTab(),
                        _buildLeaveRequestsTab(),
                        _buildLogsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "İK Yönetici Paneli",
          style: TextStyle(fontFamily: 'DINPro', fontWeight: FontWeight.bold),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildPendingTab(),
          _buildCrmTab(),
          _buildPayrollsTab(),
          _buildLeaveRequestsTab(),
          _buildLogsTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(fontFamily: 'DINPro', fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontFamily: 'DINPro', fontSize: 10),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.rate_review_outlined),
              activeIcon: Icon(Icons.rate_review),
              label: "Onaylar",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: "CRM",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: "Bordrolar",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.time_to_leave_outlined),
              activeIcon: Icon(Icons.time_to_leave),
              label: "İzinler",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_toggle_off_outlined),
              activeIcon: Icon(Icons.history_toggle_off),
              label: "Loglar",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebSidebar() {
    final List<Map<String, dynamic>> menuItems = [
      {
        "icon": Icons.rate_review_outlined,
        "activeIcon": Icons.rate_review,
        "label": "Paylaşım Onayları",
      },
      {
        "icon": Icons.people_outline,
        "activeIcon": Icons.people,
        "label": "CRM / Çalışanlar",
      },
      {
        "icon": Icons.receipt_long_outlined,
        "activeIcon": Icons.receipt_long,
        "label": "Bordro Yönetimi",
      },
      {
        "icon": Icons.time_to_leave_outlined,
        "activeIcon": Icons.time_to_leave,
        "label": "İzin Talepleri",
      },
      {
        "icon": Icons.history_toggle_off_outlined,
        "activeIcon": Icons.history_toggle_off,
        "label": "Sistem Logları",
      },
    ];

    return Container(
      width: 260,
      color: AppColors.buttonDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/logo2.png',
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 44,
                        height: 44,
                        color: Colors.white.withOpacity(0.1),
                        child: const Icon(Icons.admin_panel_settings, color: Colors.white),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hane",
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "İK YÖNETİCİ PANELİ",
                      style: TextStyle(
                        fontFamily: 'DINPro',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.08),
            margin: const EdgeInsets.only(bottom: 20),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final bool isSelected = _currentIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? item["activeIcon"] as IconData : item["icon"] as IconData,
                            color: isSelected ? Colors.white : Colors.white60,
                            size: 20,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            item["label"] as String,
                            style: TextStyle(
                              fontFamily: 'DINPro',
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, color: Colors.white, size: 16),
                    const SizedBox(width: 10),
                    Text(
                      "Paneli Kapat",
                      style: TextStyle(
                        fontFamily: 'DINPro',
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.surfaceLight, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'DINPro',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.buttonLight,
                child: Text(
                  "Z",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _firebaseService.currentUser?.name ?? "İK Yönetici",
                style: const TextStyle(
                  fontFamily: 'DINPro',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSectionTitle(int index) {
    switch (index) {
      case 0:
        return "Paylaşım Onayları";
      case 1:
        return "CRM / Çalışanlar";
      case 2:
        return "Bordro Yönetimi";
      case 3:
        return "İzin Talepleri";
      case 4:
        return "Sistem Logları";
      default:
        return "İK Yönetim Paneli";
    }
  }

  Widget _buildPendingTab() {
    if (_isLoadingRequests) {
      return const Center(child: CircularProgressIndicator(color: AppColors.buttonDark));
    }

    if (_pendingRequests.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadPendingRequests,
        color: AppColors.buttonDark,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, color: AppColors.textMuted, size: 64),
                  SizedBox(height: 16),
                  Text(
                    "Onay bekleyen paylaşım bulunmuyor.",
                    style: TextStyle(
                      fontFamily: 'DINPro',
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Yeni talepleri kontrol etmek için aşağı çekin.",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPendingRequests,
      color: AppColors.buttonDark,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingRequests.length,
        itemBuilder: (context, index) {
          final request = _pendingRequests[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Author & Type badge)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.surfaceLight,
                            radius: 18,
                            child: Text(
                              request.author.substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request.author,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const Text(
                                "Paylaşım Talebi",
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              )
                            ],
                          ),
                        ],
                      ),
                      _buildTypeBadge(request.type),
                    ],
                  ),
                ),

                // Image if available
                if (request.imageUrl != null)
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(request.imageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.title,
                        style: const TextStyle(
                          fontFamily: 'DINPro',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        request.description,
                        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                      ),
                      if (request.date != null || request.location != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              if (request.date != null)
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 14, color: AppColors.accent),
                                    const SizedBox(width: 8),
                                    Text(request.date!, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                                  ],
                                ),
                              if (request.date != null && request.location != null) const SizedBox(height: 8),
                              if (request.location != null)
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.accent),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        request.location!,
                                        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const Divider(height: 1, color: AppColors.surfaceLight),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: "Reddet",
                          type: CustomButtonType.secondary,
                          height: 40,
                          onPressed: () => _handleReject(request.id),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: "Onayla",
                          height: 40,
                          onPressed: () => _handleApprove(request.id),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogsTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firebaseService.notificationsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.buttonDark));
        }

        final logs = snapshot.data ?? [];

        if (logs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_toggle_off, color: AppColors.textMuted, size: 64),
                SizedBox(height: 16),
                Text(
                  "Sistem güncelleme logu bulunmuyor.",
                  style: TextStyle(
                    fontFamily: 'DINPro',
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            final DateTime dt = DateTime.fromMillisecondsSinceEpoch(log['timestamp'] ?? DateTime.now().millisecondsSinceEpoch);
            final timeString = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} - ${dt.day}/${dt.month}/${dt.year}";
            
            final isProfileUpdate = log['type'] == 'profile_update';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isProfileUpdate ? Icons.manage_accounts : Icons.notification_important,
                              color: isProfileUpdate ? AppColors.accent : AppColors.warning,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              log['title'] ?? 'Bildirim',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                          onPressed: () => _firebaseService.clearAdminNotification(log['id']),
                        )
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      log['message'] ?? '',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          timeString,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                        if (isProfileUpdate)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "Profil Düzenleme",
                              style: TextStyle(fontSize: 9, color: AppColors.accent, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCrmTab() {
    final employees = _firebaseService.getAllEmployees();

    return Column(
      children: [
        // View Toggle Segment
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.surfaceLight, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _crmViewIndex = 0;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _crmViewIndex == 0 ? AppColors.buttonDark : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Çalışan Listesi",
                              style: TextStyle(
                                fontFamily: 'DINPro',
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: _crmViewIndex == 0 ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _crmViewIndex = 1;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _crmViewIndex == 1 ? AppColors.buttonDark : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.analytics_outlined,
                                  size: 14,
                                  color: _crmViewIndex == 1 ? Colors.white : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Raporlama & Analiz",
                                  style: TextStyle(
                                    fontFamily: 'DINPro',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: _crmViewIndex == 1 ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Body Switcher
        Expanded(
          child: _crmViewIndex == 0 
            ? _buildCrmListSection(employees)
            : _buildCrmAnalyticsSection(employees),
        ),
      ],
    );
  }

  Widget _buildCrmListSection(List<UserModel> employees) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 900;
    
    return Column(
      children: [
        // CRM Stats Card
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Toplam Çalışan Sayısı",
                    style: TextStyle(fontFamily: 'DINPro', color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${employees.length} Kişi",
                    style: const TextStyle(fontFamily: 'DINPro', color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.darkGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.person_add),
                label: const Text("Yeni Çalışan", style: TextStyle(fontFamily: 'DINPro', fontWeight: FontWeight.bold)),
                onPressed: () => _showAddEmployeeDialog(),
              ),
            ],
          ),
        ),

        Expanded(
          child: employees.isEmpty
              ? const Center(child: Text("Sistemde kayıtlı çalışan bulunmamaktadır.", style: TextStyle(color: AppColors.textSecondary)))
              : isWideScreen
                  ? GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 350,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.8,
                      ),
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        final emp = employees[index];
                        return Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.surfaceLight,
                                      child: Text(
                                        emp.name.isNotEmpty ? emp.name.substring(0, 1).toUpperCase() : 'Ç',
                                        style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            emp.fullName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 15),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            emp.role,
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: AppColors.accent, size: 18),
                                      onPressed: () => _showEditEmployeeDialog(emp),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    const Icon(Icons.phone, size: 14, color: AppColors.textMuted),
                                    const SizedBox(width: 6),
                                    Text(emp.phone, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.email, size: 14, color: AppColors.textMuted),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        emp.email,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        final emp = employees[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.surfaceLight,
                              child: Text(
                                emp.name.isNotEmpty ? emp.name.substring(0, 1).toUpperCase() : 'Ç',
                                style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(emp.fullName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            subtitle: Text("${emp.role}\n📞 ${emp.phone}", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.edit, color: AppColors.accent),
                              onPressed: () => _showEditEmployeeDialog(emp),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildCrmAnalyticsSection(List<UserModel> employees) {
    if (employees.isEmpty) {
      return const Center(child: Text("Analiz edilecek çalışan bulunmamaktadır.", style: TextStyle(color: AppColors.textSecondary)));
    }

    // 1. Calculate statistics
    double totalAge = 0;
    final Map<String, int> deptCounts = {};
    final Map<String, int> bloodCounts = {};
    final Map<String, int> roleCounts = {};

    for (var emp in employees) {
      totalAge += emp.age;
      
      final dept = emp.department.trim().isEmpty ? "Saha Operasyonları" : emp.department.trim();
      deptCounts[dept] = (deptCounts[dept] ?? 0) + 1;

      final blood = emp.bloodGroup.trim().toUpperCase().isEmpty ? "A RH+" : emp.bloodGroup.trim().toUpperCase();
      bloodCounts[blood] = (bloodCounts[blood] ?? 0) + 1;

      final role = emp.role.trim().isEmpty ? "İHH Çalışanı" : emp.role.trim();
      roleCounts[role] = (roleCounts[role] ?? 0) + 1;
    }

    final double avgAge = totalAge / employees.length;

    // Find largest department
    String largestDept = "Belirsiz";
    int maxDeptCount = 0;
    deptCounts.forEach((key, val) {
      if (val > maxDeptCount) {
        maxDeptCount = val;
        largestDept = key;
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row of Metric Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final double cardWidth = (constraints.maxWidth - 24) / 2; // fits 2 in a row on mobile
              final bool isWide = constraints.maxWidth > 600;
              
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildMetricCard("Toplam Kadro", "${employees.length} Kişi", Icons.people, AppColors.accent, isWide ? 180 : cardWidth),
                  _buildMetricCard("Yaş Ortalaması", avgAge.toStringAsFixed(1), Icons.cake, Colors.orange, isWide ? 180 : cardWidth),
                  _buildMetricCard("Merkez Birim", largestDept, Icons.business, Colors.blue, isWide ? 220 : double.infinity),
                  _buildMetricCard("Kadro Durumu", "Aktif Çalışıyor", Icons.check_circle, Colors.teal, isWide ? 170 : cardWidth),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Department Distribution Chart (Horizontal Bars)
          _buildChartContainer(
            "Birim / Departman Dağılımı",
            Column(
              children: deptCounts.entries.map((entry) {
                final double percent = entry.value / employees.length;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                          Text("${entry.value} Çalışan (${(percent * 100).toStringAsFixed(0)}%)", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: percent,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Emergency Blood Type Counts
          _buildChartContainer(
            "Acil Durum Kan Grubu Havuzu",
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: bloodCounts.entries.map((entry) {
                return Container(
                  width: 90,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceLight),
                  ),
                  child: Column(
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontFamily: 'DINPro',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${entry.value} Kişi",
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'DINPro',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContainer(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'DINPro',
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  void _showAddEmployeeDialog() {
    final nameCtrl = TextEditingController();
    final surnameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final bloodCtrl = TextEditingController();
    final extCtrl = TextEditingController(text: (1000 + (DateTime.now().millisecond % 9000)).toString());
    final codeCtrl = TextEditingController(text: "IHH-${100 + (DateTime.now().millisecond % 900)}");
    final deptCtrl = TextEditingController(text: "Saha Operasyonları");
    String selectedRole = 'İHH Çalışanı';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Yeni Çalışan Ekle", style: TextStyle(fontFamily: 'DINPro', fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextField(controller: nameCtrl, labelText: "Adı", hintText: "Adı"),
                      const SizedBox(height: 12),
                      CustomTextField(controller: surnameCtrl, labelText: "Soyadı", hintText: "Soyadı"),
                      const SizedBox(height: 12),
                      CustomTextField(controller: emailCtrl, labelText: "E-posta", hintText: "E-posta", keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 12),
                      CustomTextField(controller: phoneCtrl, labelText: "Telefon", hintText: "Telefon", keyboardType: TextInputType.phone),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: CustomTextField(controller: ageCtrl, labelText: "Yaş", hintText: "Yaş", keyboardType: TextInputType.number)),
                          const SizedBox(width: 12),
                          Expanded(child: CustomTextField(controller: bloodCtrl, labelText: "Kan Grubu", hintText: "Kan Grubu")),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: CustomTextField(controller: codeCtrl, labelText: "Sicil Kodu", hintText: "Örn: IHH-104")),
                          const SizedBox(width: 12),
                          Expanded(child: CustomTextField(controller: extCtrl, labelText: "Dahili No", hintText: "Örn: 1004")),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(controller: deptCtrl, labelText: "Birim / Departman", hintText: "Örn: Saha Operasyonları"),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(
                          labelText: "Görev / Rol",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'İHH Çalışanı', child: Text('İHH Çalışanı')),
                          DropdownMenuItem(value: 'Destek Personeli', child: Text('Destek Personeli')),
                          DropdownMenuItem(value: 'Saha Gönüllüsü', child: Text('Saha Gönüllüsü')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedRole = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("İptal", style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonDark),
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty || surnameCtrl.text.isEmpty || emailCtrl.text.isEmpty) return;
                    final newEmp = UserModel(
                      uid: "uid_" + const Uuid().v4().substring(0, 8),
                      name: nameCtrl.text.trim(),
                      surname: surnameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      bloodGroup: bloodCtrl.text.trim(),
                      age: int.tryParse(ageCtrl.text.trim()) ?? 30,
                      role: selectedRole,
                      joinTimestamp: DateTime.now().millisecondsSinceEpoch,
                      extension: extCtrl.text.trim().isEmpty ? "1000" : extCtrl.text.trim(),
                      employeeCode: codeCtrl.text.trim().isEmpty ? "IHH-100" : codeCtrl.text.trim(),
                      department: deptCtrl.text.trim().isEmpty ? "Saha Operasyonları" : deptCtrl.text.trim(),
                    );
                    await _firebaseService.addEmployee(newEmp);
                    if (context.mounted) {
                      Navigator.pop(context);
                      setState(() {});
                    }
                  },
                  child: const Text("Ekle", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditEmployeeDialog(UserModel emp) {
    final nameCtrl = TextEditingController(text: emp.name);
    final surnameCtrl = TextEditingController(text: emp.surname);
    final emailCtrl = TextEditingController(text: emp.email);
    final phoneCtrl = TextEditingController(text: emp.phone);
    final ageCtrl = TextEditingController(text: emp.age.toString());
    final bloodCtrl = TextEditingController(text: emp.bloodGroup);
    final extCtrl = TextEditingController(text: emp.extension);
    final codeCtrl = TextEditingController(text: emp.employeeCode);
    final deptCtrl = TextEditingController(text: emp.department);
    String selectedRole = emp.role;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Çalışan Bilgilerini Düzenle", style: TextStyle(fontFamily: 'DINPro', fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextField(controller: nameCtrl, labelText: "Adı", hintText: "Adı"),
                      const SizedBox(height: 12),
                      CustomTextField(controller: surnameCtrl, labelText: "Soyadı", hintText: "Soyadı"),
                      const SizedBox(height: 12),
                      CustomTextField(controller: emailCtrl, labelText: "E-posta", hintText: "E-posta", keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 12),
                      CustomTextField(controller: phoneCtrl, labelText: "Telefon", hintText: "Telefon", keyboardType: TextInputType.phone),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: CustomTextField(controller: ageCtrl, labelText: "Yaş", hintText: "Yaş", keyboardType: TextInputType.number)),
                          const SizedBox(width: 12),
                          Expanded(child: CustomTextField(controller: bloodCtrl, labelText: "Kan Grubu", hintText: "Kan Grubu")),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: CustomTextField(controller: codeCtrl, labelText: "Sicil Kodu", hintText: "Örn: IHH-104")),
                          const SizedBox(width: 12),
                          Expanded(child: CustomTextField(controller: extCtrl, labelText: "Dahili No", hintText: "Örn: 1004")),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(controller: deptCtrl, labelText: "Birim / Departman", hintText: "Örn: Saha Operasyonları"),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(
                          labelText: "Görev / Rol",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'İHH Çalışanı', child: Text('İHH Çalışanı')),
                          DropdownMenuItem(value: 'Destek Personeli', child: Text('Destek Personeli')),
                          DropdownMenuItem(value: 'Saha Gönüllüsü', child: Text('Saha Gönüllüsü')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedRole = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("İptal", style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonDark),
                  onPressed: () async {
                    final updatedEmp = emp.copyWith(
                      name: nameCtrl.text.trim(),
                      surname: surnameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      bloodGroup: bloodCtrl.text.trim(),
                      age: int.tryParse(ageCtrl.text.trim()) ?? emp.age,
                      role: selectedRole,
                      extension: extCtrl.text.trim(),
                      employeeCode: codeCtrl.text.trim(),
                      department: deptCtrl.text.trim(),
                    );
                    await _firebaseService.updateEmployee(updatedEmp);
                    if (context.mounted) {
                      Navigator.pop(context);
                      setState(() {});
                    }
                  },
                  child: const Text("Güncelle", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPayrollsTab() {
    final employees = _firebaseService.getAllEmployees();

    return StreamBuilder<List<PayrollModel>>(
      stream: _firebaseService.adminPayrollsStream,
      initialData: _firebaseService.getAllPayrolls(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.buttonDark));
        }

        final payrolls = snapshot.data ?? [];

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tüm Maaş Bordroları",
                    style: TextStyle(fontFamily: 'DINPro', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text("Bordro Oluştur", style: TextStyle(fontFamily: 'DINPro', fontWeight: FontWeight.bold)),
                    onPressed: employees.isEmpty
                        ? null
                        : () => _showAddPayrollDialog(employees),
                  ),
                ],
              ),
            ),

            Expanded(
              child: payrolls.isEmpty
                  ? const Center(child: Text("Kayıtlı bordro bulunmamaktadır.", style: TextStyle(color: AppColors.textSecondary)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: payrolls.length,
                      itemBuilder: (context, index) {
                        final pay = payrolls[index];
                        final double totalPaid = pay.netSalary + pay.allowances - pay.deductions;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      pay.userName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.darkGreen.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "${pay.month} ${pay.year}",
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accent),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Net Maaş", style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                        Text("${pay.netSalary.toStringAsFixed(0)} TL", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Sosyal Yardım/Ek", style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                        Text("+${pay.allowances.toStringAsFixed(0)} TL", style: const TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Kesintiler", style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                        Text("-${pay.deductions.toStringAsFixed(0)} TL", style: const TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Toplam Yatırılan Tutar",
                                      style: TextStyle(fontFamily: 'DINPro', fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                    ),
                                    Text(
                                      "${totalPaid.toStringAsFixed(0)} TL",
                                      style: const TextStyle(fontFamily: 'DINPro', fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.darkGreen),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showAddPayrollDialog(List<UserModel> employees) {
    UserModel selectedEmp = employees.first;
    final monthCtrl = TextEditingController(text: "Ağustos");
    final yearCtrl = TextEditingController(text: "2026");
    final netSalaryCtrl = TextEditingController(text: "40000");
    final allowancesCtrl = TextEditingController(text: "3000");
    final deductionsCtrl = TextEditingController(text: "1500");

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Yeni Maaş Bordrosu Oluştur", style: TextStyle(fontFamily: 'DINPro', fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<UserModel>(
                        value: selectedEmp,
                        decoration: const InputDecoration(
                          labelText: "Çalışan Seçin",
                          border: OutlineInputBorder(),
                        ),
                        items: employees.map((e) {
                          return DropdownMenuItem<UserModel>(
                            value: e,
                            child: Text(e.fullName),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedEmp = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: CustomTextField(controller: monthCtrl, labelText: "Ay", hintText: "Örn: Ağustos")),
                          const SizedBox(width: 12),
                          Expanded(child: CustomTextField(controller: yearCtrl, labelText: "Yıl", hintText: "Örn: 2026", keyboardType: TextInputType.number)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(controller: netSalaryCtrl, labelText: "Net Maaş (TL)", hintText: "Net Maaş", keyboardType: TextInputType.number),
                      const SizedBox(height: 12),
                      CustomTextField(controller: allowancesCtrl, labelText: "Sosyal Yardım / Prim (TL)", hintText: "Sosyal Yardım", keyboardType: TextInputType.number),
                      const SizedBox(height: 12),
                      CustomTextField(controller: deductionsCtrl, labelText: "Vergi / Diğer Kesintiler (TL)", hintText: "Kesintiler", keyboardType: TextInputType.number),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("İptal", style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonDark),
                  onPressed: () async {
                    final netSalary = double.tryParse(netSalaryCtrl.text.trim()) ?? 0.0;
                    final allowances = double.tryParse(allowancesCtrl.text.trim()) ?? 0.0;
                    final deductions = double.tryParse(deductionsCtrl.text.trim()) ?? 0.0;
                    final year = int.tryParse(yearCtrl.text.trim()) ?? 2026;

                    final newPayroll = PayrollModel(
                      id: "pay_" + const Uuid().v4().substring(0, 8),
                      userId: selectedEmp.uid,
                      userName: selectedEmp.fullName,
                      month: monthCtrl.text.trim(),
                      year: year,
                      netSalary: netSalary,
                      allowances: allowances,
                      deductions: deductions,
                      status: "Paid",
                    );

                    await _firebaseService.addPayroll(newPayroll);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Oluştur", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLeaveRequestsTab() {
    return StreamBuilder<List<LeaveRequestModel>>(
      stream: _firebaseService.adminLeaveRequestsStream,
      initialData: _firebaseService.getAllLeaveRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.buttonDark));
        }

        final requests = snapshot.data ?? [];
        final pendingRequests = requests.where((r) => r.status == 'pending').toList();
        final processedRequests = requests.where((r) => r.status != 'pending').toList();

        final Map<String, int> leaveStats = {};
        for (var req in requests) {
          if (req.status == 'approved') {
            leaveStats[req.userName] = (leaveStats[req.userName] ?? 0) + req.durationDays;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "İzin İstatistikleri (Kim Ne Kadar İzin Yapmış?)",
                style: TextStyle(fontFamily: 'DINPro', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
            
            if (leaveStats.isEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Henüz onaylanmış bir izin bulunmuyor.",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              )
            else
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.buttonLight, width: 1),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: leaveStats.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final employeeName = leaveStats.keys.elementAt(index);
                    final totalDays = leaveStats[employeeName]!;
                    return ListTile(
                      leading: const Icon(Icons.date_range, color: AppColors.accent),
                      title: Text(employeeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.darkGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "$totalDays Gün İzin",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkGreen, fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Onay Bekleyen İzin Talepleri",
                style: TextStyle(fontFamily: 'DINPro', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 12),

            if (pendingRequests.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    "Bekleyen izin talebi bulunmuyor.",
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ),
              )
            else
              ...pendingRequests.map((req) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(req.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                req.leaveType,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tarih: ${req.startDate} / ${req.endDate} (${req.durationDays} Gün)",
                          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Gerekçe: ${req.reason}",
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: "Reddet",
                                type: CustomButtonType.secondary,
                                height: 36,
                                onPressed: () => _firebaseService.rejectLeaveRequest(req.id),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomButton(
                                text: "Onayla",
                                height: 36,
                                onPressed: () => _firebaseService.approveLeaveRequest(req.id),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),

            const SizedBox(height: 24),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Geçmiş İzin Talepleri",
                style: TextStyle(fontFamily: 'DINPro', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 12),

            if (processedRequests.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    "İşlem görmüş izin bulunmuyor.",
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ),
              )
            else
              ...processedRequests.map((req) {
                final isApproved = req.status == 'approved';
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(req.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(
                          isApproved ? "Onaylandı" : "Reddedildi",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isApproved ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      "${req.leaveType} (${req.durationDays} Gün)\n${req.startDate} / ${req.endDate}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    isThreeLine: true,
                  ),
                );
              }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildTypeBadge(String type) {
    Color badgeColor = AppColors.accent;
    String label = "Duyuru";

    switch (type) {
      case 'wedding':
        badgeColor = Colors.pinkAccent;
        label = "Düğün";
        break;
      case 'celebration':
        badgeColor = Colors.orangeAccent;
        label = "Kutlama";
        break;
      case 'event':
        badgeColor = Colors.blueAccent;
        label = "Etkinlik";
        break;
      case 'agreement':
        badgeColor = Colors.purpleAccent;
        label = "Anlaşma";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor, width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}


