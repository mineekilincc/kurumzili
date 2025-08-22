import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../controllers/yonetici_home_controller.dart';
import '../model/user_model.dart';
import '../model/school_model.dart';

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
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showQRLogsModal(String parentId) {
    final trimmedParentId = parentId.trim();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('qr_logs')
              .where('userId', isEqualTo: trimmedParentId)
              .orderBy('timestamp', descending: true)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text("Bu veliye ait QR log bulunamadı.")),
              );
            }
            final logs = snapshot.data!.docs;
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'QR Kod Logları',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: logs.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        final timestamp = log['timestamp'] as Timestamp?;
                        final dateStr = timestamp != null
                            ? '${timestamp.toDate().day.toString().padLeft(2, '0')}.${timestamp.toDate().month.toString().padLeft(2, '0')}.${timestamp.toDate().year} ${timestamp.toDate().hour.toString().padLeft(2, '0')}:${timestamp.toDate().minute.toString().padLeft(2, '0')}'
                            : 'Bilinmiyor';
                        return ListTile(
                          title: Text(log['mesaj'] ?? 'Mesaj yok'),
                          subtitle: Text(dateStr),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showStudentModal(Users parent) {
    final studentMap = parent.studentNames ?? {};

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Öğrenci Bilgisi'),
        content: studentMap.isEmpty
            ? const Text('Bu veliye ait öğrenci kaydı bulunamadı.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: studentMap.entries.map((e) {
                  final className = e.key;
                  final studentName = e.value;
                  return Text("• $studentName  Sınıf: $className");
                }).toList(),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showParentActionsModal() {
    final selectedParent = _controller.selectedParent;
    if (selectedParent == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Seçilen Veli: ${selectedParent.name ?? ''}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.group_add),
              label: const Text('Eş Ekle'),
              onPressed: () {
                Navigator.pop(context);
                _showAddSpouseModal();
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('Kardeş Ekle'),
              onPressed: () {
                Navigator.pop(context);
                _showAddSiblingModal();
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Bilgileri Güncelle'),
              onPressed: () {
                Navigator.pop(context);
                _showFullUpdateModal();
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text('QR Logları Görüntüle'),
              onPressed: () {
                final parentId = selectedParent.userid;
                if (parentId != null) {
                  Navigator.pop(context);
                  _showQRLogsModal(parentId);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Velinin ID bilgisi bulunamadı!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
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
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
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
                    ? 'Ad boş olamaz'
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
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value))
                    return 'Telefon 10 haneli olmalı';
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Eş başarıyla eklendi')),
                    );
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

  void _showAddSiblingModal() {
    if (_controller.selectedParent == null) return;

    final TextEditingController siblingNameController = TextEditingController();
    final TextEditingController siblingClassController =
        TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
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
                'Kardeş Ekle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: siblingNameController,
                decoration: const InputDecoration(
                  labelText: 'Kardeş Adı Soyadı',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Ad boş olamaz'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: siblingClassController,
                decoration: const InputDecoration(labelText: 'Sınıf'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Sınıf boş olamaz'
                    : null,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _controller.addSibling(
                      siblingNameController.text.trim(),
                      siblingClassController.text.trim(),
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kardeş başarıyla eklendi')),
                    );
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

  void _showFullUpdateModal() {
    final selectedParent = _controller.selectedParent;
    if (selectedParent == null) return;

    final TextEditingController parentNameController = TextEditingController(
      text: selectedParent.name,
    );
    final TextEditingController parentPhoneController = TextEditingController(
      text: selectedParent.phone,
    );
    final TextEditingController spouseNameController = TextEditingController(
      text: selectedParent.spouseName ?? '',
    );
    final TextEditingController spousePhoneController = TextEditingController(
      text: selectedParent.spousePhone ?? '',
    );
    final Map<String, TextEditingController> childrenControllers = {};
    selectedParent.studentNames?.forEach((className, studentName) {
      childrenControllers[className] = TextEditingController(text: studentName);
    });
    final _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Veli Bilgilerini Güncelle',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: parentNameController,
                  decoration: const InputDecoration(
                    labelText: 'Veli Adı Soyadı',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Ad boş olamaz'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: parentPhoneController,
                  decoration: const InputDecoration(labelText: 'Veli Telefon'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Telefon boş olamaz';
                    if (!RegExp(r'^[0-9]{10}$').hasMatch(value))
                      return 'Telefon 10 haneli olmalı';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Eş Bilgileri',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: spouseNameController,
                  decoration: const InputDecoration(labelText: 'Eş Adı Soyadı'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: spousePhoneController,
                  decoration: const InputDecoration(labelText: 'Eş Telefon'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Çocuk Bilgileri',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...childrenControllers.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: e.value,
                      decoration: InputDecoration(
                        labelText: 'Çocuk Adı (Sınıf: ${e.key})',
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _controller.updateParentFullInfo(
                        parentNameController.text.trim(),
                        parentPhoneController.text.trim(),
                        spouseNameController.text.trim(),
                        spousePhoneController.text.trim(),
                        childrenControllers.map(
                          (k, v) => MapEntry(k, v.text.trim()),
                        ),
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veli bilgileri başarıyla güncellendi'),
                        ),
                      );
                    }
                  },
                  child: Center(child: const Text('Güncelle')),
                ),
              ],
            ),
          ),
        ),
      ),
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
          DropdownButtonFormField<Schools>(
            value: _controller.selectedSchool,
            decoration: const InputDecoration(
              labelText: "Okul Seçiniz",
              border: OutlineInputBorder(),
            ),
            items: _controller.allowedSchools.map((school) {
              return DropdownMenuItem(
                value: school,
                child: Text(school.schoolName),
              );
            }).toList(),
            onChanged: (school) async {
              if (school != null) {
                setState(() => _isLoading = true);
                await _controller.changeSelectedSchool(school);
                setState(() {
                  _searchQuery = '';
                  _isLoading = false;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Veli Ara',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) =>
                setState(() => _searchQuery = value.toLowerCase()),
          ),
          const SizedBox(height: 16),
          filteredParents.isEmpty
              ? const Center(child: Text("Aramaya uygun veli bulunamadı."))
              : Column(
                  children: filteredParents.asMap().entries.map((entry) {
                    final index = entry.key;
                    final parent = entry.value;

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color.fromARGB(255, 13, 22, 74),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                            ), // Numara okunaklı olsun
                          ),
                        ),
                        title: Text(parent.name ?? 'İsimsiz Veli'),
                        subtitle: Text(parent.phone ?? 'Telefon Yok'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.person),
                              tooltip: "Öğrenci(leri) Görüntüle",
                              onPressed: () => _showStudentModal(parent),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              tooltip: "İşlemleri Görüntüle",
                              onPressed: () {
                                _controller.selectedParent = parent;
                                _showParentActionsModal();
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          _controller.selectedParent = parent;
                          _showParentActionsModal();
                        },
                      ),
                    );
                  }).toList(),
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
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 13, 22, 74),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _controller.selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 13, 22, 74),
        onTap: (index) => _controller.onItemTapped(context, index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Kullanıcı Ekle',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.child_care),
            label: 'Sınıfları Görüntüle',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
