import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/announcement_model.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_button.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  late TabController _tabController;
  List<AnnouncementModel> _pendingRequests = [];
  bool _isLoadingRequests = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPendingRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "İK Yönetici Paneli",
          style: TextStyle(fontFamily: 'DINPro', fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontFamily: 'DINPro', fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: "Onay Bekleyenler"),
            Tab(text: "Sistem Logları"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingTab(),
          _buildLogsTab(),
        ],
      ),
    );
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


