import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme.dart';
import '../../../../services/shared_preferences_services.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = '/profile';
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _saving = false;
  bool _privacyAccepted = false;
  String? _photoPath;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final name = await SharedPreferencesService.getUserName();
    final email = await SharedPreferencesService.getUserEmail();
    final photo = await SharedPreferencesService.getUserPhotoPath();
    if (mounted) {
      setState(() {
        _nameController.text = name ?? '';
        _emailController.text = email ?? '';
        _photoPath = photo;
        _privacyAccepted = false;
      });
    }
  }

  String? _validateName(String? value) {
    if (value == null) return 'Nome é obrigatório.';
    final v = value.trim();
    if (v.isEmpty) return 'Nome é obrigatório.';
    if (v.length > 100) return 'Nome muito longo.';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null) return 'E-mail é obrigatório.';
    final v = value.trim();
    if (v.isEmpty) return 'E-mail é obrigatório.';
    final emailRegExp = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
    if (!emailRegExp.hasMatch(v)) return 'E-mail inválido.';
    return null;
  }

  Future<void> _selectPhoto() async {
    final option = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: slate,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Tirar foto', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Escolher da galeria', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            if (_photoPath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: const Text('Remover foto', style: TextStyle(color: Colors.redAccent)),
                onTap: () => Navigator.pop(context, 'remove'),
              ),
          ],
        ),
      ),
    );

    if (option == null) return;
    if (option == 'remove') {
      await _removePhoto();
      return;
    }

    try {
      final picked = await _picker.pickImage(
        source: option == 'camera' ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1024,
      );
      if (picked == null) return;

      final file = File(picked.path);
      final compressed = await _compressImage(file);
      final savedPath = await _saveImageLocally(compressed);

      setState(() {
        _photoPath = savedPath;
      });

      await SharedPreferencesService.setUserPhotoPath(savedPath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar imagem: $e')),
        );
      }
    }
  }

  Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/avatar_compressed.jpg';
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 80,
      minWidth: 512,
      minHeight: 512,
      format: CompressFormat.jpeg,
      keepExif: false,
    );

    if (result == null) return file;

    return File(result.path);
  }

  Future<String> _saveImageLocally(File file) async {
    final dir = await getApplicationDocumentsDirectory();
    final newPath = '${dir.path}/avatar.jpg';
    final newFile = await file.copy(newPath);
    return newFile.path;
  }

  Future<void> _removePhoto() async {
    if (_photoPath != null) {
      final file = File(_photoPath!);
      if (await file.exists()) await file.delete();
      await SharedPreferencesService.setUserPhotoPath(null);
      setState(() => _photoPath = null);
    }
  }

  Future<void> _saveProfile() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    if (!_privacyAccepted) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Aviso de Privacidade'),
          content: const Text(
            'Ao salvar seu nome e e-mail, você concorda com nossa Política de Privacidade.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() => _privacyAccepted = true);
                _saveProfile();
              },
              child: const Text('Aceito'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _saving = true);

    await SharedPreferencesService.setUserName(_nameController.text.trim());
    await SharedPreferencesService.setUserEmail(_emailController.text.trim());
    await SharedPreferencesService.setPrivacyPolicyAllRead(true);

    setState(() => _saving = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil salvo com sucesso.')),
    );
    Navigator.of(context).pop(true);
  }

  Widget _buildAvatar() {
    if (_photoPath != null && File(_photoPath!).existsSync()) {
      return CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(File(_photoPath!)),
      );
    }

    final initials = _nameController.text.isNotEmpty
        ? _nameController.text.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : '?';
    return CircleAvatar(
      radius: 60,
      backgroundColor: purple,
      child: Text(
        initials,
        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil'), backgroundColor: purple),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    _buildAvatar(),
                    InkWell(
                      onTap: _selectPhoto,
                      borderRadius: BorderRadius.circular(50),
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.edit, color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    hintText: 'Seu nome completo',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _validateName,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    hintText: 'seu@exemplo.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: _privacyAccepted,
                      onChanged: (v) => setState(() => _privacyAccepted = v ?? false),
                    ),
                    const Expanded(
                      child: Text('Li e aceito a Política de Privacidade'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _saving ? null : _saveProfile,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Salvar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
