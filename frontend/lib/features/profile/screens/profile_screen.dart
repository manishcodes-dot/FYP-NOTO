import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(radius: 36, child: Icon(Icons.person_outline_rounded)),
            const SizedBox(height: 12),
            Text(user?.fullName ?? 'Guest', style: Theme.of(context).textTheme.titleLarge),
            Text(user?.email ?? ''),
            const SizedBox(height: 14),
            OutlinedButton(onPressed: () {}, child: const Text('Edit profile')),
          ],
        ),
      ),
    );
  }
}
