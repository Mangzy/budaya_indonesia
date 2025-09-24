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

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterProvider(auth: context.read<AuthProvider>()),
      child: Consumer<RegisterProvider>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('Register')),
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _nameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Full name',
                              ),
                              validator: (v) => (v ?? '').isNotEmpty
                                  ? null
                                  : 'Enter your name',
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _emailCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                              ),
                              validator: (v) => (v ?? '').contains('@')
                                  ? null
                                  : 'Enter a valid email',
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                              ),
                              obscureText: true,
                              validator: (v) =>
                                  (v ?? '').length >= 6 ? null : 'Min 6 chars',
                            ),
                            const SizedBox(height: 16),
                            RegisterPrimaryButton(
                              onPressed: vm.loading
                                  ? null
                                  : () async {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }
                                      vm.model.email = _emailCtrl.text;
                                      vm.model.password = _passCtrl.text;
                                      vm.model.name = _nameCtrl.text;
                                      try {
                                        await vm.register();
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(
                                          // ignore: use_build_context_synchronously
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Account created'),
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
                                  ? const CircularProgressIndicator()
                                  : const Text('Create account'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
