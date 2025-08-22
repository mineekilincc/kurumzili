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
      user: widget.user,
      // setState() çağrısı, controller'daki herhangi bir durum
      // değişikliğinin arayüze yansımasını sağlar.
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
        // Başlık için controller'daki kullanıcı bilgisini kullan
        title: Text(
          "Hoş Geldiniz, ${_controller.user.name ?? ''}",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 13, 22, 74),
        // Otomatik geri tuşunu kaldırmak isterseniz
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Dropdown alanı: Controller'daki öğrenci listesi boş değilse göster
          if (_controller.studentNames.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<String>(
                // Seçili değeri controller'dan al
                value: _controller.selectedStudent,
                // Öğeleri controller'daki listeden oluştur
                items: _controller.studentNames
                    .map((name) => DropdownMenuItem(
                          value: name,
                          child: Text(name),
                        ))
                    .toList(),
                // Değişiklik olduğunda controller'daki metodu çağır
                onChanged: _controller.onStudentSelected,
                decoration: const InputDecoration(
                  labelText: 'Öğrenci Seçin',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.child_care),
                ),
              ),
            )
          else
            // Eğer öğrenci yoksa bir bilgilendirme mesajı gösterilebilir
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text('Sisteme kayıtlı öğrenciniz bulunmamaktadır.'),
              ),
            ),
          // Diğer içerikler
          const Expanded(
            child: Center(
              child: Text(
                'Ana sayfa içeriği burada',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => SystemNavigator.pop(),
        backgroundColor: const Color.fromARGB(255, 13, 22, 74),
        child: const Icon(Icons.exit_to_app, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        // Aktif indeksi controller'dan al
        currentIndex: _controller.selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 13, 22, 74),
        // Tıklama olayını controller'a yönlendir
        onTap: (index) => _controller.onItemTapped(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner), label: 'QR Kod Okut'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}