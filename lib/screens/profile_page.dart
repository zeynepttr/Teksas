import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/appointment_model.dart';
import '../models/payroll_model.dart';
import '../models/leave_request_model.dart';
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
    'wedding': 'https://images.unsplash.com/photo-1607344645866-009c320c5ab8?q=80&w=400&auto=format&fit=crop',
    'celebration': 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400&auto=format&fit=crop',
    'general': 'https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=400&auto=format&fit=crop',
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
    _firebaseService.getPayrolls();
    _firebaseService.getLeaveRequests();
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildSubTab(0, "Bilgilerim", Icons.edit_note),
                _buildSubTab(1, "Paylaşım İsteği", Icons.add_photo_alternate_outlined),
                _buildSubTab(2, "Randevularım", Icons.calendar_today_outlined),
                _buildSubTab(3, "Bordrolarım", Icons.receipt_long_outlined),
                _buildSubTab(4, "İzin Taleplerim", Icons.time_to_leave_outlined),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. Content Area
          if (_activeSubSection == 0) _buildProfileEditForm(),
          if (_activeSubSection == 1) _buildAnnouncementRequestForm(),
          if (_activeSubSection == 2) _buildAppointmentsList(),
          if (_activeSubSection == 3) _buildProfilePayrolls(),
          if (_activeSubSection == 4) _buildProfileLeaveRequests(),
        ],
      ),
    );
  }

  Widget _buildSubTab(int index, String title, IconData icon) {
    final isSelected = _activeSubSection == index;
    return Container(
      width: 90,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeSubSection = index;
          });
        },
        child: Container(
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
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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

  Widget _buildProfilePayrolls() {
    return StreamBuilder<List<PayrollModel>>(
      stream: _firebaseService.payrollsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.buttonDark));
        }

        final payrolls = snapshot.data ?? [];

        if (payrolls.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(Icons.receipt_long, color: AppColors.textMuted, size: 48),
                  SizedBox(height: 12),
                  Text(
                    "Adınıza kayıtlı maaş bordrosu bulunmuyor.",
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Maaş Bordrolarım",
              style: TextStyle(fontFamily: 'DINPro', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            ...payrolls.map((pay) {
              final double totalPaid = pay.netSalary + pay.allowances - pay.deductions;
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "HANE İNSANİ YARDIM DERNEĞİ",
                                style: TextStyle(fontFamily: 'DINPro', fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accent),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${pay.month} ${pay.year} Bordrosu",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "ÖDENDİ",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 10, letterSpacing: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Net Maaş", style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          Text("${pay.netSalary.toStringAsFixed(0)} TL", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Sosyal Yardım / Ek Ödeme", style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          Text("+${pay.allowances.toStringAsFixed(0)} TL", style: const TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Vergi & Diğer Kesintiler", style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          Text("-${pay.deductions.toStringAsFixed(0)} TL", style: const TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Net Ödenen Tutar",
                            style: TextStyle(fontFamily: 'DINPro', fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                          ),
                          Text(
                            "${totalPaid.toStringAsFixed(0)} TL",
                            style: const TextStyle(fontFamily: 'DINPro', fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkGreen),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildProfileLeaveRequests() {
    final leaveTypeCtrl = TextEditingController(text: "Yıllık İzin");
    final startDateCtrl = TextEditingController(text: "2026-08-10");
    final endDateCtrl = TextEditingController(text: "2026-08-15");
    final durationCtrl = TextEditingController(text: "5");
    final reasonCtrl = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Yeni İzin Talebinde Bulun",
                  style: TextStyle(fontFamily: 'DINPro', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: leaveTypeCtrl.text,
                  decoration: const InputDecoration(
                    labelText: "İzin Türü",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Yıllık İzin', child: Text('Yıllık İzin')),
                    DropdownMenuItem(value: 'Sağlık İzni', child: Text('Sağlık İzni')),
                    DropdownMenuItem(value: 'Mazeret İzni', child: Text('Mazeret İzni')),
                  ],
                  onChanged: (val) {
                    if (val != null) leaveTypeCtrl.text = val;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: CustomTextField(controller: startDateCtrl, labelText: "Başlangıç", hintText: "YYYY-MM-DD")),
                    const SizedBox(width: 12),
                    Expanded(child: CustomTextField(controller: endDateCtrl, labelText: "Bitiş", hintText: "YYYY-MM-DD")),
                  ],
                ),
                const SizedBox(height: 12),
                CustomTextField(controller: durationCtrl, labelText: "Süre (Gün)", hintText: "Süre", keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                CustomTextField(controller: reasonCtrl, labelText: "Gerekçe / Açıklama", hintText: "İzin alma nedeniniz..."),
                const SizedBox(height: 16),
                CustomButton(
                  text: "İzin Talebini Gönder",
                  width: double.infinity,
                  onPressed: () async {
                    if (reasonCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Lütfen gerekçe belirtin."), backgroundColor: AppColors.error),
                      );
                      return;
                    }
                    await _firebaseService.submitLeaveRequest(
                      leaveType: leaveTypeCtrl.text,
                      startDate: startDateCtrl.text,
                      endDate: endDateCtrl.text,
                      durationDays: int.tryParse(durationCtrl.text) ?? 1,
                      reason: reasonCtrl.text,
                    );
                    reasonCtrl.clear();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("İzin talebiniz başarıyla İK birimine iletilmiştir."), backgroundColor: AppColors.buttonDark),
                      );
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),

        const Text(
          "İzin Taleplerim & Geçmiş",
          style: TextStyle(fontFamily: 'DINPro', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),

        StreamBuilder<List<LeaveRequestModel>>(
          stream: _firebaseService.leaveRequestsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: AppColors.buttonDark));
            }

            final requests = snapshot.data ?? [];

            if (requests.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    "Kayıtlı izin talebiniz bulunmuyor.",
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                Color statusColor = Colors.orange;
                String statusLabel = "Bekliyor";

                if (req.status == 'approved') {
                  statusColor = Colors.green;
                  statusLabel = "Onaylandı";
                } else if (req.status == 'rejected') {
                  statusColor = Colors.red;
                  statusLabel = "Reddedildi";
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(req.leaveType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      "Tarih: ${req.startDate} / ${req.endDate} (${req.durationDays} Gün)\nGerekçe: ${req.reason}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
