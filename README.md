# 📱 Arduino Bluetooth Terminal (Flutter)

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://www.android.com)

Bu uygulama, **Flutter** tabanlı mobil cihazların Bluetooth üzerinden **Arduino** (HC-05, HC-06, vb.) modülleriyle seri haberleşme kurmasını sağlar. Özellikle robotik projelerde ve hobi devrelerinde veri takibi yapmak için tasarlanmıştır.

---

## ✨ Öne Çıkan Özellikler

* 🔍 **Cihaz Tarama:** Çevredeki aktif Bluetooth cihazlarını asenkron olarak keşfeder.
* 🔗 **Kolay Bağlantı:** Eşleşmiş (Bonded) cihazları anında listeler ve tek dokunuşla bağlanır.
* 🔤 **Türkçe Karakter Onarımı:** Arduino tarafındaki encoding farklarından kaynaklanan karakter bozulmalarını (`Ã§`, `ÄŸ` vb.) otomatik temizler.
* 🛡️ **Modern İzin Yönetimi:** Android 12+ sürümleri için gerekli olan hassas Bluetooth ve Konum izinlerini uygulama içinden yönetir.
* 📟 **Terminal Görünümü:** Gelen verileri `Courier` yazı tipiyle gerçek bir terminal havasında sunar.

---

## 🛠️ Teknik Detaylar

Uygulama içerisinde kullanılan temel yapılar ve paketler:

| Paket | Kullanım Amacı |
| :--- | :--- |
| `flutter_bluetooth_serial` | Bluetooth Classic (SPP) iletişimi |
| `permission_handler` | Çalışma zamanı izin kontrolleri |
| `dart:convert` | UTF-8 veri işleme ve dönüştürme |

### 🛠️ Kurulum Adımları

1.  **Repoyu klonlayın:**
    ```bash
    git clone [https://github.com/tunabostanci/arduino_bluetooth.git](https://github.com/tunabostanci/arduino_bluetooth.git)
    ```
2.  **Paketleri yükleyin:**
    ```bash
    flutter pub get
    ```
3.  **İzinleri kontrol edin:**
    `AndroidManifest.xml` dosyanızda aşağıdaki izinlerin olduğundan emin olun:
    ```xml
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    ```

---

## 🔍 Kod Analizi

### Karakter Onarım Fonksiyonu
Arduino'dan gelen ham verilerdeki bozulmaları düzelten kritik fonksiyon:

```dart
String fixTurkishChars(String input) {
  final replacements = {
    'Ã§': 'ç', 'Ã‡': 'Ç', 'Ã¶': 'ö', 'Ã–': 'Ö',
    'Ã¼': 'ü', 'Ãœ': 'Ü', 'ÄŸ': 'ğ', 'Äž': 'Ğ',
    'ÅŸ': 'ş', 'Åž': 'Ş', 'Ä±': 'ı', 'Ä°': 'İ',
  };
  replacements.forEach((wrong, correct) {
    input = input.replaceAll(wrong, correct);
  });
  return input;
}
