import 'package:flutter/material.dart';
import '../controllers/yonetici_home_controller.dart';
import '../model/user_model.dart';

class SiniflarHomePage extends StatefulWidget {
  final Users user;

  const SiniflarHomePage({super.key, required this.user});

  @override
  State<SiniflarHomePage> createState() => _SiniflarHomePageState();
}

class _SiniflarHomePageState extends State<SiniflarHomePage> {
  late final YoneticiHomeController _controller;
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedClassName;
  List<String> _filteredStudents = [];

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

      final studentsMap = _controller.selectedSchool?.classes;
      if (studentsMap != null && studentsMap.isNotEmpty) {
        _selectedClassName = studentsMap.keys.first;
        _filteredStudents = List<String>.from(
            studentsMap[_selectedClassName] ?? []);
      }
    }

    setState(() => _isLoading = false);
  }

  Widget _buildBody() {
  final Map<String, List<String>>? studentsMap =
      _controller.selectedSchool?.classes;
  final List<String> classNames = studentsMap?.keys.toList() ?? [];

  final searchedStudents = _filteredStudents
      .where((student) => student.toLowerCase().contains(_searchQuery))
      .toList();

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedClassName,
          decoration: const InputDecoration(
            labelText: "Sınıf Seçiniz",
            border: OutlineInputBorder(),
          ),
          items: classNames.map((className) {
            return DropdownMenuItem(
              value: className,
              child: Text(className),
            );
          }).toList(),
          onChanged: (selected) {
            setState(() {
              _selectedClassName = selected;
              _filteredStudents =
                  List<String>.from(studentsMap?[selected] ?? []);
              _searchQuery = '';
            });
          },
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Öğrenci Ara',
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
        searchedStudents.isEmpty
            ? const Center(child: Text("Aramaya uygun öğrenci bulunamadı."))
            : Column(
                children: List.generate(searchedStudents.length, (index) {
                  final student = searchedStudents[index];

                  // Öğrencinin velisini bul
                  String? parentName;
                  for (var parent in _controller.parents) {
                    if (parent.studentNames?.containsValue(student) ?? false) {
                      parentName = parent.name;
                      break;
                    }
                  }

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(student),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Veli Bilgisi'),
                            content: Text(
                              parentName != null
                                  ? 'Veli: $parentName'
                                  : 'Bu öğrencinin veli bilgisi bulunamadı.',
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
                  );
                }),
              ),
      ],
    ),
  );
}


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sınıfları Görüntüle",
          style: TextStyle(color: Colors.white),
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
              icon: Icon(Icons.child_care), label: 'Sınıfları Görüntüle'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
