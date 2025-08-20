import 'package:flutter/material.dart';
import '../controllers/mmhome_controller.dart';
import '../model/user_model.dart';
//import '../model/school_model.dart';

class MainManagerHomePage extends StatefulWidget {
  const MainManagerHomePage({super.key, required Users user});

  @override
  State<MainManagerHomePage> createState() => _MainManagerHomePageState();
}

class _MainManagerHomePageState extends State<MainManagerHomePage> {
  final MainManagerHomeController _controller = MainManagerHomeController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      await _controller.loadManagersAndSchools();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yönetici - Okul Atama'),
        backgroundColor: const Color.fromARGB(255, 13, 22, 74),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<Users>(
              hint: const Text('Bir yönetici seçin'),
              value: _controller.selectedManager,
              isExpanded: true,
              items: _controller.managers
                  .map((manager) => DropdownMenuItem<Users>(
                        value: manager,
                        child: Text(manager.name ?? manager.username ?? 'Yönetici'),
                      ))
                  .toList(),
              onChanged: (manager) {
                setState(() {
                  _controller.selectedManager = manager;
                  _controller.loadSelectedSchoolsForManager();
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _controller.allSchools.length,
                itemBuilder: (context, index) {
                  final school = _controller.allSchools[index];
                  final isSelected =
                      _controller.selectedSchools.contains(school);
                  return CheckboxListTile(
                    title: Text(school.schoolName),
                    value: isSelected,
                    onChanged: (_) {
                      setState(() => _controller.toggleSchool(school));
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _controller.saveSelections();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Seçilen okullar kaydedildi!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 13, 22, 74)),
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
