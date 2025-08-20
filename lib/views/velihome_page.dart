//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/veli_home_controller.dart';
import '../model/user_model.dart';

class VelihomePage extends StatefulWidget {
  final Users user;

  const VelihomePage({super.key, required this.user});

  @override
  State<VelihomePage> createState() => _VelihomePageState();
}

class _VelihomePageState extends State<VelihomePage> {
  late final VeliHomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VeliHomeController(
      user: widget.user, // artık Users nesnesi gönderiyoruz
      onStateChanged: () => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hoş Geldiniz, ${widget.user.name.toString()}",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 13, 22, 74),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(fit: StackFit.expand, children: [
          
        ],
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
            icon: Icon(Icons.qr_code_scanner),
            label: 'QR Kod Okut',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
