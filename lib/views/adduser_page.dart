import 'package:flutter/material.dart';
import '../controllers/adduser_controller.dart';
import '../model/school_model.dart';

class AddUserPage extends StatefulWidget {
  final String? initialRole;
  final List<Schools> allowedSchools;

  const AddUserPage({
    super.key,
    this.initialRole,
    required this.allowedSchools,
  });

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  late final AddUserController _controller;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AddUserController();

    _controller.selectedRole =
        widget.initialRole != null && _controller.roles.contains(widget.initialRole)
            ? widget.initialRole!
            : _controller.roles.first;

    _controller.setAllowedSchools(widget.allowedSchools);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yeni Kullanıcı Ekle"),
        backgroundColor: const Color.fromARGB(255, 13, 22, 74),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _controller.selectedRole,
                decoration: const InputDecoration(labelText: 'Kullanıcı Rolü'),
                items: _controller.roles
                    .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (value) => setState(() => _controller.selectedRole = value),
                validator: (value) => value == null ? 'Lütfen bir rol seçin' : null,
              ),
              const SizedBox(height: 16),
              _buildRoleFields(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 13, 22, 74),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        "Kullanıcıyı Kaydet",
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleFields() {
    switch (_controller.selectedRole) {
      case 'Veli':
        return Column(
          children: [
            _schoolDropdown(),
            const SizedBox(height: 12),
            _textField(_controller.nameController, 'Veli Adı Soyadı'),
            const SizedBox(height: 12),
            _phoneField(_controller.phoneController, 'Veli Telefon Numarası'),
            const SizedBox(height: 12),
            _textField(_controller.passwordController, 'Veli Şifre', allowNumbers: true),
            const SizedBox(height: 12),
            _textField(_controller.studentNameController, 'Öğrenci Adı Soyadı'),
            const SizedBox(height: 12),
            _textField(_controller.studentClassController, 'Öğrenci Sınıfı'),
          ],
        );
      case 'Öğretmen':
        return Column(
          children: [
            _schoolDropdown(),
            const SizedBox(height: 12),
            _textField(_controller.nameController, 'Öğretmen Adı Soyadı'),
            const SizedBox(height: 12),
            _phoneField(_controller.phoneController, 'Telefon Numarası'),
            const SizedBox(height: 12),
            _textField(_controller.passwordController, 'Şifre', allowNumbers: true),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _schoolDropdown() {
    return DropdownButtonFormField<Schools>(
      decoration: const InputDecoration(labelText: 'Okul Seçimi'),
      value: _controller.selectedSchool,
      items: _controller.allowedSchools
          .map((school) => DropdownMenuItem(
                value: school,
                child: Text(school.schoolName ?? ''),
              ))
          .toList(),
      onChanged: (value) => setState(() => _controller.onSchoolSelected(value)),
      validator: (value) => value == null ? 'Lütfen bir okul seçin' : null,
    );
  }

  Widget _textField(TextEditingController controller, String label,
      {bool allowNumbers = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (allowNumbers) {
          if (value == null || value.isEmpty) return "$label boş olamaz";
          return null;
        } else {
          return _controller.textValidator(value, label);
        }
      },
    );
  }

  Widget _phoneField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      maxLength: 10,
      validator: (value) {
        if (value == null || value.isEmpty) return "$label boş olamaz.";
        final regex = RegExp(r'^[0-9]{10}$');
        if (!regex.hasMatch(value)) return "Geçerli bir telefon numarası girin (10 haneli).";
        return null;
      },
    );
  }
}
