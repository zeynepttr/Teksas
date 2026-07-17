# Hane İK - Yönetici Web Portalı

Bu klasör, Hane mobil uygulamasındaki **Giriş (Login)**, **İki Adımlı Doğrulama (2FA)** ve **İK Yönetim Paneli (CRM, Onaylar, Maaş Bordroları, İzinler ve Loglar)** ekranlarının web tarayıcılarına uyarlanmış yüksek kaliteli (high-fidelity) Vanilla HTML/CSS/JS sürümünü barındırır.

## Özellikler

1. **İki Adımlı Doğrulama (2FA) Simülasyonu:**
   * Giriş ekranı sonrasında animasyonlu bir geçişle 2FA doğrulama ekranı açılır.
   * Kod giriş kutuları otomatik odaklanma (auto-focus traversal) ve silme (backspace navigation) yeteneğine sahiptir.
   * 30 saniyelik bir geri sayım sayacı çalışır ve süre dolduğunda "Tekrar Gönder" butonu aktifleşir.

2. **İK Yönetici Paneli (Real-time Firebase):**
   * **Paylaşım Onayları:** Firebase'deki onay bekleyen gönderileri listeler, onaylandığında veya reddedildiğinde durumu gerçek zamanlı olarak veritabanında günceller.
   * **CRM / Çalışanlar:** Çalışanların tüm detaylarını (Sicil kodu, dahili no, yaş, departman, kan grubu vb.) listeler. Arama filtrelemesi yapılabilir. Yeni çalışan eklenebilir veya mevcut çalışanların bilgileri modal pencereler aracılığıyla düzenlenebilir.
   * **Bordro Yönetimi:** Çalışanlar için aylık maaş bordrosu düzenleme ve yayınlama modülüdür.
   * **İzin Talepleri:** Çalışanların izin taleplerini tablo halinde gösterir ve onaylama/reddetme işlemlerini yönetir.
   * **Sistem Günlükleri (Loglar):** Panel üzerinden yapılan tüm veri değişiklikleri ve işlemleri anlık olarak zaman damgasıyla birlikte log tablosunda listeler.

---

## Nasıl Çalıştırılır?

Hiçbir paket kurulumuna (npm, build vb.) gerek yoktur.

1. `web-site` klasörünün içindeki `index.html` dosyasına çift tıklayarak tarayıcınızda açın.
2. Giriş bilgileri olarak aşağıdaki İK Yönetici bilgilerini kullanın:
   * **E-posta:** `admin@hane.org.tr`
   * **Şifre:** `123456`
3. 2FA ekranında 6 haneli herhangi bir kod girerek (Örn: `123456`) doğrulama yapın ve panele erişin.
