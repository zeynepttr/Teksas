import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/announcement_model.dart';
import '../services/firebase_service.dart';
import '../widgets/announcement_card.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({Key? key}) : super(key: key);

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _firebaseService.getAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AnnouncementModel>>(
      stream: _firebaseService.announcementsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.buttonDark),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Duyurular yüklenirken hata oluştu: ${snapshot.error}",
              style: const TextStyle(color: AppColors.error),
            ),
          );
        }

        final announcements = snapshot.data ?? [];

        if (announcements.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.campaign_outlined, color: AppColors.textMuted, size: 64),
                SizedBox(height: 16),
                Text(
                  "Henüz yayınlanmış duyuru bulunmuyor.",
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

        return RefreshIndicator(
          color: AppColors.buttonDark,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            await _firebaseService.getAnnouncements();
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              return AnnouncementCard(announcement: announcements[index]);
            },
          ),
        );
      },
    );
  }
}
