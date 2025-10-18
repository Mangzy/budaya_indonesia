import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../register/widgets/primary_button.dart';
import '../providers/register_provider.dart';
import '../../../src/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl = TextEditingController();
  late final TextEditingController _emailCtrl = TextEditingController();
  late final TextEditingController _passCtrl = TextEditingController();
  late final TextEditingController _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterProvider(auth: context.read<AuthProvider>()),
      child: Consumer<RegisterProvider>(
        builder: (context, vm, _) {
          return Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                final media = MediaQuery.of(context);
                return SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          SizedBox(
                            height: media.size.height * 0.34,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  'assets/images/keragaman.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Container(color: Colors.teal.shade200),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor,
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 20,
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text.rich(
                                        TextSpan(
                                          text: 'Selamat datang di ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                          children: const [
                                            TextSpan(
                                              text: 'Adatverse',
                                              style: TextStyle(
                                                color: Color(0xFFDB8E00),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    const _FieldLabel('Nama'),
                                    _PillField(
                                      controller: _nameCtrl,
                                      validator: (v) => (v ?? '').isNotEmpty
                                          ? null
                                          : 'Nama wajib',
                                    ),
                                    const SizedBox(height: 12),
                                    const _FieldLabel('Email'),
                                    _PillField(
                                      controller: _emailCtrl,
                                      validator: (v) => (v ?? '').contains('@')
                                          ? null
                                          : 'Email tidak valid',
                                    ),
                                    const SizedBox(height: 12),
                                    const _FieldLabel('Password'),
                                    _PillField(
                                      controller: _passCtrl,
                                      obscure: true,
                                      enableToggle: true,
                                      validator: (v) => (v ?? '').length >= 6
                                          ? null
                                          : 'Minimal 6 karakter',
                                    ),
                                    const SizedBox(height: 12),
                                    const _FieldLabel('Konfirmasi Password'),
                                    _PillField(
                                      controller: _confirmCtrl,
                                      obscure: true,
                                      enableToggle: true,
                                      validator: (v) {
                                        if ((v ?? '').isEmpty) {
                                          return 'Konfirmasi wajib';
                                        }
                                        if (v != _passCtrl.text) {
                                          return 'Password tidak sama';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 18),
                                    RegisterPrimaryButton(
                                      onPressed: vm.loading
                                          ? null
                                          : () async {
                                              if (!_formKey.currentState!
                                                  .validate()) {
                                                return;
                                              }
                                              vm.model.email = _emailCtrl.text;
                                              vm.model.password =
                                                  _passCtrl.text;
                                              vm.model.name = _nameCtrl.text;
                                              try {
                                                await vm.register();
                                                if (!mounted) return;
                                                ScaffoldMessenger.of(
                                                  // ignore: use_build_context_synchronously
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Akun berhasil dibuat',
                                                    ),
                                                  ),
                                                );
                                                // ignore: use_build_context_synchronously
                                                Navigator.of(context).pop();
                                              } catch (e) {
                                                if (!mounted) return;
                                                ScaffoldMessenger.of(
                                                  // ignore: use_build_context_synchronously
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(content: Text('$e')),
                                                );
                                              }
                                            },
                                      child: vm.loading
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text('Daftar'),
                                    ),
                                    const SizedBox(height: 16),
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: const Center(
                                        child: Text.rich(
                                          TextSpan(
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'Sudah punya akun? ',
                                              ),
                                              TextSpan(
                                                text: 'Masuk',
                                                style: TextStyle(
                                                  color: Colors.teal,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _PillField extends StatefulWidget {
  final TextEditingController controller;
  final bool obscure;
  final bool enableToggle;
  final String? Function(String?)? validator;
  const _PillField({
    required this.controller,
    this.obscure = false,
    this.enableToggle = false,
    this.validator,
  });
  @override
  State<_PillField> createState() => _PillFieldState();
}

class _PillFieldState extends State<_PillField> {
  late bool _hide;
  @override
  void didUpdateWidget(covariant _PillField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscure != widget.obscure) {
      _hide = widget.obscure;
    }
  }

  @override
  void initState() {
    _hide = widget.obscure;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      // ignore: deprecated_member_use
      borderSide: BorderSide(color: Colors.teal.withOpacity(.45), width: 1.1),
    );
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscure ? _hide : false,
      validator: widget.validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: Colors.teal, width: 1.6),
        ),
        border: border,
        suffixIcon: widget.enableToggle
            ? IconButton(
                icon: Icon(
                  _hide ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
                onPressed: () => setState(() => _hide = !_hide),
              )
            : null,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }
}
