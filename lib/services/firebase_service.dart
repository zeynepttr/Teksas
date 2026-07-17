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
  final List<Map<String, dynamic>> _localNotifications = [];

  // Stream controllers to push real-time updates to UI
  final _announcementsStreamController = StreamController<List<AnnouncementModel>>.broadcast();
  final _appointmentsStreamController = StreamController<List<AppointmentModel>>.broadcast();
  final _notificationsStreamController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _authStreamController = StreamController<UserModel?>.broadcast();

  Stream<List<AnnouncementModel>> get announcementsStream => _announcementsStreamController.stream;
  Stream<List<AppointmentModel>> get appointmentsStream => _appointmentsStreamController.stream;
  Stream<List<Map<String, dynamic>>> get notificationsStream => _notificationsStreamController.stream;
  Stream<UserModel?> get authStateChanges => _authStreamController.stream;

  UserModel? get currentUser => _currentUser;

  Future<void> initialize() async {
    try {
      // Check if Firebase is configured in the project
      if (Firebase.apps.isNotEmpty) {
        _dbRef = FirebaseDatabase.instance.ref();
        _useFirebase = true;
        debugPrint("Firebase Realtime Database initialized successfully.");
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

  void _setupMockDatabase() {
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
      ),
      AgreementModel(
        id: "agr_2",
        companyName: "Medical Park Sağlık",
        category: "Sağlık & Medikal",
        discountRate: "%25 Sağlık İndirimi",
        description: "Anlaşmalı Medical Park hastanelerinde muayene, tahlil, tetkik ve ameliyat işlemlerinde Hane personeline ve ailelerine özel %25 indirim fırsatı.",
        code: "HANEMEDICAL25",
        logoUrl: "https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?q=80&w=300&auto=format&fit=crop",
      ),
      AgreementModel(
        id: "agr_3",
        companyName: "Petrol Ofisi",
        category: "Ulaşım & Akaryakıt",
        discountRate: "%5 Akaryakıt İndirimi",
        description: "Petrol Ofisi mobil uygulamasında kayıtlı Hane Kurumsal Taşıt Tanıma Sistemi ile akaryakıt alımlarında anında %5 indirim avantajı.",
        code: "HANEPO5",
        logoUrl: "https://images.unsplash.com/photo-1610491462702-42e6ecdabaa2?q=80&w=300&auto=format&fit=crop",
      ),
      AgreementModel(
        id: "agr_4",
        companyName: "MacFit Spor Salonları",
        category: "Yaşam & Spor",
        discountRate: "%15 Üyelik İndirimi",
        description: "Zinde kalmak için MacFit kulüplerine yapılacak yeni üyelik ve yenileme paketlerinde Hane personeline özel %15 ek indirim.",
        code: "HANEMAC15",
        logoUrl: "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=300&auto=format&fit=crop",
      ),
      AgreementModel(
        id: "agr_5",
        companyName: "Starbucks Türkiye",
        category: "Gıda & Restoran",
        discountRate: "1 Kahve Alana 1 Bedava",
        description: "Hafta içi saat 09:00 - 11:00 arasında tüm Starbucks mağazalarında alacağınız ilk kahveye ikincisi Hane daveti olarak hediye!",
        code: "HANESTAR1PLUS1",
        logoUrl: "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?q=80&w=300&auto=format&fit=crop",
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
        final event = await _dbRef!.child('users').once();
        if (event.snapshot.value is Map) {
          final usersMap = event.snapshot.value as Map;
          String? foundId;
          Map? foundData;
          usersMap.forEach((key, val) {
            if (val is Map && val['email'] == email) {
              foundId = key;
              foundData = val;
            }
          });
          if (foundId != null && foundData != null) {
            _currentUser = UserModel.fromMap(foundData!, foundId!);
            _notifyUpdates();
            return _currentUser;
          }
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
        if (snapshot.snapshot.value is Map) {
          final Map data = snapshot.snapshot.value as Map;
          final List<AgreementModel> fbList = [];
          data.forEach((key, value) {
            if (value is Map) {
              fbList.add(AgreementModel.fromMap(value, key.toString()));
            }
          });
          _localAgreements.clear();
          _localAgreements.addAll(fbList);
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
}
