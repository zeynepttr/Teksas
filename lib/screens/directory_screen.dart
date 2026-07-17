import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import 'employee_detail_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({Key? key}) : super(key: key);

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _allContacts = [];
  List<UserModel> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    // Start with pre-loaded cache to avoid empty flashing
    _allContacts = _firebaseService.getAllEmployees();
    _filteredContacts = List.from(_allContacts);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = List.from(_allContacts);
      } else {
        _filteredContacts = _allContacts.where((contact) {
          final name = contact.fullName.toLowerCase();
          final title = contact.role.toLowerCase();
          final dept = contact.department.toLowerCase();
          return name.contains(query) || title.contains(query) || dept.contains(query);
        }).toList();
      }
    });
  }

  void _handleCall(String name, String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.phone_in_talk, color: Colors.white),
            const SizedBox(width: 12),
            Text("$name aranıyor: $phone...", style: const TextStyle(fontFamily: 'DINPro')),
          ],
        ),
        backgroundColor: AppColors.buttonDark,
      ),
    );
  }

  void _handleEmail(String name, String email) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.mail_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "$name için e-posta istemcisi başlatılıyor: $email...",
                style: const TextStyle(fontFamily: 'DINPro'),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.darkGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kurumsal Rehber",
          style: TextStyle(fontFamily: 'DINPro', fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: _firebaseService.usersStream,
        initialData: _allContacts,
        builder: (context, snapshot) {
          // Sync allContacts with latest stream updates
          if (snapshot.hasData) {
            _allContacts = snapshot.data!;
            // Apply current search query filter to updated list
            final query = _searchController.text.toLowerCase().trim();
            if (query.isEmpty) {
              _filteredContacts = List.from(_allContacts);
            } else {
              _filteredContacts = _allContacts.where((contact) {
                final name = contact.fullName.toLowerCase();
                final title = contact.role.toLowerCase();
                final dept = contact.department.toLowerCase();
                return name.contains(query) || title.contains(query) || dept.contains(query);
              }).toList();
            }
          }

          return Column(
            children: [
              // Search Input Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: "İsim, birim veya pozisyon arayın...",
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.surfaceLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.surfaceLight, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
                    ),
                  ),
                ),
              ),

              // Search results
              Expanded(
                child: _filteredContacts.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredContacts.length,
                        itemBuilder: (context, index) {
                          final contact = _filteredContacts[index];
                          final name = contact.fullName;
                          final title = contact.role;
                          final phone = contact.phone;
                          final email = contact.email;
                          final department = contact.department;
                          final extension = contact.extension;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EmployeeDetailScreen(employee: contact),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    // Avatar
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: AppColors.accent.withOpacity(0.1),
                                      child: Text(
                                        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'C',
                                        style: const TextStyle(
                                          fontFamily: 'DINPro',
                                          color: AppColors.accent,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Text details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              fontFamily: 'DINPro',
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "$department • $title",
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "Dahili: $extension",
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Action icons
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.mail, color: AppColors.textSecondary, size: 20),
                                          onPressed: () => _handleEmail(name, email),
                                        ),
                                        Container(
                                          width: 1,
                                          height: 20,
                                          color: AppColors.surfaceLight,
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.phone, color: AppColors.accent, size: 20),
                                          onPressed: () => _handleCall(name, phone),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_search_outlined, color: AppColors.textMuted, size: 64),
          const SizedBox(height: 16),
          Text(
            "'${_searchController.text}' için sonuç bulunamadı.",
            style: const TextStyle(
              fontFamily: 'DINPro',
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Yazımı kontrol edebilir veya başka bir kelime deneyebilirsiniz.",
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
