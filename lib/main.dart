// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // <-- GEREKLİ IMPORT
import 'firebase_options.dart';                   // <-- GEREKLİ IMPORT
import 'views/login_page.dart';

// main fonksiyonu 'async' olmalı ve Firebase.initializeApp çağrılmalı.
Future<void> main() async {
  // Bu iki satır Firebase'in çalışması için zorunludur.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veli Uygulaması',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // HİÇBİR DEĞİŞİKLİK YOK: Uygulama hala doğrudan LoginPage'den başlıyor.
      home: LoginPage(),
    );
  }
}