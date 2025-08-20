import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/yonetici_home_controller.dart';
import '../model/user_model.dart';
import '../model/school_model.dart';
import 'adduser_page.dart';
import 'profile_page.dart';

class YoneticihomePage extends StatefulWidget {
  final Users user;

  const YoneticihomePage({super.key, required this.user});

  @override
  State<YoneticihomePage> createState() => _YoneticihomePageState();
}

class _YoneticihomePageState extends State<YoneticihomePage> {
  late final YoneticiHomeController _controller;
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = YoneticiHomeController(
      user: widget.user,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await _controller.fetchAllowedSchools();
    if (_controller.allowedSchools.isNotEmpty) {
      _controller.selectedSchool = _controller.allowedSchools.first;
      await _controller.fetchParentsForSelectedSchool();
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAddSpouseModal() {
    if (_controller.selectedParent == null) return;

    final TextEditingController spouseNameController = TextEditingController();
    final TextEditingController spousePhoneController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Eş Ekle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: spouseNameController,
                decoration: const InputDecoration(labelText: 'Eş Adı Soyadı'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Eş adı boş olamaz'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: spousePhoneController,
                decoration: const InputDecoration(labelText: 'Telefon'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Telefon boş olamaz';
                  final regex = RegExp(r'^[0-9]{10}$');
                  if (!regex.hasMatch(value)) return 'Telefon 10 haneli olmalı';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _controller.addSpouse(
                      spouseNameController.text.trim(),
                      spousePhoneController.text.trim(),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Ekle'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showParentActionsModal() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Seçilen Veli: ${_controller.selectedParent?.name ?? ''}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Eş Ekle Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.group_add),
                  label: const Text('Eş Ekle'),
                  onPressed: () {
                    Navigator.pop(context);
                    _showAddSpouseModal();
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Bilgileri Güncelle Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Bilgileri Güncelle'),
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Güncelleme modalı veya sayfası burada açılabilir
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Güncelleme işlemi yakında eklenecek."),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Kardeş Ekle Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Kardeş Ekle'),
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Kardeş ekleme modalı burada açılabilir
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Kardeş ekleme işlemi yakında eklenecek.",
                        ),
                      ),
                    );
                  },
                ),
              ),


              const SizedBox(height: 8),

              // QR Gör Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Log QR'),
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Kardeş ekleme modalı burada açılabilir
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Kardeş ekleme işlemi yakında eklenecek.",
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    final filteredParents = _controller.parents.where((parent) {
      final name = parent.name?.toLowerCase() ?? '';
      return name.contains(_searchQuery);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Okul Seçimi
          DropdownButtonFormField<SchoolModel>(
            value: _controller.selectedSchool,
            decoration: const InputDecoration(
              labelText: "Okul Seçiniz",
              border: OutlineInputBorder(),
            ),
            items: _controller.allowedSchools.map((school) {
              return DropdownMenuItem(
                value: school,
                child: Text(school.schoolName ?? 'İsimsiz Okul'),
              );
            }).toList(),
            onChanged: (school) async {
              if (school != null) {
                setState(() => _isLoading = true);
                await _controller.changeSelectedSchool(school);
                setState(() {
                  _searchQuery = ''; // Arama sıfırlansın
                  _isLoading = false;
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // Veli Arama
          TextField(
            decoration: const InputDecoration(
              labelText: 'Veli Ara',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
          const SizedBox(height: 16),

          // Veliler Listesi
          filteredParents.isEmpty
    ? const Center(child: Text("Aramaya uygun veli bulunamadı."))
    : Column(
        children: List.generate(filteredParents.length, (index) {
          final parent = filteredParents[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),
              title: Text(parent.name ?? 'İsimsiz Veli'),
              subtitle: Text(parent.phone ?? 'Telefon Yok'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.person),
                    tooltip: "Öğrenci(leri) Görüntüle",
                    onPressed: () {
                      final students = parent.students ?? [];
                      final classes = parent.studentclasses ?? [];

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Öğrenci Bilgisi'),
                          content: students.isEmpty
                              ? const Text(
                                  'Bu veliye ait öğrenci kaydı bulunamadı.',
                                )
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(
                                    students.length,
                                    (i) {
                                      final studentName = students[i];
                                      final studentClass =
                                          i < classes.length ? classes[i] : '-';
                                      return Text(
                                          "• $studentName  Sınıf: $studentClass");
                                    },
                                  ),
                                ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Tamam'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Icon(Icons.arrow_forward_ios),
                ],
              ),
              onTap: () {
                _controller.selectedParent = parent;
                _showParentActionsModal();
              },
            ),
          );
        }),
      ),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hoş Geldiniz, ${widget.user.name ?? 'Yönetici'}",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 13, 22, 74),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => SystemNavigator.pop(),
        backgroundColor: const Color.fromARGB(255, 13, 22, 74),
        child: const Icon(Icons.exit_to_app, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
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
