import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/announcement_model.dart';
import '../models/agreement_model.dart';
import '../models/appointment_model.dart';
import '../models/listing_model.dart';
import '../models/payroll_model.dart';
import '../models/leave_request_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _useFirebase = false;
  DatabaseReference? _dbRef;
  
  // Local Database simulation variables
  UserModel? _currentUser;
  final List<UserModel> _localUsers = [];
  final List<AnnouncementModel> _localAnnouncements = [];
  final List<AgreementModel> _localAgreements = [];
  final List<AppointmentModel> _localAppointments = [];
  final List<ListingModel> _localListings = [];
  final List<Map<String, dynamic>> _localNotifications = [];
  final List<PayrollModel> _localPayrolls = [];
  final List<LeaveRequestModel> _localLeaveRequests = [];

  // Stream controllers to push real-time updates to UI
  final _announcementsStreamController = StreamController<List<AnnouncementModel>>.broadcast();
  final _appointmentsStreamController = StreamController<List<AppointmentModel>>.broadcast();
  final _listingsStreamController = StreamController<List<ListingModel>>.broadcast();
  final _notificationsStreamController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _authStreamController = StreamController<UserModel?>.broadcast();
  final _payrollsStreamController = StreamController<List<PayrollModel>>.broadcast();
  final _leaveRequestsStreamController = StreamController<List<LeaveRequestModel>>.broadcast();

  Stream<List<AnnouncementModel>> get announcementsStream => _announcementsStreamController.stream;
  Stream<List<AppointmentModel>> get appointmentsStream => _appointmentsStreamController.stream;
  Stream<List<ListingModel>> get listingsStream => _listingsStreamController.stream;
  Stream<List<Map<String, dynamic>>> get notificationsStream => _notificationsStreamController.stream;
  Stream<UserModel?> get authStateChanges => _authStreamController.stream;
  Stream<List<PayrollModel>> get payrollsStream => _payrollsStreamController.stream;
  Stream<List<LeaveRequestModel>> get leaveRequestsStream => _leaveRequestsStreamController.stream;

  UserModel? get currentUser => _currentUser;

  Future<void> initialize() async {
    try {
      // Check if Firebase is configured in the project
      if (Firebase.apps.isNotEmpty) {
        // Logda görünen kendi veritabanı URL'nizi buraya doğrudan tanımlayarak eşleştiriyoruz:
        const String dbUrl = "https://hane-hackathon-default-rtdb.firebaseio.com/";
        
        _dbRef = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: dbUrl,
        ).ref();
        
        _useFirebase = true;
        debugPrint("Firebase Realtime Database initialized successfully. URL: $dbUrl");
        fetchEmployees();
        _checkAndSeedDatabase();
      } else {
        debugPrint("Firebase not initialized. Falling back to Simulated Realtime Database.");
        _useFirebase = false;
        _setupMockDatabase();
      }
    } catch (e) {
      debugPrint("Error initializing Firebase: $e. Falling back to Simulated Realtime Database.");
      _useFirebase = false;
      _setupMockDatabase();
    }
    
    // Initial fetch to populate streams
    _notifyUpdates();
  }

  Future<void> fetchEmployees() async {
    if (_useFirebase && _dbRef != null) {
      try {
        _dbRef!.child('users').onValue.listen((event) {
          final data = event.snapshot.value;
          final List<UserModel> fbList = [];
          if (data is Map) {
            data.forEach((key, val) {
              if (val is Map) {
                try {
                  fbList.add(UserModel.fromMap(val, key.toString()));
                } catch (e) {
                  debugPrint("Error parsing user $key: $e");
                }
              }
            });
          } else if (data is List) {
            for (int i = 0; i < data.length; i++) {
              final val = data[i];
              if (val is Map) {
                try {
                  fbList.add(UserModel.fromMap(val, i.toString()));
                } catch (e) {
                  debugPrint("Error parsing user at index $i: $e");
                }
              }
            }
          }
          _localUsers.clear();
          _localUsers.addAll(fbList);
          _notifyUpdates();
        });
      } catch (e) {
        debugPrint("Error listening to users: $e");
      }
    }
  }

  Future<void> _checkAndSeedDatabase() async {
    if (!_useFirebase || _dbRef == null) return;
    try {
      final snapshot = await _dbRef!.child('users').once().timeout(const Duration(seconds: 3));
      if (snapshot.snapshot.value == null) {
        debugPrint("Firebase database is empty. Auto-seeding mock database...");
        await seedFirebaseDatabase();
      } else {
        debugPrint("Firebase database has existing data. Auto-seeding skipped.");
      }
    } catch (e) {
      debugPrint("Error checking/seeding Firebase database: $e");
    }
  }

  void _setupMockDatabase() {
    _localUsers.clear();
    _localAnnouncements.clear();
    _localAgreements.clear();
    _localAppointments.clear();
    _localNotifications.clear();
    _localListings.clear();
    _localPayrolls.clear();
    _localLeaveRequests.clear();

    // 1. Populate Users
    _localUsers.addAll([
      UserModel(
        uid: "uid_admin",
        name: "Zeynep",
        surname: "Turan",
        email: "admin@hane.org.tr",
        phone: "+90 555 123 4567",
        bloodGroup: "A Rh+",
        age: 28,
        role: "İK Çalışanı (Admin)",
        joinTimestamp: DateTime.now().subtract(const Duration(days: 830, hours: 2, minutes: 15, seconds: 30)).millisecondsSinceEpoch,
      ),
      UserModel(
        uid: "uid_employee",
        name: "Ahmet",
        surname: "Yılmaz",
        email: "employee@hane.org.tr",
        phone: "+90 532 987 6543",
        bloodGroup: "0 Rh-",
        age: 34,
        role: "İHH Çalışanı",
        joinTimestamp: DateTime.now().subtract(const Duration(days: 432, hours: 4, minutes: 22, seconds: 10)).millisecondsSinceEpoch,
      ),
      UserModel(
        uid: "uid_employee2",
        name: "Merve",
        surname: "Demir",
        email: "merve.demir@hane.org.tr",
        phone: "+90 541 333 4455",
        bloodGroup: "B Rh+",
        age: 26,
        role: "İHH Çalışanı",
        joinTimestamp: DateTime.now().subtract(const Duration(days: 185, hours: 1, minutes: 40, seconds: 15)).millisecondsSinceEpoch,
      ),
    ]);

    // 2. Populate Announcements (Rich data)
    _localAnnouncements.addAll([
      AnnouncementModel(
        id: "ann_1",
        title: "Bölge Saha Toplantısı & Akşam Yemeği 🤝",
        description: "Tüm saha ekiplerimizin katılımıyla gerçekleşecek olan yıllık değerlendirme toplantımız ardından düzenlenecek akşam yemeğine davetlisiniz. Toplantıda yeni dönem saha hedefleri ve lojistik koordinasyonlar ele alınacaktır. Katılımlarınızı bildirmek için 'Katıl' butonunu kullanabilirsiniz.",
        imageUrl: "https://images.unsplash.com/photo-1511578314322-379afb476865?q=80&w=600&auto=format&fit=crop",
        type: "event",
        date: "25 Temmuz 2026, Cumartesi",
        location: "Hane Genel Merkez Konferans Salonu",
        author: "İK Departmanı",
        authorId: "uid_admin",
        timestamp: DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        attendees: {"uid_employee": true},
        status: "approved",
      ),
      AnnouncementModel(
        id: "ann_2",
        title: "Aramıza Yeni Bir Hane Üyesi Katıldı! 👶❤️",
        description: "Dış İlişkiler Birimi'nden Hakan Yılmaz Bey ve değerli eşinin nur topu gibi bir erkek bebekleri dünyaya gelmiştir. Hane ailesi olarak yeni doğan Ömer Asaf bebeğe sağlıklı, huzurlu ve uzun bir ömür dileriz. Tebriklerinizi iletmek için Hakan Bey'e profil rehberinden ulaşabilirsiniz.",
        imageUrl: "https://images.unsplash.com/photo-1519689680058-324335c77eba?q=80&w=600&auto=format&fit=crop",
        type: "celebration",
        date: "16 Temmuz 2026",
        author: "Hakan Yılmaz",
        authorId: "uid_employee",
        timestamp: DateTime.now().subtract(const Duration(days: 3)).millisecondsSinceEpoch,
        status: "approved",
      ),
      AnnouncementModel(
        id: "ann_3",
        title: "Medical Park Hastaneleri İle Yeni İndirim Anlaşması 🏥",
        description: "Çalışanlarımızın esenliği bizim için önemlidir! Medical Park Hastaneler Grubu ile imzaladığımız yeni sağlık protokolü kapsamında, tüm Hane personeli ve birinci derece yakınları ayakta ve yatarak tedavilerde %25 indirim hakkı kazanmıştır. Detaylar 'Ayrıcalıklar' sekmesindedir.",
        imageUrl: "https://images.unsplash.com/photo-1505751172876-fa1923c5c528?q=80&w=600&auto=format&fit=crop",
        type: "agreement",
        date: "15 Temmuz 2026",
        author: "İK Departmanı",
        authorId: "uid_admin",
        timestamp: DateTime.now().subtract(const Duration(days: 4)).millisecondsSinceEpoch,
        status: "approved",
      ),
    ]);

    // 3. Populate Partner Agreements
    _localAgreements.addAll([
      AgreementModel(
        id: "agr_1",
        companyName: "Yemeksepeti",
        category: "Gıda & Restoran",
        discountRate: "%20 İndirim",
        description: "Tüm Hane çalışanlarına özel, Yemeksepeti siparişlerinde geçerli anında %20 indirim kodu. Alt limit 200 TL'dir.",
        code: "HANE20YS",
        logoUrl: "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?q=80&w=300&auto=format&fit=crop",
        isPermanent: false,
        endDate: "2026-08-10",
      ),
      AgreementModel(
        id: "agr_2",
        companyName: "Medical Park Sağlık",
        category: "Sağlık & Medikal",
        discountRate: "%25 Sağlık İndirimi",
        description: "Anlaşmalı Medical Park hastanelerinde muayene, tahlil, tetkik ve ameliyat işlemlerinde Hane personeline ve ailelerine özel %25 indirim fırsatı.",
        code: "HANEMEDICAL25",
        logoUrl: "https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?q=80&w=300&auto=format&fit=crop",
        isPermanent: true,
      ),
      AgreementModel(
        id: "agr_3",
        companyName: "Petrol Ofisi",
        category: "Ulaşım & Akaryakıt",
        discountRate: "%5 Akaryakıt İndirimi",
        description: "Petrol Ofisi mobil uygulamasında kayıtlı Hane Kurumsal Taşıt Tanıma Sistemi ile akaryakıt alımlarında anında %5 indirim avantajı.",
        code: "HANEPO5",
        logoUrl: "https://images.unsplash.com/photo-1610491462702-42e6ecdabaa2?q=80&w=300&auto=format&fit=crop",
        isPermanent: true,
      ),
      AgreementModel(
        id: "agr_4",
        companyName: "MacFit Spor Salonları",
        category: "Yaşam & Spor",
        discountRate: "%15 Üyelik İndirimi",
        description: "Zinde kalmak için MacFit kulüplerine yapılacak yeni üyelik ve yenileme paketlerinde Hane personeline özel %15 ek indirim.",
        code: "HANEMAC15",
        logoUrl: "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=300&auto=format&fit=crop",
        isPermanent: false,
        endDate: "2026-07-10",
      ),
      AgreementModel(
        id: "agr_5",
        companyName: "Starbucks Türkiye",
        category: "Gıda & Restoran",
        discountRate: "1 Kahve Alana 1 Bedava",
        description: "Hafta içi saat 09:00 - 11:00 arasında tüm Starbucks mağazalarında alacağınız ilk kahveye ikincisi Hane daveti olarak hediye!",
        code: "HANESTAR1PLUS1",
        logoUrl: "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?q=80&w=300&auto=format&fit=crop",
        isPermanent: false,
        endDate: "2026-07-25",
      ),
    ]);

    // 4. Populate Appointments
    _localAppointments.add(
      AppointmentModel(
        id: "app_1",
        userId: "uid_employee",
        doctorName: "Psk. Selim Can",
        role: "Kurum Psikoloğu",
        city: "İstanbul",
        date: "20 Temmuz 2026",
        time: "11:00",
        notes: "Yoğun çalışma temposu stresi ve kaygı yönetimi üzerine görüşme.",
      ),
    );

    // 5. Populate Admin Notifications
    _localNotifications.addAll([
      {
        "id": "not_1",
        "type": "post_request",
        "title": "Yeni Paylaşım İsteyi",
        "message": "Ahmet Yılmaz yeni bir düğün davetiyesi paylaşım onayı bekliyor.",
        "itemId": "req_1", // Bu alttaki pending postu işaret edecek
        "timestamp": DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch,
      }
    ]);
    
    // Ve pending durumunda bir request ekleyelim
    _localAnnouncements.add(
      AnnouncementModel(
        id: "req_1",
        title: "Merve & Ömer Evleniyor! 💍👰",
        description: "Hayatımızı birleştireceğimiz bu mutlu günde, siz değerli Hane ailesini ve tüm çalışma arkadaşlarımızı aramızda görmekten mutluluk duyarız. Nikah törenimiz Beşiktaş Evlendirme Dairesi'nde gerçekleştirilecektir.",
        imageUrl: "https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8?q=80&w=600&auto=format&fit=crop",
        type: "wedding",
        date: "01 Ağustos 2026, Pazar 15:30",
        location: "Ihlamur Kasrı Nikah Salonu, Beşiktaş",
        author: "Merve Demir",
        authorId: "uid_employee2",
        timestamp: DateTime.now().millisecondsSinceEpoch,
        status: "pending",
      )
    );

    // 6. Populate Marketplace Listings (Aramızda)
    _localListings.addAll([
      ListingModel(
        id: "list_1",
        title: "Donanımlı, Bakımlı Egea Cross 🚗",
        description: "2022 model, 24.500 km'de. Boyasız, hatasız, tüm bakımları yetkili serviste yapılmıştır. Şerit takip, geri görüş kamerası, carplay mevcuttur. Pazarlık payı vardır.",
        price: 820000.0,
        category: "Araç",
        imageUrl: "https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?q=80&w=600&auto=format&fit=crop",
        sellerId: "uid_employee",
        sellerName: "Ahmet Yılmaz",
        sellerPhone: "+90 532 987 6543",
        timestamp: DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch,
        status: "active",
      ),
      ListingModel(
        id: "list_2",
        title: "Bilecik Bahçelievler Daire 3+1 Daire 🏢",
        description: "Bilecik Bahçelievler Mahallesinde sıfır binada, lüks yapılı, ebeveyn banyolu, asansörlü, kapalı otoparklı, ferah güney cephe 3+1 daire satılıktır. İHH çalışanlarına özel fiyattır.",
        price: 2100000.0,
        category: "Emlak",
        imageUrl: "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?q=80&w=600&auto=format&fit=crop",
        sellerId: "uid_employee2",
        sellerName: "Merve Demir",
        sellerPhone: "+90 541 333 4455",
        timestamp: DateTime.now().subtract(const Duration(days: 5)).millisecondsSinceEpoch,
        status: "active",
      ),
      ListingModel(
        id: "list_3",
        title: "iPhone 14 Pro Max 128 GB 📱",
        description: "Kozmetik olarak 10/10 durumdadır. Pil sağlığı %88, garantisi 3 ay önce bitti. Kutu, fatura ve orijinal şarj kablosu ile birlikte teslim edilecektir. Takas düşünmüyorum.",
        price: 42500.0,
        category: "iPhone",
        imageUrl: "https://images.unsplash.com/photo-1510557880182-3d4d3cba35a5?q=80&w=600&auto=format&fit=crop",
        sellerId: "uid_admin",
        sellerName: "Zeynep Turan",
        sellerPhone: "+90 555 123 4567",
        timestamp: DateTime.now().subtract(const Duration(hours: 12)).millisecondsSinceEpoch,
        status: "active",
      ),
      ListingModel(
        id: "list_4",
        title: "Nespresso Essenza Mini C30 Kahve Makinesi ☕",
        description: "Çok az kullanıldı, sıfırdan farksızdır. Kutusu ve kitapçıkları duruyor. Yanında 2 kutu orijinal kapsül hediye olarak verilecektir.",
        price: 4500.0,
        category: "Elektronik",
        imageUrl: "https://images.unsplash.com/photo-1517256064527-09c53b2d0bc6?q=80&w=600&auto=format&fit=crop",
        sellerId: "uid_employee",
        sellerName: "Ahmet Yılmaz",
        sellerPhone: "+90 532 987 6543",
        timestamp: DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        status: "active",
      ),
    ]);

    // 7. Populate Payrolls
    _localPayrolls.addAll([
      PayrollModel(
        id: "pay_1",
        userId: "uid_employee",
        userName: "Ahmet Yılmaz",
        month: "Temmuz",
        year: 2026,
        netSalary: 42500.0,
        allowances: 4500.0,
        deductions: 1800.0,
        status: "Paid",
      ),
      PayrollModel(
        id: "pay_2",
        userId: "uid_employee",
        userName: "Ahmet Yılmaz",
        month: "Haziran",
        year: 2026,
        netSalary: 42500.0,
        allowances: 3000.0,
        deductions: 1800.0,
        status: "Paid",
      ),
      PayrollModel(
        id: "pay_3",
        userId: "uid_employee2",
        userName: "Merve Demir",
        month: "Temmuz",
        year: 2026,
        netSalary: 38000.0,
        allowances: 5000.0,
        deductions: 1500.0,
        status: "Paid",
      ),
    ]);

    // 8. Populate Leave Requests
    _localLeaveRequests.addAll([
      LeaveRequestModel(
        id: "leave_1",
        userId: "uid_employee",
        userName: "Ahmet Yılmaz",
        leaveType: "Yıllık İzin",
        startDate: "2026-06-10",
        endDate: "2026-06-15",
        durationDays: 5,
        reason: "Yaz tatili planı",
        status: "approved",
        timestamp: DateTime.now().subtract(const Duration(days: 40)).millisecondsSinceEpoch,
      ),
      LeaveRequestModel(
        id: "leave_2",
        userId: "uid_employee2",
        userName: "Merve Demir",
        leaveType: "Sağlık İzni",
        startDate: "2026-07-05",
        endDate: "2026-07-07",
        durationDays: 2,
        reason: "Diş tedavi",
        status: "approved",
        timestamp: DateTime.now().subtract(const Duration(days: 12)).millisecondsSinceEpoch,
      ),
      LeaveRequestModel(
        id: "leave_3",
        userId: "uid_employee",
        userName: "Ahmet Yılmaz",
        leaveType: "Mazeret İzni",
        startDate: "2026-08-01",
        endDate: "2026-08-04",
        durationDays: 3,
        reason: "Aile ziyareti",
        status: "pending",
        timestamp: DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
      ),
    ]);
  }

  void _notifyUpdates() {
    // Push updates to streams
    _announcementsStreamController.add(
      _localAnnouncements.where((a) => a.status == 'approved').toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp))
    );
    
    if (_currentUser != null) {
      _appointmentsStreamController.add(
        _localAppointments.where((a) => a.userId == _currentUser!.uid).toList()
      );
    }

    _listingsStreamController.add(
      _localListings.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp))
    );
    
    // Payroll stream updates
    if (_currentUser != null) {
      if (_currentUser!.isAdmin) {
        _payrollsStreamController.add(_localPayrolls.toList()..sort((a, b) => b.year == a.year ? b.month.compareTo(a.month) : b.year.compareTo(a.year)));
      } else {
        _payrollsStreamController.add(_localPayrolls.where((p) => p.userId == _currentUser!.uid).toList()..sort((a, b) => b.year == a.year ? b.month.compareTo(a.month) : b.year.compareTo(a.year)));
      }
    } else {
      _payrollsStreamController.add([]);
    }

    // Leave request stream updates
    if (_currentUser != null) {
      if (_currentUser!.isAdmin) {
        _leaveRequestsStreamController.add(_localLeaveRequests.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp)));
      } else {
        _leaveRequestsStreamController.add(_localLeaveRequests.where((l) => l.userId == _currentUser!.uid).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp)));
      }
    } else {
      _leaveRequestsStreamController.add([]);
    }
    
    _notificationsStreamController.add(_localNotifications);
    _authStreamController.add(_currentUser);
  }

  // --- AUTHENTICATION ---
  
  Future<UserModel?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate network latency
    
    if (_useFirebase) {
      // Real firebase auth can be simulated here
      // Standard Firebase DB query to fetch matching user email
      try {
        final event = await _dbRef!.child('users').once().timeout(const Duration(seconds: 3));
        final data = event.snapshot.value;
        String? foundId;
        Map? foundData;
        
        if (data is Map) {
          data.forEach((key, val) {
            if (val is Map && val['email'] == email) {
              foundId = key.toString();
              foundData = val;
            }
          });
        } else if (data is List) {
          for (int i = 0; i < data.length; i++) {
            final val = data[i];
            if (val is Map && val['email'] == email) {
              foundId = i.toString();
              foundData = val;
            }
          }
        }

        if (foundId != null && foundData != null) {
          _currentUser = UserModel.fromMap(foundData!, foundId!);
          _notifyUpdates();
          return _currentUser;
        }
      } catch (e) {
        debugPrint("Firebase Login Error: $e. Falling back to local search.");
      }
    }
    
    // Local fallback
    try {
      final user = _localUsers.firstWhere(
        (u) => u.email.toLowerCase().trim() == email.toLowerCase().trim(),
      );
      // Simulating a simple correct password (any password length > 4 is valid for mock)
      if (password.length >= 6) {
        _currentUser = user;
        
        // Save to SharedPreferences for session persistence
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_uid', _currentUser!.uid);
        
        _notifyUpdates();
        return _currentUser;
      } else {
        throw Exception("Şifre en az 6 karakter olmalıdır.");
      }
    } catch (e) {
      throw Exception("Hatalı e-posta adresi veya şifre!");
    }
  }

  Future<UserModel?> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('session_uid');
    if (uid != null) {
      try {
        _currentUser = _localUsers.firstWhere((u) => u.uid == uid);
        _notifyUpdates();
        return _currentUser;
      } catch (_) {}
    }
    return null;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_uid');
    _notifyUpdates();
  }

  // --- PROFILE UPDATE ---

  Future<void> updateProfile({
    required String name,
    required String surname,
    required String phone,
    required String bloodGroup,
    required int age,
  }) async {
    if (_currentUser == null) return;
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    final updatedUser = _currentUser!.copyWith(
      name: name,
      surname: surname,
      phone: phone,
      bloodGroup: bloodGroup,
      age: age,
    );

    // Save profile change locally
    final userIdx = _localUsers.indexWhere((u) => u.uid == _currentUser!.uid);
    if (userIdx != -1) {
      _localUsers[userIdx] = updatedUser;
    }
    
    // Create an Admin Notification log of this change
    if (!_currentUser!.isAdmin) {
      final notificationId = const Uuid().v4();
      final logMsg = {
        "id": notificationId,
        "type": "profile_update",
        "title": "Profil Güncelleme Bildirimi",
        "message": "${_currentUser!.fullName} profil bilgilerini güncelledi. (Telefon: $phone, Kan Grubu: $bloodGroup, Yaş: $age)",
        "userId": _currentUser!.uid,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      };
      
      _localNotifications.insert(0, logMsg);
      
      if (_useFirebase) {
        await _dbRef!.child('admin_notifications').child(notificationId).set(logMsg);
      }
    }

    _currentUser = updatedUser;
    
    if (_useFirebase) {
      await _dbRef!.child('users').child(_currentUser!.uid).update(updatedUser.toMap());
    }

    _notifyUpdates();
  }

  // --- ANNOUNCEMENTS ---

  Future<void> getAnnouncements() async {
    if (_useFirebase) {
      try {
        _dbRef!.child('announcements').onValue.listen((event) {
          final data = event.snapshot.value;
          if (data is Map) {
            final List<AnnouncementModel> fbList = [];
            data.forEach((key, value) {
              if (value is Map) {
                fbList.add(AnnouncementModel.fromMap(value, key.toString()));
              }
            });
            _localAnnouncements.clear();
            _localAnnouncements.addAll(fbList);
            _notifyUpdates();
          }
        });
        return;
      } catch (e) {
        debugPrint("Error fetching announcements from Firebase: $e");
      }
    }
    _notifyUpdates();
  }

  Future<void> submitAnnouncementRequest({
    required String title,
    required String description,
    required String type,
    String? date,
    String? location,
    String? imageUrl,
  }) async {
    if (_currentUser == null) return;
    
    await Future.delayed(const Duration(milliseconds: 500));
    final requestId = const Uuid().v4();
    
    final newRequest = AnnouncementModel(
      id: requestId,
      title: title,
      description: description,
      type: type,
      imageUrl: imageUrl ?? "https://images.unsplash.com/photo-1517457373958-b7bdd4587205?q=80&w=600&auto=format&fit=crop",
      date: date,
      location: location,
      author: _currentUser!.fullName,
      authorId: _currentUser!.uid,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      status: "pending",
    );

    _localAnnouncements.add(newRequest);
    
    // Notify admin
    final notifId = const Uuid().v4();
    final notif = {
      "id": notifId,
      "type": "post_request",
      "title": "Yeni Paylaşım İsteyi",
      "message": "${_currentUser!.fullName} yeni bir paylaşım için onay bekliyor: '$title'",
      "itemId": requestId,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };
    
    _localNotifications.insert(0, notif);

    if (_useFirebase) {
      await _dbRef!.child('announcements').child(requestId).set(newRequest.toMap());
      await _dbRef!.child('admin_notifications').child(notifId).set(notif);
    }
    
    _notifyUpdates();
  }

  Future<void> joinEvent(String announcementId) async {
    if (_currentUser == null) return;
    
    final idx = _localAnnouncements.indexWhere((a) => a.id == announcementId);
    if (idx != -1) {
      final announcement = _localAnnouncements[idx];
      final currentAttendees = Map<String, bool>.from(announcement.attendees);
      
      // Toggle join status
      final isJoining = !(currentAttendees[_currentUser!.uid] ?? false);
      currentAttendees[_currentUser!.uid] = isJoining;
      
      final updatedAnnouncement = announcement.copyWith(attendees: currentAttendees);
      _localAnnouncements[idx] = updatedAnnouncement;
      
      if (_useFirebase) {
        await _dbRef!
            .child('announcements')
            .child(announcementId)
            .child('attendees')
            .update({_currentUser!.uid: isJoining});
      }
      
      _notifyUpdates();
    }
  }

  // --- ADMIN METHODS ---

  Future<List<AnnouncementModel>> getPendingAnnouncementRequests() async {
    return _localAnnouncements.where((a) => a.status == 'pending').toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> approveAnnouncement(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _localAnnouncements.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final updated = _localAnnouncements[idx].copyWith(status: 'approved');
      _localAnnouncements[idx] = updated;

      if (_useFirebase) {
        await _dbRef!.child('announcements').child(id).update({'status': 'approved'});
      }
      
      // Remove corresponding request notification if it exists
      _localNotifications.removeWhere((notif) => notif['itemId'] == id);
      
      _notifyUpdates();
    }
  }

  Future<void> rejectAnnouncement(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _localAnnouncements.removeWhere((a) => a.id == id);
    
    if (_useFirebase) {
      await _dbRef!.child('announcements').child(id).remove();
    }
    
    // Remove notification
    _localNotifications.removeWhere((notif) => notif['itemId'] == id);
    
    _notifyUpdates();
  }

  Future<void> clearAdminNotification(String notifId) async {
    _localNotifications.removeWhere((notif) => notif['id'] == notifId);
    
    if (_useFirebase) {
      await _dbRef!.child('admin_notifications').child(notifId).remove();
    }
    
    _notifyUpdates();
  }

  // --- PARTNER AGREEMENTS ---

  Future<List<AgreementModel>> getAgreements() async {
    if (_useFirebase) {
      try {
        final snapshot = await _dbRef!.child('partner_agreements').once();
        final data = snapshot.snapshot.value;
        final List<AgreementModel> fbList = [];
        bool needsMigration = false;
        
        if (data is Map) {
          data.forEach((key, value) {
            if (value is Map) {
              final model = AgreementModel.fromMap(value, key.toString());
              fbList.add(model);
              if (value['isPermanent'] == null) {
                needsMigration = true;
              }
            }
          });
        } else if (data is List) {
          for (int i = 0; i < data.length; i++) {
            final value = data[i];
            if (value is Map) {
              final model = AgreementModel.fromMap(value, i.toString());
              fbList.add(model);
              if (value['isPermanent'] == null) {
                needsMigration = true;
              }
            }
          }
        }
        
        if (fbList.isNotEmpty) {
          _localAgreements.clear();
          _localAgreements.addAll(fbList);
          
          if (needsMigration) {
            debugPrint("Migrating partner agreements in Firebase...");
            for (var agreement in fbList) {
              await _dbRef!.child('partner_agreements').child(agreement.id).set(agreement.toMap());
            }
          }
        }
      } catch (e) {
        debugPrint("Error fetching agreements: $e");
      }
    }
    return _localAgreements;
  }

  // --- APPOINTMENTS ---

  Future<void> getAppointments() async {
    if (_currentUser == null) return;
    if (_useFirebase) {
      try {
        _dbRef!
            .child('appointments')
            .orderByChild('userId')
            .equalTo(_currentUser!.uid)
            .onValue
            .listen((event) {
          final data = event.snapshot.value;
          if (data is Map) {
            final List<AppointmentModel> fbList = [];
            data.forEach((key, value) {
              if (value is Map) {
                fbList.add(AppointmentModel.fromMap(value, key.toString()));
              }
            });
            _localAppointments.removeWhere((a) => a.userId == _currentUser!.uid);
            _localAppointments.addAll(fbList);
            _notifyUpdates();
          }
        });
        return;
      } catch (e) {
        debugPrint("Error fetching appointments: $e");
      }
    }
    _notifyUpdates();
  }

  Future<void> bookAppointment({
    required String doctorName,
    required String role,
    required String city,
    required String date,
    required String time,
    String? notes,
  }) async {
    if (_currentUser == null) return;
    
    await Future.delayed(const Duration(milliseconds: 600));
    final appId = const Uuid().v4();
    
    final newAppointment = AppointmentModel(
      id: appId,
      userId: _currentUser!.uid,
      doctorName: doctorName,
      role: role,
      city: city,
      date: date,
      time: time,
      notes: notes,
      status: 'scheduled',
    );

    _localAppointments.add(newAppointment);
    
    if (_useFirebase) {
      await _dbRef!.child('appointments').child(appId).set(newAppointment.toMap());
    }
    
    _notifyUpdates();
  }

  // --- MARKETPLACE LISTINGS (ARAMIZDA) ---

  Future<void> getListings() async {
    if (_useFirebase) {
      try {
        _dbRef!.child('marketplace_listings').onValue.listen((event) {
          final data = event.snapshot.value;
          if (data is Map) {
            final List<ListingModel> fbList = [];
            data.forEach((key, value) {
              if (value is Map) {
                fbList.add(ListingModel.fromMap(value, key.toString()));
              }
            });
            _localListings.clear();
            _localListings.addAll(fbList);
            _notifyUpdates();
          }
        });
        return;
      } catch (e) {
        debugPrint("Error fetching listings from Firebase: $e");
      }
    }
    _notifyUpdates();
  }

  Future<void> createListing({
    required String title,
    required String description,
    required double price,
    required String category,
    String? imageUrl,
  }) async {
    if (_currentUser == null) return;
    
    await Future.delayed(const Duration(milliseconds: 600));
    final listingId = const Uuid().v4();
    
    final newListing = ListingModel(
      id: listingId,
      title: title,
      description: description,
      price: price,
      category: category,
      imageUrl: imageUrl ?? "https://images.unsplash.com/photo-1549399542-7e3f8b79c341?q=80&w=400&auto=format&fit=crop",
      sellerId: _currentUser!.uid,
      sellerName: _currentUser!.fullName,
      sellerPhone: _currentUser!.phone,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      status: "active",
    );

    _localListings.add(newListing);
    
    if (_useFirebase) {
      await _dbRef!.child('marketplace_listings').child(listingId).set(newListing.toMap());
    }
    
    _notifyUpdates();
  }

  Future<void> markListingAsSold(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _localListings.indexWhere((l) => l.id == id);
    if (idx != -1) {
      final updated = _localListings[idx].copyWith(status: 'sold');
      _localListings[idx] = updated;

      if (_useFirebase) {
        await _dbRef!.child('marketplace_listings').child(id).update({'status': 'sold'});
      }
      
      _notifyUpdates();
    }
  }

  Future<void> deleteListing(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _localListings.removeWhere((l) => l.id == id);
    
    if (_useFirebase) {
      await _dbRef!.child('marketplace_listings').child(id).remove();
    }
    
    _notifyUpdates();
  }

  Future<void> toggleListingFavorite(String id) async {
    final idx = _localListings.indexWhere((l) => l.id == id);
    if (idx != -1) {
      final updated = _localListings[idx].copyWith(isFavorite: !_localListings[idx].isFavorite);
      _localListings[idx] = updated;
      _notifyUpdates();
    }
  }

  // --- CORPORATE DIRECTORY ---

  List<Map<String, String>> getDirectoryContacts() {
    return [
      {"name": "Mehmet Zahit Bal", "title": "İHH İnsan Kaynakları Koordinatörü", "phone": "+90 555 111 2233", "email": "m.zahitbal@ihh.org.tr"},
      {"name": "Zeynep Turan", "title": "İK Uzmanı (Admin)", "phone": "+90 555 123 4567", "email": "zeynep@hane.org.tr"},
      {"name": "Hakan Yılmaz", "title": "Dış İlişkiler Sorumlusu", "phone": "+90 532 987 6543", "email": "hakan.yilmaz@ihh.org.tr"},
      {"name": "Dr. Ayşe Yılmaz", "title": "İş Yeri Hekimi", "phone": "+90 533 444 5566", "email": "ayse.yilmaz@ihh.org.tr"},
      {"name": "Psk. Selim Can", "title": "Kurum Psikoloğu", "phone": "+90 544 555 6677", "email": "selim.can@ihh.org.tr"},
      {"name": "Ahmet Yılmaz", "title": "Saha Operasyon Lideri", "phone": "+90 532 987 6543", "email": "employee@hane.org.tr"},
      {"name": "Merve Demir", "title": "Saha Operasyon Sorumlusu", "phone": "+90 541 333 4455", "email": "merve.demir@hane.org.tr"},
      {"name": "Kemal Kaya", "title": "Bilgi Teknolojileri Müdürü", "phone": "+90 505 666 7788", "email": "kemal.kaya@ihh.org.tr"},
    ];
  }

  /// Bu metot, mock veritabanındaki tüm verileri Firebase Realtime Database'e yükler.
  /// Sadece bir kez (uygulama kurulumunda veya test aşamasında) çalıştırılmalıdır.
  Future<void> seedFirebaseDatabase() async {
    if (!_useFirebase || _dbRef == null) {
      debugPrint("Hata: Firebase bağlı değil veya başlatılamadı. Veri yükleme iptal edildi.");
      return;
    }

    try {
      debugPrint("Firebase'e veri yükleme işlemi başlatılıyor...");

      // Önce mock verilerin bellekte hazır olduğundan emin olmak için kuruyoruz
      _localUsers.clear();
      _localAnnouncements.clear();
      _localAgreements.clear();
      _localAppointments.clear();
      _localNotifications.clear();
      _localListings.clear();
      _localPayrolls.clear();
      _localLeaveRequests.clear();
      _setupMockDatabase();

      // 1. Kullanıcıları Yükle (users)
      for (var user in _localUsers) {
        await _dbRef!.child('users').child(user.uid).set(user.toMap());
      }
      debugPrint("✓ Kullanıcılar yüklendi.");

      // 2. Duyuruları Yükle (announcements)
      for (var announcement in _localAnnouncements) {
        await _dbRef!.child('announcements').child(announcement.id).set(announcement.toMap());
      }
      debugPrint("✓ Duyurular yüklendi.");

      // 3. Anlaşmaları Yükle (partner_agreements)
      for (var agreement in _localAgreements) {
        await _dbRef!.child('partner_agreements').child(agreement.id).set(agreement.toMap());
      }
      debugPrint("✓ Anlaşmalar yüklendi.");

      // 4. Randevuları Yükle (appointments)
      for (var appointment in _localAppointments) {
        await _dbRef!.child('appointments').child(appointment.id).set(appointment.toMap());
      }
      debugPrint("✓ Randevular yüklendi.");

      // 5. Bildirimleri Yükle (admin_notifications)
      for (var notif in _localNotifications) {
        final id = notif['id'] ?? const Uuid().v4();
        await _dbRef!.child('admin_notifications').child(id).set(notif);
      }
      debugPrint("✓ Bildirimler yüklendi.");

      // 6. İlanları Yükle (marketplace_listings)
      for (var listing in _localListings) {
        await _dbRef!.child('marketplace_listings').child(listing.id).set(listing.toMap());
      }
      debugPrint("✓ İkinci el ilanlar yüklendi.");

      // 7. Bordroları Yükle (payrolls)
      for (var payroll in _localPayrolls) {
        await _dbRef!.child('payrolls').child(payroll.id).set(payroll.toMap());
      }
      debugPrint("✓ Bordrolar yüklendi.");

      // 8. İzin Taleplerini Yükle (leave_requests)
      for (var request in _localLeaveRequests) {
        await _dbRef!.child('leave_requests').child(request.id).set(request.toMap());
      }
      debugPrint("✓ İzin talepleri yüklendi.");

      debugPrint("🎉 Tüm mock veriler başarıyla Firebase Realtime Database'e aktarıldı!");
    } catch (e) {
      debugPrint("Veri aktarımı sırasında hata oluştu: $e");
    }
  }

  // --- CRM / EMPLOYEE MANAGEMENT ---

  List<UserModel> getAllEmployees() {
    return _localUsers.where((u) => u.uid != 'uid_admin').toList();
  }

  Future<void> addEmployee(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _localUsers.add(user);
    if (_useFirebase) {
      try {
        await _dbRef!.child('users').child(user.uid).set(user.toMap());
      } catch (e) {
        debugPrint("Error writing new user to Firebase: $e");
      }
    }
    _notifyUpdates();
  }

  Future<void> updateEmployee(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _localUsers.indexWhere((u) => u.uid == user.uid);
    if (idx != -1) {
      _localUsers[idx] = user;
    }
    if (_useFirebase) {
      try {
        await _dbRef!.child('users').child(user.uid).set(user.toMap());
      } catch (e) {
        debugPrint("Error updating user on Firebase: $e");
      }
    }
    _notifyUpdates();
  }

  // --- PAYROLL METHODS ---

  Future<void> getPayrolls() async {
    _notifyUpdates();
    if (_useFirebase) {
      try {
        _dbRef!.child('payrolls').onValue.listen((event) {
          final data = event.snapshot.value;
          final List<PayrollModel> fbList = [];
          if (data is Map) {
            data.forEach((key, val) {
              if (val is Map) {
                try {
                  fbList.add(PayrollModel.fromMap(val, key.toString()));
                } catch (e) {
                  debugPrint("Error parsing payroll $key: $e");
                }
              }
            });
          } else if (data is List) {
            for (int i = 0; i < data.length; i++) {
              final val = data[i];
              if (val is Map) {
                try {
                  fbList.add(PayrollModel.fromMap(val, i.toString()));
                } catch (e) {
                  debugPrint("Error parsing payroll at index $i: $e");
                }
              }
            }
          }
          _localPayrolls.clear();
          _localPayrolls.addAll(fbList);
          _notifyUpdates();
        }, onError: (err) {
          debugPrint("Firebase payrolls listener error: $err");
          _notifyUpdates();
        });
      } catch (e) {
        debugPrint("Error reading payrolls from Firebase: $e");
      }
    }
  }

  Future<void> addPayroll(PayrollModel payroll) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _localPayrolls.add(payroll);
    if (_useFirebase) {
      try {
        await _dbRef!.child('payrolls').child(payroll.id).set(payroll.toMap());
      } catch (e) {
        debugPrint("Error writing payroll to Firebase: $e");
      }
    }
    _notifyUpdates();
  }

  // --- LEAVE REQUEST METHODS ---

  Future<void> getLeaveRequests() async {
    _notifyUpdates();
    if (_useFirebase) {
      try {
        _dbRef!.child('leave_requests').onValue.listen((event) {
          final data = event.snapshot.value;
          final List<LeaveRequestModel> fbList = [];
          if (data is Map) {
            data.forEach((key, val) {
              if (val is Map) {
                try {
                  fbList.add(LeaveRequestModel.fromMap(val, key.toString()));
                } catch (e) {
                  debugPrint("Error parsing leave request $key: $e");
                }
              }
            });
          } else if (data is List) {
            for (int i = 0; i < data.length; i++) {
              final val = data[i];
              if (val is Map) {
                try {
                  fbList.add(LeaveRequestModel.fromMap(val, i.toString()));
                } catch (e) {
                  debugPrint("Error parsing leave request at index $i: $e");
                }
              }
            }
          }
          _localLeaveRequests.clear();
          _localLeaveRequests.addAll(fbList);
          _notifyUpdates();
        }, onError: (err) {
          debugPrint("Firebase leave_requests listener error: $err");
          _notifyUpdates();
        });
      } catch (e) {
        debugPrint("Error reading leave_requests from Firebase: $e");
      }
    }
  }

  Future<void> submitLeaveRequest({
    required String leaveType,
    required String startDate,
    required String endDate,
    required int durationDays,
    required String reason,
  }) async {
    if (_currentUser == null) return;
    await Future.delayed(const Duration(milliseconds: 500));
    
    final id = "leave_" + const Uuid().v4();
    final newRequest = LeaveRequestModel(
      id: id,
      userId: _currentUser!.uid,
      userName: _currentUser!.fullName,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      durationDays: durationDays,
      reason: reason,
      status: "pending",
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    _localLeaveRequests.add(newRequest);

    // Add notification to admin logs
    final notifId = "notif_" + const Uuid().v4();
    final notif = {
      'id': notifId,
      'title': 'İzin Talebi',
      'message': '${_currentUser!.fullName} ($leaveType) için $durationDays gün izin talebinde bulundu. Gerekçe: $reason',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'type': 'leave_request',
    };
    _localNotifications.insert(0, notif);

    if (_useFirebase) {
      try {
        await _dbRef!.child('leave_requests').child(id).set(newRequest.toMap());
        await _dbRef!.child('admin_notifications').child(notifId).set(notif);
      } catch (e) {
        debugPrint("Error submitting leave request to Firebase: $e");
      }
    }
    _notifyUpdates();
  }

  Future<void> approveLeaveRequest(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _localLeaveRequests.indexWhere((l) => l.id == id);
    if (idx != -1) {
      final updated = _localLeaveRequests[idx].copyWith(status: "approved");
      _localLeaveRequests[idx] = updated;

      if (_useFirebase) {
        try {
          await _dbRef!.child('leave_requests').child(id).child('status').set('approved');
        } catch (e) {
          debugPrint("Error approving leave request on Firebase: $e");
        }
      }
    }
    _notifyUpdates();
  }

  Future<void> rejectLeaveRequest(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _localLeaveRequests.indexWhere((l) => l.id == id);
    if (idx != -1) {
      final updated = _localLeaveRequests[idx].copyWith(status: "rejected");
      _localLeaveRequests[idx] = updated;

      if (_useFirebase) {
        try {
          await _dbRef!.child('leave_requests').child(id).child('status').set('rejected');
        } catch (e) {
          debugPrint("Error rejecting leave request on Firebase: $e");
        }
      }
    }
    _notifyUpdates();
  }
}