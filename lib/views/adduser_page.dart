import 'package:flutter/material.dart';
import '../controllers/adduser_controller.dart';
import '../model/school_model.dart';

class AddUserPage extends StatefulWidget {
  final String? initialRole;
  final List<SchoolModel> allowedSchools; // MainManager’dan gelen izinli okullar

  const AddUserPage({super.key, this.initialRole, required this.allowedSchools});

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
    // Rolü güvenli şekilde seçiyoruz
    _controller.selectedRole = (widget.initialRole != null &&
            _controller.roles.contains(widget.initialRole))
        ? widget.initialRole!
        : _controller.roles.first;

    // İzinli okulları controller’a aktar
    _controller.setAllowedSchools(widget.allowedSchools);

    // School dropdown için default seçim
    _controller.selectedSchool = widget.allowedSchools.isNotEmpty
        ? widget.allowedSchools.first
        : null;

    // Class dropdown için default null
    _controller.selectedClass = null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final errorMessage = await _controller.addUser();
    if (!mounted) return;

    if (errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kullanıcı başarıyla eklendi!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
    setState(() => _isLoading = false);
  }

  Widget _schoolDropdown() {
    return DropdownButtonFormField<SchoolModel>(
      decoration: const InputDecoration(labelText: 'Okul Seç'),
      value: _controller.selectedSchool,
      items: _controller.allowedSchools
          .map((s) => DropdownMenuItem(value: s, child: Text(s.schoolName)))
          .toList(),
      onChanged: (v) => setState(() => _controller.onSchoolSelected(v)),
      validator: (v) =>
          _controller.selectedSchool == null ? 'Lütfen bir okul seçiniz' : null,
    );
  }

  Widget _classDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Sınıf Seç'),
      value: _controller.selectedClass,
      items: _controller.filteredClasses
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (v) => setState(() => _controller.onClassSelected(v)),
      validator: (v) => v == null ? 'Lütfen bir sınıf seçiniz' : null,
    );
  }

  Widget _textField(TextEditingController controller, String label,
      {bool allowNumbers = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      textCapitalization: TextCapitalization.words,
      validator: (v) =>
          allowNumbers ? null : _controller.textValidator(v, label),
    );
  }

  Widget _phoneField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) return "$label boş olamaz";
        final regex = RegExp(r'^[0-9]{10}$');
        if (!regex.hasMatch(value)) return "$label 10 haneli olmalı";
        return null;
      },
    );
  }

  Widget _buildRoleFields() {
    switch (_controller.selectedRole) {
      case 'Veli':
        return Column(
          children: [
            _schoolDropdown(),
            _classDropdown(),
            _textField(_controller.nameController, 'Veli Adı Soyadı'),
            _phoneField(_controller.phoneController, 'Veli Telefon'),
            _textField(_controller.passwordController, 'Veli Şifre',
                allowNumbers: true),
            _textField(_controller.studentNameController, 'Öğrenci Adı Soyadı'),
          ],
        );
      case 'Öğretmen':
        return Column(
          children: [
            _schoolDropdown(),
            _classDropdown(),
            _textField(_controller.nameController, 'Öğretmen Adı Soyadı'),
            _phoneField(_controller.phoneController, 'Telefon'),
            _textField(_controller.usernameController, 'Kullanıcı Adı',
                allowNumbers: true),
            _textField(_controller.passwordController, 'Şifre', allowNumbers: true),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yeni Kullanıcı Ekle", style: TextStyle(color: Colors.white),),

        backgroundColor: const Color.fromARGB(255, 13, 22, 74),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _controller.selectedRole,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: _controller.roles
                    .map((role) =>
                        DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (v) => setState(() => _controller.selectedRole = v!),
                validator: (v) => v == null ? 'Lütfen bir rol seçin' : null,
              ),
              const SizedBox(height: 12),
              _buildRoleFields(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 13, 22, 74),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Kullanıcı Ekle", style: TextStyle(fontSize: 18)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
