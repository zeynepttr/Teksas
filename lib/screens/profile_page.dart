import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/appointment_model.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/appointment_card.dart';
import 'admin_panel_screen.dart';
import 'doctor_booking_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseService _firebaseService = FirebaseService();
  
  // Profile Update Form Fields
  final _profileFormKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  late TextEditingController _bloodGroupController;
  bool _isUpdatingProfile = false;

  // Announcement Request Form Fields
  final _requestFormKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  final _locController = TextEditingController();
  String _selectedType = 'wedding';
  String _selectedPresetImage = 'wedding'; // wedding, celebration, general
  bool _isSubmittingRequest = false;

  // Visual tab state (Info/Edit, New Request, Appointments)
  int _activeSubSection = 0; // 0 = Info/Edit, 1 = New Request, 2 = Appointments

  // Unsplash preset URLs to allow realistic mock requests
  final Map<String, String> _presetImages = {
    'wedding': 'https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8?q=80&w=600&auto=format&fit=crop',
    'celebration': 'https://images.unsplash.com/photo-1519689680058-324335c77eba?q=80&w=600&auto=format&fit=crop',
    'general': 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?q=80&w=600&auto=format&fit=crop',
  };

  @override
  void initState() {
    super.initState();
    final user = _firebaseService.currentUser;
    _nameController = TextEditingController(text: user?.name);
    _surnameController = TextEditingController(text: user?.surname);
    _phoneController = TextEditingController(text: user?.phone);
    _ageController = TextEditingController(text: user?.age.toString());
    _bloodGroupController = TextEditingController(text: user?.bloodGroup);
    
    _firebaseService.getAppointments();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _bloodGroupController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _dateController.dispose();
    _locController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;

    setState(() {
      _isUpdatingProfile = true;
    });

    try {
      await _firebaseService.updateProfile(
        name: _nameController.text.trim(),
        surname: _surnameController.text.trim(),
        phone: _phoneController.text.trim(),
        bloodGroup: _bloodGroupController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 0,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Profil başarıyla güncellendi. İK paneline bildirim gönderildi.", style: TextStyle(fontFamily: 'DINPro')),
            backgroundColor: AppColors.buttonDark,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e"), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingProfile = false;
        });
      }
    }
  }

  Future<void> _handleSubmitRequest() async {
    if (!_requestFormKey.currentState!.validate()) return;

    setState(() {
      _isSubmittingRequest = true;
    });

    try {
      await _firebaseService.submitAnnouncementRequest(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        type: _selectedType,
        date: _dateController.text.isEmpty ? null : _dateController.text.trim(),
        location: _locController.text.isEmpty ? null : _locController.text.trim(),
        imageUrl: _presetImages[_selectedPresetImage],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Paylaşım talebiniz İK onayına gönderilmiştir.", style: TextStyle(fontFamily: 'DINPro')),
            backgroundColor: AppColors.buttonDark,
          ),
        );
        // Clear request form
        _titleController.clear();
        _descController.clear();
        _dateController.clear();
        _locController.clear();
        setState(() {
          _activeSubSection = 0; // Return to details tab
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e"), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingRequest = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _firebaseService.currentUser;
    if (user == null) return const Center(child: Text("Oturum açık değil."));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Profile Header Widget
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primaryGradient.colors.first,
                child: Text(
                  user.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'DINPro',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontFamily: 'DINPro',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: user.isAdmin ? AppColors.error.withOpacity(0.2) : AppColors.buttonDark.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: user.isAdmin ? AppColors.error : AppColors.buttonDark, width: 0.5),
                      ),
                      child: Text(
                        user.role,
                        style: TextStyle(
                          color: user.isAdmin ? AppColors.error : AppColors.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Admin Panel shortcut section (Only for Admins)
          if (user.isAdmin) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.error.withOpacity(0.3), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.admin_panel_settings, color: AppColors.error),
                      SizedBox(width: 8),
                      Text(
                        "Yönetici Konsolu (İK Yetkisi)",
                        style: TextStyle(
                          fontFamily: 'DINPro',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Paylaşım onayları, profil değişiklik bildirimleri ve sistem yönetim paneline erişin.",
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: "İK Yönetici Paneline Git",
                    width: double.infinity,
                    height: 44,
                    icon: Icons.dashboard,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 3. Sub-navigation tabs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSubTab(0, "Bilgilerim & Düzenle", Icons.edit_note),
              _buildSubTab(1, "Paylaşım İsteği", Icons.add_photo_alternate_outlined),
              _buildSubTab(2, "Randevularım", Icons.calendar_today_outlined),
            ],
          ),
          const SizedBox(height: 20),

          // 4. Content Area
          if (_activeSubSection == 0) _buildProfileEditForm(),
          if (_activeSubSection == 1) _buildAnnouncementRequestForm(),
          if (_activeSubSection == 2) _buildAppointmentsList(),
        ],
      ),
    );
  }

  Widget _buildSubTab(int index, String title, IconData icon) {
    final isSelected = _activeSubSection == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeSubSection = index;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceLight : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.buttonDark : Colors.transparent,
              width: 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.accent : AppColors.textSecondary, size: 20),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DINPro',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // SUB-SECTION 0: Profile View & Edit Form
  Widget _buildProfileEditForm() {
    return Form(
      key: _profileFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: _nameController,
            hintText: "İsim",
            labelText: "Adı",
            prefixIcon: Icons.person_outline,
            validator: (val) => val == null || val.trim().isEmpty ? "Bu alan boş bırakılamaz." : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _surnameController,
            hintText: "Soyisim",
            labelText: "Soyadı",
            prefixIcon: Icons.person_outline,
            validator: (val) => val == null || val.trim().isEmpty ? "Bu alan boş bırakılamaz." : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _phoneController,
            hintText: "+90 555 123 4567",
            labelText: "Telefon Numarası",
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (val) => val == null || val.trim().isEmpty ? "Bu alan boş bırakılamaz." : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _ageController,
                  hintText: "Yaş",
                  labelText: "Yaş",
                  prefixIcon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return "Boş olamaz.";
                    if (int.tryParse(val) == null) return "Sayı olmalı.";
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  controller: _bloodGroupController,
                  hintText: "Örn: A Rh+",
                  labelText: "Kan Grubu",
                  prefixIcon: Icons.water_drop_outlined,
                  validator: (val) => val == null || val.trim().isEmpty ? "Boş olamaz." : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: "Profil Bilgilerini Güncelle",
            width: double.infinity,
            isLoading: _isUpdatingProfile,
            onPressed: _handleUpdateProfile,
          ),
        ],
      ),
    );
  }

  // SUB-SECTION 1: Announcement Request Submission Form
  Widget _buildAnnouncementRequestForm() {
    return Form(
      key: _requestFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Paylaşım İsteği Oluştur",
            style: TextStyle(fontFamily: 'DINPro', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            "Düğün davetiyesi, doğum kutlaması veya kişisel duyurularınızı İK onayına sunabilirsiniz. Onaylanan talepler ana ekrandaki akışta yayınlanır.",
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          
          // Request Type dropdown simulation (wedding, celebration, general)
          const Text(
            "Paylaşım Türü",
            style: TextStyle(fontFamily: 'DINPro', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTypeRadio('wedding', 'Düğün Daveti', Icons.favorite),
              const SizedBox(width: 8),
              _buildTypeRadio('celebration', 'Kutlama', Icons.cake),
              const SizedBox(width: 8),
              _buildTypeRadio('general', 'Duyuru', Icons.campaign),
            ],
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _titleController,
            hintText: "Duyuru Başlığı",
            labelText: "Başlık",
            prefixIcon: Icons.title,
            validator: (val) => val == null || val.trim().isEmpty ? "Başlık yazılmalıdır." : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _descController,
            hintText: "Açıklama veya davet detayları...",
            labelText: "Açıklama",
            maxLines: 4,
            validator: (val) => val == null || val.trim().isEmpty ? "Açıklama yazılmalıdır." : null,
          ),
          const SizedBox(height: 16),
          
          // Conditional fields for wedding/events
          if (_selectedType == 'wedding') ...[
            CustomTextField(
              controller: _dateController,
              hintText: "Örn: 15 Ağustos Pazartesi, 19:00",
              labelText: "Etkinlik Tarihi",
              prefixIcon: Icons.calendar_today,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _locController,
              hintText: "Örn: Ihlamur Kasrı, Beşiktaş",
              labelText: "Etkinlik Yeri",
              prefixIcon: Icons.location_on,
            ),
            const SizedBox(height: 16),
          ],
          
          // Preset image preview picker (wedding, celebration, general)
          const Text(
            "Görsel Seçimi (Örnek Görsel)",
            style: TextStyle(fontFamily: 'DINPro', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _presetImages.keys.map((key) {
              final isSelected = _selectedPresetImage == key;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPresetImage = key;
                  });
                },
                child: Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : Colors.transparent,
                      width: 2.0,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(_presetImages[key]!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          
          CustomButton(
            text: "Paylaşım Talebi Gönder",
            width: double.infinity,
            isLoading: _isSubmittingRequest,
            onPressed: _handleSubmitRequest,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeRadio(String type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.darkGreen.withOpacity(0.1) : Colors.transparent,
          side: BorderSide(color: isSelected ? AppColors.accent : AppColors.surfaceLight),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          setState(() {
            _selectedType = type;
            // set preset image matching type
            if (_presetImages.containsKey(type)) {
              _selectedPresetImage = type;
            }
          });
        },
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.accent : AppColors.textSecondary, size: 18),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'DINPro',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SUB-SECTION 2: Active Doctor/Psychologist Appointments List
  Widget _buildAppointmentsList() {
    return StreamBuilder<List<AppointmentModel>>(
      stream: _firebaseService.appointmentsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.buttonDark));
        }
        
        final appointments = snapshot.data ?? [];
        
        if (appointments.isEmpty) {
          return Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.calendar_today, color: AppColors.textMuted, size: 48),
                const SizedBox(height: 12),
                const Text(
                  "Aktif bir randevunuz bulunmamaktadır.",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: "Şimdi Randevu Al",
                  type: CustomButtonType.secondary,
                  onPressed: () {
                    // Navigate to Doctor screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DoctorBookingScreen()),
                    );
                  },
                )
              ],
            ),
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Aktif Randevularım",
              style: TextStyle(fontFamily: 'DINPro', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            ...appointments.map((app) => AppointmentCard(appointment: app)).toList(),
          ],
        );
      },
    );
  }
}
