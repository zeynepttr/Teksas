import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../models/agreement_model.dart';
import '../widgets/custom_button.dart';

class PrivilegeDetailScreen extends StatelessWidget {
  final AgreementModel agreement;

  const PrivilegeDetailScreen({
    Key? key,
    required this.agreement,
  }) : super(key: key);

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: agreement.code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              "'${agreement.code}' indirim kodu panoya kopyalandı!",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Anlaşma Detayı",
          style: TextStyle(fontFamily: 'DINPro', fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Header Banner Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    // Logo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 90,
                        height: 90,
                        color: AppColors.surfaceLight,
                        child: agreement.logoUrl != null
                            ? Image.network(
                                agreement.logoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(Icons.business, color: AppColors.textMuted, size: 40),
                                ),
                              )
                            : const Center(
                                child: Icon(Icons.business, color: AppColors.textMuted, size: 40),
                              ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    
                    // Titles
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.oliveGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              agreement.category.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.oliveGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            agreement.companyName,
                            style: const TextStyle(
                              fontFamily: 'DINPro',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                agreement.discountRate,
                                style: const TextStyle(
                                  fontFamily: 'DINPro',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent,
                                ),
                              ),
                              _buildDurationBadge(agreement),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Description Header
            const Text(
              "Kampanya Açıklaması",
              style: TextStyle(
                fontFamily: 'DINPro',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            
            // Description text
            Text(
              agreement.description,
              style: const TextStyle(
                fontFamily: 'DINPro',
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            // Promo Code Card container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: agreement.isExpired ? Colors.red.withOpacity(0.3) : AppColors.buttonDark.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.buttonDark.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    agreement.isExpired ? "KAMPANYA SÜRESİ DOLDU" : "İNDİRİM KODUNUZ",
                    style: TextStyle(
                      fontFamily: 'DINPro',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: agreement.isExpired ? Colors.red : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  if (agreement.isExpired)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.withOpacity(0.2), width: 1),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Bu anlaşmanın süresi sona erdiği için kampanya kodu kullanılamaz.",
                              style: TextStyle(
                                fontFamily: 'DINPro',
                                color: Colors.red,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    InkWell(
                      onTap: () => _copyToClipboard(context),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.accent,
                            style: BorderStyle.solid,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              agreement.code,
                              style: const TextStyle(
                                fontFamily: 'DINPro',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.copy, size: 18, color: AppColors.accent),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  
                  Text(
                    agreement.isExpired
                        ? "Süresi dolan kampanyalardan tekrar yararlanılamaz. Yenilenen kampanyalar için akışı takip edebilirsiniz."
                        : "Kodu kopyalamak için üzerine dokunun. Ödeme veya sipariş sayfasında indirim kodu alanına girerek indirimden faydalanabilirsiniz.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            CustomButton(
              text: agreement.isExpired ? "Süresi Dolan Kampanya" : "Kampanyayı Kullan",
              width: double.infinity,
              icon: agreement.isExpired ? Icons.event_busy : Icons.open_in_browser,
              onPressed: agreement.isExpired ? null : () => _copyToClipboard(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationBadge(AgreementModel agreement) {
    Color badgeColor = Colors.teal;
    IconData icon = Icons.all_inclusive;
    String label = agreement.durationLabel;

    if (agreement.isExpired) {
      badgeColor = Colors.red;
      icon = Icons.event_busy;
    } else if (!agreement.isPermanent) {
      badgeColor = Colors.orange;
      icon = Icons.event;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: badgeColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
