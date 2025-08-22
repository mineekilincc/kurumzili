import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/qrscan_controller.dart';
import '../model/user_model.dart';

class QRScanPage extends StatefulWidget {
  final Users user;
  final String?
  selectedStudentName; // GÜNCELLENDİ: Seçilen öğrencinin adını alır
  final String? selectedStudentClass; // Yeni parametre

  const QRScanPage({
    super.key,
    required this.user,
    this.selectedStudentName, // GÜNCELLENDİ
    this.selectedStudentClass, // Yeni parametre
  });

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  late final QRScanController _controller;

  @override
  // _QRScanPageState'in initState metodu
  @override
  void initState() {
    super.initState();
    // Controller'ı doğru parametrelerle başlat
    _controller = QRScanController(
      user: widget.user,
      selectedStudentName: widget.selectedStudentName,
      selectedStudentClass: widget
          .selectedStudentClass, // Bu parametreyi eklediğinizden emin olun
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Tarayıcı', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 13, 22, 74),
      ),
      body: MobileScanner(
        controller: _controller.scannerController,
        onDetect: (barcodeCapture) {
          final String? code = barcodeCapture.barcodes.first.rawValue;

          if (code != null) {
            // Tespit edilen kodu işlenmesi için controller'a gönder
            _controller.handleScannedCode(code, context);
          }
        },
      ),
    );
  }
}
