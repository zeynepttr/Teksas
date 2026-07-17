import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/ai_assistant_service.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class DoctorBookingScreen extends StatefulWidget {
  const DoctorBookingScreen({Key? key}) : super(key: key);

  @override
  State<DoctorBookingScreen> createState() => _DoctorBookingScreenState();
}

class _DoctorBookingScreenState extends State<DoctorBookingScreen> {
  final AIAssistantService _aiService = AIAssistantService();
  final FirebaseService _firebaseService = FirebaseService();

  // Chat variables
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final List<Map<String, dynamic>> _chatMessages = [];
  bool _isAiTyping = false;

  // AI Recommendation outcomes
  String? _recommendedRole;
  List<String> _recommendationTips = [];

  // Appointment Form variables
  final _formKey = GlobalKey<FormState>();
  String _selectedDoctor = "Dr. Ayşe Yılmaz";
  String _selectedRole = "İş Yeri Hekimi";
  String _selectedCity = "İstanbul";
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  final TextEditingController _notesController = TextEditingController();
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    // Insert welcome message from AI
    _chatMessages.add({
      "text": "Merhaba! Ben Hane Sağlık ve Esenlik Asistanıyım. Bugün kendinizi nasıl hissediyorsunuz? Şikayetlerinizi veya zihinsel durumunuzu (stres, yorgunluk, ağrı vb.) benimle paylaşabilirsiniz.",
      "isUser": false,
      "time": DateTime.now(),
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    _chatScrollController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    _chatController.clear();
    setState(() {
      _chatMessages.add({
        "text": text,
        "isUser": true,
        "time": DateTime.now(),
      });
      _isAiTyping = true;
    });
    _scrollToBottom();

    try {
      final rec = await _aiService.getRecommendation(text);
      
      setState(() {
        _isAiTyping = false;
        _chatMessages.add({
          "text": rec.responseText,
          "isUser": false,
          "time": DateTime.now(),
        });
        
        // Save recommendation to prefill form
        if (rec.recommendedSpecialist != "Genel Esenlik") {
          _recommendedRole = rec.recommendedSpecialist;
          _selectedRole = rec.recommendedSpecialist;
          
          if (_selectedRole == "İş Yeri Hekimi") {
            _selectedDoctor = "Dr. Ayşe Yılmaz";
          } else {
            _selectedDoctor = "Psk. Selim Can";
          }
        }
        
        _recommendationTips = rec.tips;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isAiTyping = false;
        _chatMessages.add({
          "text": "Öneri alınırken bir sorun oluştu. Lütfen tekrar deneyin.",
          "isUser": false,
          "time": DateTime.now(),
        });
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.darkGreen,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.darkGreen,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _handleBookAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isBooking = true;
    });

    try {
      final dateStr = "${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}";
      final timeStr = "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}";

      await _firebaseService.bookAppointment(
        doctorName: _selectedDoctor,
        role: _selectedRole,
        city: _selectedCity,
        date: dateStr,
        time: timeStr,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Randevunuz başarıyla alındı: $_selectedDoctor - $dateStr saat $timeStr"),
            backgroundColor: AppColors.buttonDark,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Hata oluştu: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  String _getMonthName(int month) {
    const months = ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Doktorum Nerede",
          style: TextStyle(fontFamily: 'DINPro', fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. AI Wellness Chat Panel Header
                  _buildHeaderSection(),
                  const SizedBox(height: 16),

                  // 2. Chat interface inside a styled container
                  _buildChatContainer(constraints),
                  const SizedBox(height: 16),

                  // 3. AI Recommendations/Tips Card
                  if (_recommendationTips.isNotEmpty) ...[
                    _buildTipsCard(),
                    const SizedBox(height: 24),
                  ],

                  // 4. Appointment Booking Form
                  _buildBookingForm(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkGreen.withOpacity(0.2), width: 1),
      ),
      child: const Row(
        children: [
          Icon(Icons.psychology_outlined, color: AppColors.accent, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AI Triage & Sağlık Yönlendirmesi",
                  style: TextStyle(fontFamily: 'DINPro', fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                ),
                SizedBox(height: 2),
                Text(
                  "Şikayetlerinizi yazın, yapay zekâ sizi en doğru kurum hekimine/psikoloğuna yönlendirsin.",
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChatContainer(BoxConstraints constraints) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceLight, width: 1.5),
      ),
      child: Column(
        children: [
          // Message List
          Expanded(
            child: ListView.builder(
              controller: _chatScrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _chatMessages.length + (_isAiTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _chatMessages.length && _isAiTyping) {
                  return _buildTypingIndicator();
                }
                
                final msg = _chatMessages[index];
                final isUser = msg['isUser'] == true;
                
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.darkGreen : AppColors.surfaceLight,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
                        bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                      ),
                      border: Border.all(
                        color: isUser ? Colors.transparent : AppColors.surfaceLight,
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(
                        fontSize: 13,
                        color: isUser ? Colors.white : AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const Divider(height: 1, color: AppColors.surfaceLight),
          
          // Chat Input Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    onSubmitted: (_) => _handleSendMessage(),
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Buraya yazın (örn: başım ağrıyor, yorgunum...)",
                      hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppColors.accent),
                  onPressed: _handleSendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const SizedBox(
          width: 24,
          height: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(backgroundColor: AppColors.accent, radius: 2.5),
              CircleAvatar(backgroundColor: AppColors.accent, radius: 2.5),
              CircleAvatar(backgroundColor: AppColors.accent, radius: 2.5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Card(
      color: AppColors.surfaceLight.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.health_and_safety, color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Yapay Zekâ Sağlık Tavsiyeleri (${_recommendedRole ?? 'Öneri'})",
                  style: const TextStyle(
                    fontFamily: 'DINPro',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ..._recommendationTips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("• ", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          tip,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Randevu Planlama Formu",
            style: TextStyle(fontFamily: 'DINPro', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),

          // Specialist dropdown
          const Text(
            "Sağlık Uzmanı",
            style: TextStyle(fontFamily: 'DINPro', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceLight),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDoctor,
                dropdownColor: AppColors.surface,
                isExpanded: true,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                items: const [
                  DropdownMenuItem(
                    value: "Dr. Ayşe Yılmaz",
                    child: Text("Dr. Ayşe Yılmaz (İş Yeri Hekimi)"),
                  ),
                  DropdownMenuItem(
                    value: "Psk. Selim Can",
                    child: Text("Psk. Selim Can (Kurum Psikoloğu)"),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedDoctor = val;
                      _selectedRole = val == "Dr. Ayşe Yılmaz" ? "İş Yeri Hekimi" : "Kurum Psikoloğu";
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // City selector
          const Text(
            "Lokasyon / Şehir",
            style: TextStyle(fontFamily: 'DINPro', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceLight),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCity,
                dropdownColor: AppColors.surface,
                isExpanded: true,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                items: const [
                  DropdownMenuItem(value: "İstanbul", child: Text("İstanbul (Genel Merkez)")),
                  DropdownMenuItem(value: "Ankara", child: Text("Ankara (Bölge Temsilciliği)")),
                  DropdownMenuItem(value: "Hatay", child: Text("Hatay Lojistik Merkezi")),
                  DropdownMenuItem(value: "Kahramanmaraş", child: Text("Kahramanmaraş Depo")),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCity = val;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Date and Time Selectors
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Randevu Tarihi",
                      style: TextStyle(fontFamily: 'DINPro', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.surfaceLight),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}",
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                            const Icon(Icons.calendar_today, color: AppColors.accent, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Saat",
                      style: TextStyle(fontFamily: 'DINPro', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectTime(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.surfaceLight),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}",
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                            const Icon(Icons.access_time, color: AppColors.accent, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Problem explanation
          CustomTextField(
            controller: _notesController,
            hintText: "Varsa hekimin bilmesini istediğiniz ek notlar...",
            labelText: "Şikayet Detayı / Notlar",
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          // Book Button
          CustomButton(
            text: "Randevuyu Onayla",
            width: double.infinity,
            isLoading: _isBooking,
            onPressed: _handleBookAppointment,
          ),
        ],
      ),
    );
  }
}
