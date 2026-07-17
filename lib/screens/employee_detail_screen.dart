import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../models/user_model.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final UserModel employee;

  const EmployeeDetailScreen({
    Key? key,
    required this.employee,
  }) : super(key: key);

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              "$label panoya kopyalandı!",
              style: const TextStyle(fontFamily: 'DINPro', fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: AppColors.buttonDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatJoinDate(int timestamp) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final List<String> months = [
        "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran",
        "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"
      ];
      return "${date.day} ${months[date.month - 1]} ${date.year}";
    } catch (_) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Çalışan Detayı",
          style: TextStyle(fontFamily: 'DINPro', fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile Header Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.accent.withOpacity(0.12),
                      child: Text(
                        employee.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee.fullName,
                            style: const TextStyle(
                              fontFamily: 'DINPro',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.oliveGreen.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.oliveGreen.withOpacity(0.2), width: 0.5),
                            ),
                            child: Text(
                              employee.role,
                              style: const TextStyle(
                                color: AppColors.oliveGreen,
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
              ),
            ),
            const SizedBox(height: 24),

            // 2. Info Sections Header
            const Text(
              "Kurumsal Bilgiler",
              style: TextStyle(
                fontFamily: 'DINPro',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // 3. Corporate Info Box
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow(context, Icons.business, "Birim / Departman", employee.department),
                    const Divider(height: 24),
                    _buildInfoRow(
                      context,
                      Icons.badge_outlined,
                      "Sicil Kodu (Çalışan Kodu)",
                      employee.employeeCode,
                      canCopy: true,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      context,
                      Icons.phone_callback_outlined,
                      "Dahili Hat (No)",
                      employee.extension,
                      canCopy: true,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(context, Icons.calendar_today_outlined, "İşe Başlama Tarihi", _formatJoinDate(employee.joinTimestamp)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 4. Contact Info Section
            const Text(
              "İletişim Bilgileri",
              style: TextStyle(
                fontFamily: 'DINPro',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context,
                      Icons.mail_outline,
                      "E-posta Adresi",
                      employee.email,
                      canCopy: true,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      context,
                      Icons.phone_outlined,
                      "Telefon Numarası",
                      employee.phone,
                      canCopy: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 5. Personal Info Section
            const Text(
              "Kişisel Bilgiler",
              style: TextStyle(
                fontFamily: 'DINPro',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow(context, Icons.bloodtype_outlined, "Kan Grubu", employee.bloodGroup.toUpperCase()),
                    const Divider(height: 24),
                    _buildInfoRow(context, Icons.cake_outlined, "Yaş", "${employee.age} Yaşında"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, {bool canCopy = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'DINPro',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (canCopy)
          IconButton(
            icon: const Icon(Icons.copy, color: AppColors.accent, size: 16),
            onPressed: () => _copyToClipboard(context, value, label),
          ),
      ],
    );
  }
}
