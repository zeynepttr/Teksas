import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/announcement_model.dart';
import '../screens/announcement_detail_screen.dart';

class AnnouncementCard extends StatelessWidget {
  final AnnouncementModel announcement;

  const AnnouncementCard({
    Key? key,
    required this.announcement,
  }) : super(key: key);

  Color _getTypeColor() {
    switch (announcement.type) {
      case 'event':
        return AppColors.buttonDark;
      case 'wedding':
        return const Color(0xFFC782B9); // Soft purple/pink
      case 'celebration':
        return AppColors.warning;
      case 'agreement':
        return AppColors.oliveGreen;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getTypeLabel() {
    switch (announcement.type) {
      case 'event':
        return 'ETKİNLİK';
      case 'wedding':
        return 'DÜĞÜN DAVETİ';
      case 'celebration':
        return 'KUTLAMA';
      case 'agreement':
        return 'KURUMSAL ANLAŞMA';
      default:
        return 'DUYURU';
    }
  }

  IconData _getTypeIcon() {
    switch (announcement.type) {
      case 'event':
        return Icons.event;
      case 'wedding':
        return Icons.favorite;
      case 'celebration':
        return Icons.cake;
      case 'agreement':
        return Icons.handshake;
      default:
        return Icons.campaign;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnnouncementDetailScreen(announcement: announcement),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            if (announcement.imageUrl != null)
              Stack(
                children: [
                  Image.network(
                    announcement.imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: AppColors.surfaceLight,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: AppColors.textMuted, size: 40),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 180,
                        color: AppColors.surfaceLight,
                        child: const Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    },
                  ),
                  // Badge for type
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getTypeColor(),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getTypeIcon(), color: Colors.white, size: 12),
                          const SizedBox(width: 6),
                          Text(
                            _getTypeLabel(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    announcement.title,
                    style: const TextStyle(
                      fontFamily: 'DINPro',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    announcement.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'DINPro',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Divider
                  Container(
                    height: 1,
                    color: AppColors.surfaceLight,
                  ),
                  const SizedBox(height: 12),
                  
                  // Author & Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.darkGreen,
                            child: Text(
                              announcement.author.substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            announcement.author,
                            style: const TextStyle(
                              fontFamily: 'DINPro',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      
                      if (announcement.isEvent) ...[
                        Row(
                          children: [
                            const Icon(Icons.people_outline, color: AppColors.accent, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              "${announcement.attendeeCount} Katılımcı",
                              style: const TextStyle(
                                fontFamily: 'DINPro',
                                fontSize: 12,
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      ] else ...[
                        Text(
                          announcement.date ?? "Bugün",
                          style: const TextStyle(
                            fontFamily: 'DINPro',
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
