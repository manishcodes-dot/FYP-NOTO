import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes.dart';
import '../../../shared/widgets/ui_helpers.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppTextField(controller: email, hint: 'Email'),
            const SizedBox(height: 10),
            AppTextField(controller: password, hint: 'Password', obscure: true),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Continue',
              isLoading: state.isLoading,
              onPressed: () async {
                final emailVal = email.text.trim();
                final passVal = password.text.trim();

                if (emailVal.isEmpty || passVal.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter both email and password')));
                  return;
                }

                final bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailVal);
                if (!emailValid) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid email address')));
                  return;
                }

                final ok = await ref.read(authControllerProvider.notifier).login(emailVal, passVal);
                if (ok && context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
                } else if (context.mounted) {
                  final err = ref.read(authControllerProvider).error ?? 'Login failed';
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                }
              },
            ),
            TextButton(onPressed: () {}, child: const Text('Forgot password?')),
          ],
        ),
      ),
    );
  }
}
