// qrscan_controller.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../model/user_model.dart';

class QRScanController {
  final Users user;
  final String? selectedStudentName;
  final String? selectedStudentClass;

  final MobileScannerController scannerController = MobileScannerController();
  String? _lastScannedCode;

  QRScanController({
    required this.user,
    this.selectedStudentName,
    this.selectedStudentClass,
  });

  Future<void> handleScannedCode(String qrData, BuildContext context) async {

    debugPrint('--- QR KOD İŞLEME BAŞLADI ---');
    debugPrint('Giriş yapan kullanıcı ID: ${user.userid}');
    debugPrint('Giriş yapan kullanıcının School ID değeri: ${user.schoolId}'); 
    debugPrint('Okutulan QR Verisi: $qrData');
    debugPrint('----------------------------------');


    if (qrData == _lastScannedCode) return;
    _lastScannedCode = qrData;

    debugPrint('QR Kod İşleniyor: $qrData');

    final qrLogsRef = FirebaseFirestore.instance.collection('qr_logs');

    // QR kod okul ile uyuşuyor mu kontrolü
    if (qrData != user.schoolId) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hata: Bu QR kod sizin okulunuz için geçerli değil!'),
            duration: Duration(seconds:3),
          ),
        );
      }
      _lastScannedCode = null;
      return;
    }

    // 10 dakikalık tekrar okutma kontrolü
    try {
     
      final prefs = await SharedPreferences.getInstance();
 final currentTime = DateTime.now().millisecondsSinceEpoch;
      final lastScannedCode = prefs.getString('lastScannedCode');

      if (lastScannedCode != null && lastScannedCode == qrData) {
        debugPrint('Aynı QR kodu tekrar okutulmaya çalışıldı: $qrData');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bu QR kodu zaten okuttunuz.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      if (query.docs.isNotEmpty) {
        final lastTimestamp = query.docs.first['timestamp'] as Timestamp?;
        if (lastTimestamp != null) {
          final difference = DateTime.now().difference(lastTimestamp.toDate());
          if (difference.inMinutes < 10) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Bu QR kodu tekrar okutmak için 10 dakika bekleyin.'),
                  duration: Duration(seconds: 3),
                ),
              );
            }
            Future.delayed(const Duration(seconds: 10), () => _lastScannedCode = null);
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('QR tekrar kontrol hatası: $e');
    }

    // 🟢 Mesaj oluşturma: Firestore'dan okulun anonsunu çek
    String mesaj = '${selectedStudentName ?? 'Öğrenci'} bekleniyor'; // varsayılan

    if (selectedStudentName != null && selectedStudentClass != null) {
      try {
        final schoolDoc = await FirebaseFirestore.instance
            .collection('schools')
            .doc(user.schoolId)
            .get();

        if (schoolDoc.exists) {
          final String anons = schoolDoc.get('anons') ?? '';
          // Anonstaki XXX ve YYY yerlerini değiştir
          mesaj = anons
              .replaceAll('XXX', selectedStudentClass!)
              .replaceAll('YYY', selectedStudentName!);
        }
      } catch (e) {
        debugPrint('Anons çekme hatası: $e');
     
        mesaj = '${selectedStudentClass} sınıfından ${selectedStudentName} bekleniyor';
      }
    }
    try {
      await qrLogsRef.add({
        'qrData': qrData,
        'userid': user.userid,
        'schoolId': user.schoolId, // Bu değerin null olmaması gerekiyor
        'userAdSoyad': user.name,
        'sinifAdi': selectedStudentClass ?? 'Bilinmiyor',
        'mesaj': mesaj,
        'teslimZamani': 1,
        'timestamp': FieldValue.serverTimestamp(),
        'tip': 1,
        'microtime': DateTime.now().millisecondsSinceEpoch,
      });
     
      await prefs.setString('lastScannedCode', currentTime);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR kod kaydedildi: $qrData'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('QR log kaydetme hatası: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR kod kaydedilemedi!'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }

    Future.delayed(const Duration(seconds: 2), () => _lastScannedCode = null);
  }

  void dispose() {
    scannerController.dispose();
  }
}