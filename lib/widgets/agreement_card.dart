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
            children: [
              // Logo image
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
              const SizedBox(width: 16),
              
              // Text information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.oliveGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.oliveGreen.withOpacity(0.4), width: 0.5),
                      ),
                      child: Text(
                        agreement.category.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.oliveGreen,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    
                    // Company Name
                    Text(
                      agreement.companyName,
                      style: const TextStyle(
                        fontFamily: 'DINPro',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Description snippet
                    Text(
                      agreement.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'DINPro',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              
              // Discount Rate highlight
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.buttonLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      agreement.discountRate,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'DINPro',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Text(
                        "Kodu Al",
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 12, color: AppColors.accent),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
