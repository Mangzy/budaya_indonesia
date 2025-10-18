import 'package:budaya_indonesia/src/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/login_provider.dart';
import '../widgets/primary_button.dart';
import '../widgets/google_button.dart';

class LoginPages extends StatefulWidget {
  const LoginPages({super.key});

  @override
  State<LoginPages> createState() => _LoginPagesState();
}

class _LoginPagesState extends State<LoginPages> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _controllersInitialized = false;

  @override
  void dispose() {
    if (_controllersInitialized) {
      _emailController.dispose();
      _passwordController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginProvider>();

    if (!_controllersInitialized) {
      _emailController = TextEditingController(text: vm.model.email);
      _passwordController = TextEditingController(text: vm.model.password);
      _emailController.addListener(
        () => vm.model.email = _emailController.text,
      );
      _passwordController.addListener(
        () => vm.model.password = _passwordController.text,
      );
      _controllersInitialized = true;
    }

    if (vm.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
        vm.errorMessage = null;
      });
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final media = MediaQuery.of(context);
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Top Image Section
                    SizedBox(
                      height: media.size.height * 0.34,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/images/batik.png',
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
                                  Theme.of(context).scaffoldBackgroundColor,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Form Section
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text.rich(
                                TextSpan(
                                  text: 'Selamat datang di ',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                  children: const [
                                    TextSpan(
                                      text: 'Adatverse',
                                      style: TextStyle(
                                        color: Colors.teal,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  const _FieldLabel('Email'),
                                  _PillField(
                                    controller: _emailController,
                                    hintText: 'Masukkan email',
                                    validator: (v) =>
                                        (v ?? '').trim().contains('@')
                                        ? null
                                        : 'Email tidak valid',
                                  ),
                                  const SizedBox(height: 12),
                                  const _FieldLabel('Password'),
                                  _PillField(
                                    controller: _passwordController,
                                    hintText: 'Masukkan kata sandi',
                                    obscure: true,
                                    enableToggle: true,
                                    validator: (v) => (v ?? '').length >= 6
                                        ? null
                                        : 'Minimal 6 karakter',
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: vm.loadingSignInWithEmail
                                          ? null
                                          : () async {
                                              final email = vm.model.email
                                                  .trim();
                                              if (email.contains('@')) {
                                                await context
                                                    .read<AuthProvider>()
                                                    .sendResetEmail(email);
                                                if (!mounted) return;
                                                ScaffoldMessenger.of(
                                                  // ignore: use_build_context_synchronously
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Reset email terkirim',
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Masukkan email dulu',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                      child: const Text('Lupa Password ?'),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  PrimaryButton(
                                    onPressed: vm.loadingSignInWithEmail
                                        ? null
                                        : () async {
                                            if (!_formKey.currentState!
                                                .validate()) {
                                              return;
                                            }
                                            try {
                                              await vm.signInWithEmail();
                                              if (vm.errorMessage != null) {
                                                // ignore: use_build_context_synchronously
                                                ScaffoldMessenger.of(
                                                  // ignore: use_build_context_synchronously
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      vm.errorMessage!,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                if (!mounted) return;
                                                Navigator.pushNamedAndRemoveUntil(
                                                  context,
                                                  '/navbar',
                                                  (route) => false,
                                                );
                                              }
                                            } catch (e) {
                                              // ignore: use_build_context_synchronously
                                              ScaffoldMessenger.of(
                                                // ignore: use_build_context_synchronously
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(e.toString()),
                                                ),
                                              );
                                            }
                                          },
                                    child: vm.loadingSignInWithEmail
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : Text(
                                            'Masuk',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              fontFamily:
                                                  GoogleFonts.montserrat()
                                                      .fontFamily,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 14),
                                  const _DividerWithText(
                                    text: 'atau masuk dengan',
                                  ),
                                  const SizedBox(height: 14),
                                  GoogleButton(
                                    onPressed: vm.loadingSignInWithGoogle
                                        ? null
                                        : () async {
                                            await vm.signInWithGoogle();
                                            if (vm.errorMessage != null) {
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    vm.errorMessage!,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              if (!mounted) return;
                                              Navigator.pushNamedAndRemoveUntil(
                                                context,
                                                '/navbar',
                                                (route) => false,
                                              );
                                            }
                                          },
                                  ),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      '/register',
                                    ),
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                        children: [
                                          TextSpan(text: 'Tidak punya akun? '),
                                          TextSpan(
                                            text: 'Daftar disini',
                                            style: TextStyle(
                                              color: Colors.teal,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
  }
}

// Custom pill field to match design
class _PillField extends StatefulWidget {
  final TextEditingController controller;
  final bool obscure;
  final bool enableToggle;
  final String? Function(String?)? validator;
  final String? hintText;
  const _PillField({
    required this.controller,
    this.obscure = false,
    this.enableToggle = false,
    this.validator,
    this.hintText,
  });
  @override
  State<_PillField> createState() => _PillFieldState();
}

class _PillFieldState extends State<_PillField> {
  bool _hide = true;
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
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _DividerWithText extends StatelessWidget {
  final String text;
  const _DividerWithText({required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: const TextStyle(fontSize: 12.5, color: Colors.black87),
          ),
        ),
        const Expanded(child: Divider(thickness: 1)),
      ],
    );
  }
}
