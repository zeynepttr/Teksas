import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/listing_model.dart';
import '../widgets/custom_button.dart';

class ListingDetailScreen extends StatelessWidget {
  final ListingModel listing;

  const ListingDetailScreen({
    Key? key,
    required this.listing,
  }) : super(key: key);

  void _handleCall(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.phone_in_talk, color: Colors.white),
            const SizedBox(width: 12),
            Text("${listing.sellerName} aranıyor: ${listing.sellerPhone}...", style: const TextStyle(fontFamily: 'DINPro')),
          ],
        ),
        backgroundColor: AppColors.buttonDark,
      ),
    );
  }

  void _handleMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.message, color: Colors.white),
            const SizedBox(width: 12),
            Text("${listing.sellerName} için mesaj kutusu açılıyor...", style: const TextStyle(fontFamily: 'DINPro')),
          ],
        ),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime dt = DateTime.fromMillisecondsSinceEpoch(listing.timestamp);
    final dateString = "${dt.day} ${_getMonthName(dt.month)} ${dt.year}";

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Cover Image with Back Button overlay
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                listing.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.surfaceLight,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: AppColors.textMuted, size: 50),
                  ),
                ),
              ),
            ),
          ),

          // 2. Listing Details Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.accent, width: 0.5),
                    ),
                    child: Text(
                      listing.category.toUpperCase(),
                      style: const TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    listing.title,
                    style: const TextStyle(
                      fontFamily: 'DINPro',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Price
                  Text(
                    "${listing.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} TL",
                    style: const TextStyle(
                      fontFamily: 'DINPro',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Date
                  Text(
                    "İlan Tarihi: $dateString",
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 20),

                  const Divider(color: AppColors.surfaceLight),
                  const SizedBox(height: 16),

                  // Seller Info Card
                  const Text(
                    "Satıcı Bilgileri",
                    style: TextStyle(fontFamily: 'DINPro', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceLight),
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
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.surfaceLight,
                          child: Text(
                            listing.sellerName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontFamily: 'DINPro', color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                listing.sellerName,
                                style: const TextStyle(fontFamily: 'DINPro', fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Hane Çalışanı",
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Product Description
                  const Text(
                    "Ürün Açıklaması",
                    style: TextStyle(fontFamily: 'DINPro', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    listing.description,
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 40),

                  // Call to Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: "Mesaj Gönder",
                          type: CustomButtonType.secondary,
                          icon: Icons.chat_bubble_outline,
                          onPressed: () => _handleMessage(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(
                          text: "Ara",
                          icon: Icons.phone,
                          onPressed: () => _handleCall(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"];
    return months[month - 1];
  }
}
