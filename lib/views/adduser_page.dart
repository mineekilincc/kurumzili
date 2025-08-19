import 'package:flutter/material.dart';
import '../controllers/adduser_controller.dart';
import '../model/school_model.dart';

class AddUserPage extends StatefulWidget {
  final String? initialRole;

  const AddUserPage({super.key, this.initialRole});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final AddUserController _controller = AddUserController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.selectedRole = widget.initialRole ?? _controller.roles.first;

    _controller.fetchSchools().then((_) {
      setState(() {}); // UI güncellensin
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final errorMessage = await _controller.addUser();

    if (!mounted) return;

    if (errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanıcı başarıyla eklendi!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }

    setState(() => _isLoading = false);
  }

  Widget _buildRoleFields() {
    switch (_controller.selectedRole) {
      case 'Veli':
        return Column(
          children: [
            _schoolDropdown(),
            _classDropdown(),
            _studentDropdown(),
            const SizedBox(height: 12),
            _textField(_controller.nameController, 'Veli Adı'),
            _textField(_controller.surnameController, 'Veli Soyadı'),
            _textField(_controller.phoneController, 'Veli Telefon', keyboard: TextInputType.phone),
            _textField(_controller.emailController, 'Veli Mail', keyboard: TextInputType.emailAddress),
            _textField(_controller.usernameController, 'Veli Kullanıcı Adı'),
            _textField(_controller.passwordController, 'Veli Şifresi'),
            _textField(_controller.studentNameController, 'Veli Öğrenci Adı')
          ],
        );

      case 'Öğrenci':
        return Column(
          children: [
            _schoolDropdown(),
            _classDropdown(),
            //_studentDropdown(),
            const SizedBox(height: 12),
            _textField(_controller.nameController, 'Öğrenci Adı'),
            _textField(_controller.surnameController, 'Öğrenci Soyadı'),
            _textField(_controller.usernameController, 'Kullanıcı Adı'),
            _textField(_controller.passwordController, 'Şifre'),
          ],
        );

      case 'Yönetici':
        return Column(
          children: [
            _textField(_controller.nameController, 'Ad'),
            _textField(_controller.surnameController, 'Soyad'),
            _schoolDropdown(),
            const SizedBox(height: 12),
            _textField(_controller.phoneController, 'Telefon', keyboard: TextInputType.phone),
            _textField(_controller.emailController, 'Mail', keyboard: TextInputType.emailAddress),
            _textField(_controller.usernameController, 'Kullanıcı Adı'),
            _textField(_controller.passwordController, 'Şifre'),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  // TextField helper
  Widget _textField(TextEditingController controller, String label, {TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboard,
      validator: (v) => _controller.validateTurkish(v, label),
    );
  }

  // Dropdown helperlar
  Widget _schoolDropdown() {
    return DropdownButtonFormField<SchoolModel>(
      decoration: const InputDecoration(labelText: 'Okul Seç'),
      value: _controller.selectedSchool,
      isExpanded: true,
      items: _controller.schools
          .map((school) => DropdownMenuItem(value: school, child: Text(school.schoolName)))
          .toList(),
      onChanged: (value) => setState(() => _controller.onSchoolSelected(value)),
      validator: (v) => v == null ? 'Lütfen bir okul seçiniz' : null,
    );
  }

  Widget _classDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Sınıf Seç'),
      value: _controller.selectedClass,
      isExpanded: true,
      items: _controller.filteredClasses.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: (value) => setState(() => _controller.onClassSelected(value)),
      validator: (v) => v == null ? 'Lütfen bir sınıf seçiniz' : null,
    );
  }

  Widget _studentDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Öğrenci Seç'),
      value: _controller.selectedStudent,
      isExpanded: true,
      items: _controller.filteredStudents.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: (value) => setState(() => _controller.onStudentSelected(value)),
      validator: (v) => v == null ? 'Lütfen bir öğrenci seçiniz' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yeni Kullanıcı Ekle", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 13, 22, 74),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _controller.selectedRole,
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items: _controller.roles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
                  onChanged: (newValue) => setState(() => _controller.selectedRole = newValue),
                  validator: (v) => v == null ? 'Lütfen bir rol seçin' : null,
                ),
                const SizedBox(height: 12),
                _buildRoleFields(),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 13, 22, 74),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                        : const Text('Kullanıcı Ekle', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
