import 'package:budaya_indonesia/features/profile/providers/profile_provider.dart';
import 'package:budaya_indonesia/features/profile/widgets/profile_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:budaya_indonesia/src/auth_provider.dart';
import 'dart:io';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Profile',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, prov, _) {
          if (prov.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final p = prov.profile;
          if (p == null) {
            return const Center(child: Text('Tidak ada data profile'));
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => prov.updatePhoto(),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceVariant,
                      backgroundImage:
                          (p.photoUrl != null && p.photoUrl!.startsWith('http'))
                          ? NetworkImage(p.photoUrl!)
                          : (p.photoUrl != null &&
                                !p.photoUrl!.startsWith('http'))
                          ? Image.asset('assets/images/google_logo.png').image
                          : null,
                      child: p.photoUrl == null
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (p.username != null)
                          Text(
                            '@${p.username}',
                            style: GoogleFonts.montserrat(fontSize: 12),
                          ),
                        Text(
                          p.email ?? '-',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  EditableChip(
                    onTap: () =>
                        Navigator.of(context).pushNamed('/profile/edit'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ProfileActionTile(
                icon: Icons.dark_mode_outlined,
                label: 'Dark Mode',
                trailing: Switch(
                  value: p.darkMode,
                  onChanged: (_) async => await prov.toggleDarkMode(),
                ),
              ),
              const Divider(height: 0),
              ProfileActionTile(
                icon: Icons.logout,
                label: 'Log Out',
                onTap: () async {
                  await context.read<AuthProvider>().signOut();
                  if (!context.mounted) return;
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _username;

  @override
  void initState() {
    super.initState();
    final p = context.read<ProfileProvider>().profile;
    _name = TextEditingController(text: p?.name ?? '');
    _username = TextEditingController(text: p?.username ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProfileProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Consumer<ProfileProvider>(
                  builder: (context, prov, _) {
                    final p = prov.profile;
                    return Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceVariant,
                          backgroundImage: p?.photoUrl == null
                              ? null
                              : p!.photoUrl!.startsWith('http')
                              ? NetworkImage(p.photoUrl!)
                              : File(p.photoUrl!).existsSync()
                              ? FileImage(File(p.photoUrl!))
                              : null,
                          child: p?.photoUrl == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                        Material(
                          color: Colors.teal,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () async {
                              final path = await prov.pickImagePath();
                              if (path != null) await prov.setLocalPhoto(path);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.camera_alt, size: 20),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Edit Profile',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  hintText: 'Nama',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _username,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Username unik',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Username wajib';
                  if (v.length < 3) return 'Min 3 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: prov.isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          await prov.updateName(_name.text.trim());
                          await prov.updateUsername(_username.text.trim());
                          // ignore: use_build_context_synchronously
                          if (mounted) Navigator.pop(context);
                        },
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
