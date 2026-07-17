import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/agreement_model.dart';
import '../services/firebase_service.dart';
import '../widgets/agreement_card.dart';

class PrivilegesPage extends StatefulWidget {
  const PrivilegesPage({Key? key}) : super(key: key);

  @override
  State<PrivilegesPage> createState() => _PrivilegesPageState();
}

class _PrivilegesPageState extends State<PrivilegesPage> {
  final FirebaseService _firebaseService = FirebaseService();
  List<AgreementModel> _allAgreements = [];
  List<AgreementModel> _filteredAgreements = [];
  bool _isLoading = true;
  String _selectedCategory = "Tümü";

  final List<String> _categories = ["Tümü", "Gıda & Restoran", "Sağlık & Medikal", "Ulaşım & Akaryakıt", "Yaşam & Spor"];

  @override
  void initState() {
    super.initState();
    _loadAgreements();
  }

  Future<void> _loadAgreements() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _firebaseService.getAgreements();
      setState(() {
        _allAgreements = data;
        _filterAgreements();
      });
    } catch (e) {
      debugPrint("Error loading agreements: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterAgreements() {
    if (_selectedCategory == "Tümü") {
      _filteredAgreements = List.from(_allAgreements);
    } else {
      _filteredAgreements = _allAgreements
          .where((agr) => agr.category.toLowerCase().trim() == _selectedCategory.toLowerCase().trim())
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category filters
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = cat == _selectedCategory;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    cat,
                    style: TextStyle(
                      fontFamily: 'DINPro',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.darkGreen,
                  backgroundColor: AppColors.surface,
                  checkmarkColor: Colors.white,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = cat;
                        _filterAgreements();
                      });
                    }
                  },
                ),
              );
            },
          ),
        ),

        // Agreements list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.buttonDark))
              : _filteredAgreements.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star_border, color: AppColors.textMuted, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            "Bu kategoride anlaşma bulunmuyor.",
                            style: TextStyle(
                              fontFamily: 'DINPro',
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.buttonDark,
                      onRefresh: _loadAgreements,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        itemCount: _filteredAgreements.length,
                        itemBuilder: (context, index) {
                          return AgreementCard(agreement: _filteredAgreements[index]);
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
