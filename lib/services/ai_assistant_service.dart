import 'dart:async';

class AIRecommendation {
  final String responseText;
  final String recommendedSpecialist; // 'İş Yeri Hekimi', 'Kurum Psikoloğu', or 'Genel Esenlik'
  final List<String> tips;

  AIRecommendation({
    required this.responseText,
    required this.recommendedSpecialist,
    required this.tips,
  });
}

class AIAssistantService {
  static final AIAssistantService _instance = AIAssistantService._internal();
  factory AIAssistantService() => _instance;
  AIAssistantService._internal();

  Future<AIRecommendation> getRecommendation(String message) async {
    // Simulate thinking delay
    await Future.delayed(const Duration(milliseconds: 1200));

    final cleanMsg = message.toLowerCase();

    // 1. Psychological Indicators (Stress, depression, fatigue, anxiety, burnout, sleep)
    if (cleanMsg.contains('stres') ||
        cleanMsg.contains('kaygı') ||
        cleanMsg.contains('yorgun') ||
        cleanMsg.contains('tüken') ||
        cleanMsg.contains('uyku') ||
        cleanMsg.contains('depres') ||
        cleanMsg.contains('mutsuz') ||
        cleanMsg.contains('bunal') ||
        cleanMsg.contains('anksiyete') ||
        cleanMsg.contains('üzgün') ||
        cleanMsg.contains('motivasyon')) {
      return AIRecommendation(
        responseText: "Merhaba. Paylaştıklarınız yoğun bir zihinsel yük veya tükenmişlik belirtisi olabilir. Saha çalışmalarında ve yoğun iş temposunda bu tür hisler oldukça doğaldır. Sizi dinlemek ve baş etme mekanizmaları geliştirmek üzere kurum psikoloğumuzla görüşmenizi öneririm.",
        recommendedSpecialist: "Kurum Psikoloğu",
        tips: [
          "Günün belirli saatlerinde 5'er dakikalık nefes egzersizleri yapın.",
          "İş ve dinlenme saatlerinizi net sınırlarla ayırmaya çalışın.",
          "Kurum psikoloğumuz Psk. Selim Can ile görüşerek stresi yönetme stratejileri üzerine konuşabilirsiniz."
        ],
      );
    }

    // 2. Physical Health Indicators (Headache, back pain, cough, fever, stomach, flu)
    if (cleanMsg.contains('ağrı') ||
        cleanMsg.contains('başım') ||
        cleanMsg.contains('sırt') ||
        cleanMsg.contains('belim') ||
        cleanMsg.contains('ateş') ||
        cleanMsg.contains('öksür') ||
        cleanMsg.contains('grip') ||
        cleanMsg.contains('hasta') ||
        cleanMsg.contains('midem') ||
        cleanMsg.contains('tansiyon') ||
        cleanMsg.contains('üşüt')) {
      return AIRecommendation(
        responseText: "Merhaba. Belirttiğiniz fiziksel şikayetler, sağlığınızı ve iş performansınızı doğrudan etkileyebilecek durumlardır. Hızlı bir teşhis ve gerekirse tedavi planı oluşturulması için en kısa sürede iş yeri hekimimize görünmenizi tavsiye ederim.",
        recommendedSpecialist: "İş Yeri Hekimi",
        tips: [
          "Şikayetleriniz geçene kadar sıvı tüketiminizi artırın.",
          "Masa başı veya saha çalışmalarında duruş (postür) ergonomisine özen gösterin.",
          "İş yeri hekimimiz Dr. Ayşe Yılmaz'dan randevu alarak genel muayene yaptırabilirsiniz."
        ],
      );
    }

    // Default / General Wellness
    return AIRecommendation(
      responseText: "Merhaba! Hane Yapay Zekâ Sağlık ve Esenlik Asistanı'na hoş geldiniz. Sağlık ve esenlik durumunuz hakkında konuşabiliriz. Fiziksel bir rahatsızlığınız veya zihinsel desteğe ihtiyacınız varsa belirtirseniz size en uygun uzmana yönlendirebilirim.",
      recommendedSpecialist: "Genel Esenlik",
      tips: [
        "Günde en az 2-3 litre su tüketmeye özen gösterin.",
        "Sağlıklı bir yaşam için her gün 30 dakika hafif yürüyüşler yapın.",
        "Koruyucu sağlık hizmetleri kapsamında hem iş yeri hekimimiz hem de psikoloğumuzla tanışma randevusu planlayabilirsiniz."
      ],
    );
  }
}
