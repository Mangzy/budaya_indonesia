import 'package:budaya_indonesia/src/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/login_provider.dart';
import '../widgets/auth_text_field.dart';
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
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AuthTextField(
                            controller: _emailController,
                            label: 'Email',
                            validator: (v) => (v ?? '').contains('@')
                                ? null
                                : 'Enter a valid email',
                          ),
                          const SizedBox(height: 12),
                          AuthTextField(
                            controller: _passwordController,
                            label: 'Password',
                            obscure: true,
                            validator: (v) => (v ?? '').length >= 6
                                ? null
                                : 'Min 6 characters',
                          ),
                          const SizedBox(height: 16),
                          PrimaryButton(
                            onPressed: vm.loadingSignInWithEmail
                                ? null
                                : () async {
                                    if (!_formKey.currentState!.validate()) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please enter a valid email and password',
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    try {
                                      await vm.signInWithEmail();
                                      if (vm.errorMessage != null) {
                                        ScaffoldMessenger.of(
                                          // ignore: use_build_context_synchronously
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(vm.errorMessage!),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        // ignore: use_build_context_synchronously
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                    }
                                  },
                            child: vm.loadingSignInWithEmail
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Sign in'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: vm.loadingSignInWithEmail
                              ? null
                              : () async {
                                  final email = vm.model.email.trim();
                                  if (email.contains('@')) {
                                    await context
                                        .read<AuthProvider>()
                                        .sendResetEmail(email);
                                    if (!mounted) return;
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Reset email sent'),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Enter email to reset'),
                                      ),
                                    );
                                  }
                                },
                          child: const Text('Forgot password'),
                        ),
                        TextButton(
                          onPressed: vm.loadingSignUpWithEmail
                              ? null
                              : () async {
                                  final email = vm.model.email.trim();
                                  final pass = vm.model.password;
                                  if (email.contains('@') && pass.length >= 6) {
                                    try {
                                      await vm.signUpWithEmail();
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        // ignore: use_build_context_synchronously
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Account created'),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        // ignore: use_build_context_synchronously
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Fill valid email and password',
                                        ),
                                      ),
                                    );
                                  }
                                },
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: const Text('Create account'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    GoogleButton(
                      onPressed: vm.loadingSignInWithGoogle
                          ? null
                          : vm.signInWithGoogle,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
