import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/agreement_model.dart';
import '../screens/privilege_detail_screen.dart';

class AgreementCard extends StatelessWidget {
  final AgreementModel agreement;

  const AgreementCard({
    Key? key,
    required this.agreement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: Opacity(
        opacity: agreement.isExpired ? 0.55 : 1.0,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrivilegeDetailScreen(agreement: agreement),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: AppColors.surfaceLight,
                    child: agreement.logoUrl != null
                        ? Image.network(
                            agreement.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(Icons.business, color: AppColors.textMuted, size: 30),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.business, color: AppColors.textMuted, size: 30),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.oliveGreen.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.oliveGreen.withOpacity(0.3), width: 0.5),
                            ),
                            child: Text(
                              agreement.category.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.oliveGreen,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.buttonLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              agreement.discountRate,
                              style: const TextStyle(
                                fontFamily: 'DINPro',
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      Text(
                        agreement.companyName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'DINPro',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),

                      _buildDurationBadge(agreement),
                      const SizedBox(height: 8),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              agreement.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'DINPro',
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                agreement.isExpired ? "Süre Doldu" : "Kodu Al",
                                style: TextStyle(
                                  color: agreement.isExpired ? AppColors.textMuted : AppColors.accent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.chevron_right, size: 12, color: agreement.isExpired ? AppColors.textMuted : AppColors.accent),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: badgeColor.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
