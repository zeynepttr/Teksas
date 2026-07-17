import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class DoctorBookingScreen extends StatefulWidget {
  const DoctorBookingScreen({Key? key}) : super(key: key);

  @override
  State<DoctorBookingScreen> createState() => _DoctorBookingScreenState();
}

class _DoctorBookingScreenState extends State<DoctorBookingScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  // Appointment Form variables
  final _formKey = GlobalKey<FormState>();
  String _selectedCity = "İstanbul";
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  final TextEditingController _notesController = TextEditingController();
  bool _isBooking = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _getDoctorForCity(String city) {
    switch (city) {
      case "İstanbul":
        return "Dr. Ayşe Yılmaz";
      case "Ankara":
        return "Dr. Hakan Demir";
      case "Hatay":
        return "Dr. Selim Kaya";
      case "Kahramanmaraş":
        return "Dr. Merve Çelik";
      default:
        return "Dr. Ayşe Yılmaz";
    }
  }

  String _getFacilityForDate(String city, DateTime date) {
    final weekday = date.weekday;
    if (city == "İstanbul") {
      if (weekday == 1 || weekday == 3) return "İHH Tuzla Temsilciliği";
      if (weekday == 2 || weekday == 4) return "İHH Ümraniye Ofisi";
      return "İHH Fatih Genel Merkez";
    } else if (city == "Ankara") {
      if (weekday == 1 || weekday == 3) return "İHH Çankaya Temsilciliği";
      return "İHH Yenimahalle Depo";
    } else if (city == "Hatay") {
      if (weekday == 1 || weekday == 3 || weekday == 5) return "İHH Antakya Lojistik Merkezi";
      return "İHH Kırıkhan Depo";
    } else if (city == "Kahramanmaraş") {
      if (weekday == 1 || weekday == 3 || weekday == 5) return "İHH Kahramanmaraş Merkez Depo";
      return "İHH Elbistan İrtibat Bürosu";
    }
    return "İHH Merkez Ofis";
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
            colorScheme: const ColorScheme.light(
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
            colorScheme: const ColorScheme.light(
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
      final doctor = _getDoctorForCity(_selectedCity);
      final facility = _getFacilityForDate(_selectedCity, _selectedDate);

      await _firebaseService.bookAppointment(
        doctorName: doctor,
        role: "İş Yeri Hekimi",
        city: "$_selectedCity ($facility)",
        date: dateStr,
        time: timeStr,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Randevunuz alındı: $doctor - $dateStr saat $timeStr ($facility)", style: const TextStyle(fontFamily: 'DINPro')),
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
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "Doktorum Nerede",
            style: TextStyle(fontFamily: 'DINPro', fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Premium Header Banner
              _buildHeaderSection(),
              const SizedBox(height: 24),

              // 2. Appointment Booking Form
              _buildBookingForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.buttonLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_city_outlined, color: AppColors.accent, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Şehir & Kurum Bazlı Randevu",
                  style: TextStyle(
                    fontFamily: 'DINPro',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Şehrinizi seçin, ilgili bölge hekiminizin o tarihte hangi İHH yerleşkesinde/deposunda olduğunu görerek randevunuzu oluşturun.",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBookingForm() {
    final doctor = _getDoctorForCity(_selectedCity);
    final facility = _getFacilityForDate(_selectedCity, _selectedDate);
    final dateStr = "${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}";

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Randevu Planlama Formu",
            style: TextStyle(fontFamily: 'DINPro', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),

          // City selector
          const Text(
            "Çalıştığınız Şehir",
            style: TextStyle(fontFamily: 'DINPro', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceLight, width: 1.5),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCity,
                dropdownColor: AppColors.surface,
                isExpanded: true,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                items: const [
                  DropdownMenuItem(value: "İstanbul", child: Text("İstanbul")),
                  DropdownMenuItem(value: "Ankara", child: Text("Ankara")),
                  DropdownMenuItem(value: "Hatay", child: Text("Hatay")),
                  DropdownMenuItem(value: "Kahramanmaraş", child: Text("Kahramanmaraş")),
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

          // Doctor auto-assigned
          const Text(
            "Bölge Hekimi",
            style: TextStyle(fontFamily: 'DINPro', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceLight, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: AppColors.accent, size: 18),
                const SizedBox(width: 12),
                Text(
                  "$doctor (İş Yeri Hekimi)",
                  style: const TextStyle(
                    fontFamily: 'DINPro',
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
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
                          border: Border.all(color: AppColors.surfaceLight, width: 1.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dateStr,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
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
                          border: Border.all(color: AppColors.surfaceLight, width: 1.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}",
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
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
          const SizedBox(height: 20),

          // Dynamic Location Indicator Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.buttonLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.accent, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Hekim Yerleşke Bilgisi",
                      style: TextStyle(
                        fontFamily: 'DINPro',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Seçtiğiniz tarihte ($dateStr) $doctor, $facility yerleşkesinde hizmet vermektedir.",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

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
