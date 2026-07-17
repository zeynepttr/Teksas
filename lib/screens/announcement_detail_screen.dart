import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/announcement_model.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_button.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  final AnnouncementModel announcement;

  const AnnouncementDetailScreen({
    Key? key,
    required this.announcement,
  }) : super(key: key);

  @override
  State<AnnouncementDetailScreen> createState() => _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late AnnouncementModel _currentAnnouncement;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _currentAnnouncement = widget.announcement;
  }

  Color _getTypeColor() {
    switch (_currentAnnouncement.type) {
      case 'event':
        return AppColors.buttonDark;
      case 'wedding':
        return const Color(0xFFC782B9);
      case 'celebration':
        return AppColors.warning;
      case 'agreement':
        return AppColors.oliveGreen;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getTypeLabel() {
    switch (_currentAnnouncement.type) {
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

  Future<void> _handleJoinEvent() async {
    setState(() {
      _isJoining = true;
    });

    try {
      await _firebaseService.joinEvent(_currentAnnouncement.id);
      
      // Update state locally based on updated list in service
      final user = _firebaseService.currentUser;
      if (user != null) {
        final currentAttendees = Map<String, bool>.from(_currentAnnouncement.attendees);
        final hasJoined = currentAttendees[user.uid] == true;
        currentAttendees[user.uid] = !hasJoined;
        
        setState(() {
          _currentAnnouncement = _currentAnnouncement.copyWith(attendees: currentAttendees);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata oluştu: $e"), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() {
        _isJoining = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _firebaseService.currentUser;
    final hasJoined = user != null && _currentAnnouncement.hasJoined(user.uid);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Elegant Sliver App Bar with Cover Image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _currentAnnouncement.imageUrl != null
                  ? Image.network(
                      _currentAnnouncement.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surfaceLight,
                        child: const Center(
                          child: Icon(Icons.broken_image, color: AppColors.textMuted, size: 50),
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.surfaceLight,
                      child: const Center(
                        child: Icon(Icons.campaign, color: AppColors.textMuted, size: 50),
                      ),
                    ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getTypeColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getTypeColor(), width: 1),
                    ),
                    child: Text(
                      _getTypeLabel(),
                      style: TextStyle(
                        color: _getTypeColor(),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    _currentAnnouncement.title,
                    style: const TextStyle(
                      fontFamily: 'DINPro',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Metadata (Author and Timestamp)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.darkGreen,
                        child: Text(
                          _currentAnnouncement.author.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentAnnouncement.author,
                            style: const TextStyle(
                              fontFamily: 'DINPro',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            _currentAnnouncement.date ?? "Duyuru Tarihi",
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Divider
                  Container(
                    height: 1,
                    color: AppColors.surfaceLight,
                  ),
                  const SizedBox(height: 20),
                  
                  // Event details section (Location & Date/Time info)
                  if (_currentAnnouncement.isEvent) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceLight, width: 1),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_month, color: AppColors.accent, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _currentAnnouncement.date ?? "Belirtilmemiş",
                                  style: const TextStyle(
                                    fontFamily: 'DINPro',
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: AppColors.accent, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _currentAnnouncement.location ?? "Belirtilmemiş",
                                  style: const TextStyle(
                                    fontFamily: 'DINPro',
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Description
                  const Text(
                    "Açıklama",
                    style: TextStyle(
                      fontFamily: 'DINPro',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentAnnouncement.description,
                    style: const TextStyle(
                      fontFamily: 'DINPro',
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Event RSVP Button
                  if (_currentAnnouncement.isEvent) ...[
                    Center(
                      child: Column(
                        children: [
                          CustomButton(
                            text: hasJoined ? "Katılmaktan Vazgeç" : "Etkinliğe Katıl",
                            type: hasJoined ? CustomButtonType.secondary : CustomButtonType.primary,
                            width: double.infinity,
                            icon: hasJoined ? Icons.check_circle : Icons.add_circle_outline,
                            isLoading: _isJoining,
                            onPressed: _handleJoinEvent,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Toplam ${_currentAnnouncement.attendeeCount} çalışma arkadaşımız katılıyor.",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
