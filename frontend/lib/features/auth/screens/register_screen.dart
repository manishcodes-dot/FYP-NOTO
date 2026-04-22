import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes.dart';
import '../../../shared/widgets/ui_helpers.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppTextField(controller: name, hint: 'Full name'),
            const SizedBox(height: 10),
            AppTextField(controller: email, hint: 'Email'),
            const SizedBox(height: 10),
            AppTextField(controller: password, hint: 'Password', obscure: true),
            const SizedBox(height: 10),
            AppTextField(controller: confirm, hint: 'Confirm password', obscure: true),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Register',
              isLoading: state.isLoading,
              onPressed: () async {
                final nameVal = name.text.trim();
                final emailVal = email.text.trim();
                final passVal = password.text.trim();
                final confirmVal = confirm.text.trim();

                if (nameVal.isEmpty || emailVal.isEmpty || passVal.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
                  return;
                }

                if (passVal.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters')));
                  return;
                }

                if (passVal != confirmVal) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
                  return;
                }

                final bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailVal);
                if (!emailValid) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid email address')));
                  return;
                }

                final ok = await ref.read(authControllerProvider.notifier).register(nameVal, emailVal, passVal);
                if (ok && context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (_) => false);
                } else if (context.mounted) {
                  final err = ref.read(authControllerProvider).error ?? 'Registration failed';
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
