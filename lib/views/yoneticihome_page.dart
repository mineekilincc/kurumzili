// lib/views/yonetici_home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/yonetici_home_controller.dart';
import '../model/user_model.dart';

class YoneticihomePage extends StatefulWidget {
  final Users user;

  const YoneticihomePage({super.key, required this.user});

  @override
  State<YoneticihomePage> createState() => _YoneticihomePageState();
}

class _YoneticihomePageState extends State<YoneticihomePage> {
  late final YoneticiHomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoneticiHomeController(
      user: widget.user, // Users nesnesi gönderiliyor
      onStateChanged: () => setState(() {}),
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
        title: Text(
          "Hoş Geldiniz ${widget.user.username ?? 'Kullanıcı'}",
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 13, 22, 74),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          SystemNavigator.pop();
        },
        backgroundColor: const Color.fromARGB(255, 13, 22, 74),
        child: const Icon(Icons.exit_to_app, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _controller.selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 13, 22, 74),
        onTap: (index) => _controller.onItemTapped(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Kullanıcı Ekle',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
