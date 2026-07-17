import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/listing_model.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'listing_detail_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  int _currentIndex = 0;

  // Add Listing Form fields
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = "Elektronik";
  String _selectedPresetImage = "electronics";
  bool _isSubmitting = false;

  // Search variables
  final _searchController = TextEditingController();
  String _searchQuery = "";

  // Browse filter category
  String _activeCategoryFilter = "Tüm İlanlar";

  final Map<String, String> _imagePresets = {
    'electronics': 'https://images.unsplash.com/photo-1517256064527-09c53b2d0bc6?q=80&w=400&auto=format&fit=crop',
    'phone': 'https://images.unsplash.com/photo-1510557880182-3d4d3cba35a5?q=80&w=400&auto=format&fit=crop',
    'car': 'https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?q=80&w=400&auto=format&fit=crop',
    'realestate': 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?q=80&w=400&auto=format&fit=crop',
    'other': 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?q=80&w=400&auto=format&fit=crop'
  };

  @override
  void initState() {
    super.initState();
    _firebaseService.getListings();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateListing() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      await _firebaseService.createListing(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        price: price,
        category: _selectedCategory,
        imageUrl: _imagePresets[_selectedPresetImage],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("İlanınız başarıyla yayına alındı!"),
            backgroundColor: AppColors.buttonDark,
          ),
        );
        // Clear form
        _titleController.clear();
        _priceController.clear();
        _descController.clear();
        setState(() {
          _currentIndex = 0; // Go back to listings browse feed
          _activeCategoryFilter = "Tüm İlanlar";
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata oluştu: $e"), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
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
            "Aramızda",
            style: TextStyle(fontFamily: 'DINPro', fontWeight: FontWeight.bold),
          ),
          actions: [
            // Decorative chat button matching screenshot 4
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Mesaj kutusu çok yakında aktif edilecektir!"),
                    backgroundColor: AppColors.accent,
                  ),
                );
              },
            ),
          ],
        ),
        body: StreamBuilder<List<ListingModel>>(
          stream: _firebaseService.listingsStream,
          builder: (context, snapshot) {
            final listings = snapshot.data ?? [];

            return IndexedStack(
              index: _currentIndex,
              children: [
                _buildBrowseTab(listings),
                _buildSearchTab(listings),
                _buildAddListingTab(),
                _buildMyListingsTab(listings),
              ],
            );
          },
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.surfaceLight, width: 1.0),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedItemColor: AppColors.accent,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: "Ana Sayfa",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: "Arama",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline),
                activeIcon: Icon(Icons.add_circle, color: AppColors.accent),
                label: "İlan Ekle",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.view_list_outlined),
                activeIcon: Icon(Icons.view_list),
                label: "İlanlarım",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 0: BROWSE ---
  Widget _buildBrowseTab(List<ListingModel> listings) {
    // Apply category filter
    final activeListings = listings.where((l) => l.isActive).toList();
    final filteredListings = _activeCategoryFilter == "Tüm İlanlar"
        ? activeListings
        : activeListings.where((l) => l.category == _activeCategoryFilter).toList();

    return RefreshIndicator(
      onRefresh: () async => _firebaseService.getListings(),
      color: AppColors.buttonDark,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cover Campaign Banner
            _buildCampaignBanner(),
            const SizedBox(height: 20),

            // 2. Horizontal Categories
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Kategoriler",
                style: TextStyle(fontFamily: 'DINPro', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 12),
            _buildCategoriesRow(),
            const SizedBox(height: 20),

            // 3. Grid listings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _activeCategoryFilter == "Tüm İlanlar" ? "Tüm İlanlar" : "$_activeCategoryFilter İlanları",
                    style: const TextStyle(fontFamily: 'DINPro', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Text(
                    "${filteredListings.length} İlan",
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            filteredListings.isEmpty
                ? _buildEmptyState("Bu kategoride ilan bulunmuyor.")
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: filteredListings.length,
                    itemBuilder: (context, index) {
                      final item = filteredListings[index];
                      return _buildListingCard(item);
                    },
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF00ACC1), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Banner graphics background
          Positioned(
            right: -20,
            bottom: -30,
            child: CircleAvatar(
              radius: 90,
              backgroundColor: Colors.white.withOpacity(0.08),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 10,
            top: 10,
            child: Opacity(
              opacity: 0.85,
              child: Image.network(
                "https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=250&auto=format&fit=crop",
                width: 110,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Texts
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Bu Yaz Bazı Şeyleri\nSerbest Bırakıyoruz! 🧺",
                  style: TextStyle(
                    fontFamily: 'DINPro',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Dolabında sırasını bekleyen kıyafetleri sat.",
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC782B9), // Purple button matching screenshot 4
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () {
                    setState(() {
                      _currentIndex = 2; // Jump to Add Listing
                    });
                  },
                  child: const Text(
                    "Hemen İlan Ver",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesRow() {
    final categories = [
      {"name": "Tüm İlanlar", "icon": Icons.grid_view_outlined},
      {"name": "iPhone", "icon": Icons.phone_iphone},
      {"name": "Araç", "icon": Icons.directions_car},
      {"name": "Emlak", "icon": Icons.home},
      {"name": "Elektronik", "icon": Icons.devices},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _activeCategoryFilter == cat['name'];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeCategoryFilter = cat['name'] as String;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.darkGreen : AppColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: isSelected ? AppColors.accent : AppColors.surfaceLight,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        cat['icon'] as IconData,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cat['name'] as String,
                  style: TextStyle(
                    fontFamily: 'DINPro',
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.accent : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListingCard(ListingModel item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ListingDetailScreen(listing: item)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: AppColors.surfaceLight, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Favorite Toggle
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: GestureDetector(
                      onTap: () => _firebaseService.toggleListingFavorite(item.id),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white.withOpacity(0.9),
                        child: Icon(
                          item.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: item.isFavorite ? Colors.red : AppColors.textSecondary,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'DINPro',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${item.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} TL",
                        style: const TextStyle(
                          fontFamily: 'DINPro',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.category,
                          style: const TextStyle(fontSize: 8, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: SEARCH ---
  Widget _buildSearchTab(List<ListingModel> listings) {
    final activeListings = listings.where((l) => l.isActive).toList();
    final searchResults = _searchQuery.isEmpty
        ? activeListings
        : activeListings.where((l) {
            return l.title.toLowerCase().contains(_searchQuery) ||
                l.description.toLowerCase().contains(_searchQuery) ||
                l.category.toLowerCase().contains(_searchQuery);
          }).toList();

    return Column(
      children: [
        // Search text field
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: "Ürün, marka veya kategori arayın...",
              hintStyle: const TextStyle(color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
            ),
          ),
        ),
        // Results
        Expanded(
          child: searchResults.isEmpty
              ? _buildEmptyState("Aradığınız kriterde ilan bulunamadı.")
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    return _buildListingCard(searchResults[index]);
                  },
                ),
        ),
      ],
    );
  }

  // --- TAB 2: ADD LISTING ---
  Widget _buildAddListingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Yeni İlan Oluştur",
              style: TextStyle(fontFamily: 'DINPro', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              "Çalışma arkadaşlarınıza satmak istediğiniz ürünün detaylarını giriniz.",
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // Form Title
            CustomTextField(
              controller: _titleController,
              hintText: "Örn: Tertemiz iPhone 13 Pro",
              labelText: "İlan Başlığı",
              prefixIcon: Icons.title,
              validator: (val) => val == null || val.trim().isEmpty ? "Başlık gereklidir." : null,
            ),
            const SizedBox(height: 16),

            // Category & Price
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Kategori",
                        style: TextStyle(fontFamily: 'DINPro', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.surfaceLight, width: 1.5),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            dropdownColor: Colors.white,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: "iPhone", child: Text("iPhone / Telefon")),
                              DropdownMenuItem(value: "Araç", child: Text("Araç / Otomobil")),
                              DropdownMenuItem(value: "Emlak", child: Text("Emlak / Konut")),
                              DropdownMenuItem(value: "Elektronik", child: Text("Elektronik")),
                              DropdownMenuItem(value: "Genel", child: Text("Diğer")),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedCategory = val;
                                  // Update image preset to match
                                  if (val == "iPhone") _selectedPresetImage = "phone";
                                  else if (val == "Araç") _selectedPresetImage = "car";
                                  else if (val == "Emlak") _selectedPresetImage = "realestate";
                                  else if (val == "Elektronik") _selectedPresetImage = "electronics";
                                  else _selectedPresetImage = "other";
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _priceController,
                    hintText: "Örn: 24500",
                    labelText: "Fiyat (TL)",
                    prefixIcon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return "Fiyat gereklidir.";
                      if (double.tryParse(val.trim()) == null) return "Geçersiz fiyat.";
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            CustomTextField(
              controller: _descController,
              hintText: "Ürünün durumu, özellikleri, garanti süresi vb...",
              labelText: "Açıklama",
              maxLines: 4,
              validator: (val) => val == null || val.trim().isEmpty ? "Açıklama gereklidir." : null,
            ),
            const SizedBox(height: 20),

            // Preset Image picker
            const Text(
              "Ürün Fotoğrafı (Örnek Görsel Seçin)",
              style: TextStyle(fontFamily: 'DINPro', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _imagePresets.keys.map((key) {
                final isSelected = _selectedPresetImage == key;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPresetImage = key;
                    });
                  },
                  child: Container(
                    width: 60,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.accent : Colors.transparent,
                        width: 2.0,
                      ),
                      image: DecorationImage(
                        image: NetworkImage(_imagePresets[key]!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Submit Button
            CustomButton(
              text: "İlanı Yayınla",
              width: double.infinity,
              isLoading: _isSubmitting,
              onPressed: _handleCreateListing,
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 3: MY LISTINGS ---
  Widget _buildMyListingsTab(List<ListingModel> listings) {
    final user = _firebaseService.currentUser;
    if (user == null) return const Center(child: Text("Oturum açık değil."));

    final myListings = listings.where((l) => l.sellerId == user.uid).toList();

    if (myListings.isEmpty) {
      return _buildEmptyState("Henüz yayınladığınız bir ilan bulunmuyor.");
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myListings.length,
      itemBuilder: (context, index) {
        final item = myListings[index];
        final isActive = item.isActive;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    item.imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                // Titles
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${item.price.toInt()} TL",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkGreen),
                      ),
                      const SizedBox(height: 4),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.buttonLight : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isActive ? "Aktif" : "Satıldı",
                          style: TextStyle(
                            fontSize: 9,
                            color: isActive ? AppColors.accent : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Actions
                Column(
                  children: [
                    if (isActive)
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline, color: AppColors.buttonDark),
                        tooltip: "Satıldı İşaretle",
                        onPressed: () => _firebaseService.markListingAsSold(item.id),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      tooltip: "Sil",
                      onPressed: () => _firebaseService.deleteListing(item.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
