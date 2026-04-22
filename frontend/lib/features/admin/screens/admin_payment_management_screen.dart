import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';

import '../../../core/theme/app_colors.dart';

class AdminPaymentManagementScreen extends ConsumerStatefulWidget {
  const AdminPaymentManagementScreen({super.key});

  @override
  ConsumerState<AdminPaymentManagementScreen> createState() => _AdminPaymentManagementScreenState();
}

class _AdminPaymentManagementScreenState extends ConsumerState<AdminPaymentManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminControllerProvider.notifier).fetchUsers());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminControllerProvider);
    final users = state.users.where((u) => u.isPremium).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Management')),
      body: state.isLoading && users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? const Center(child: Text('No premium subscribers found.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: CircleAvatar(backgroundColor: AppColors.primary, child: const Icon(Icons.star, color: Colors.white)),
                      title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Plan: ${user.subscriptionPlan.toUpperCase()}\nExpires: ${user.subscriptionExpiry?.toString().split(' ')[0] ?? 'Lifetime'}'),
                      isThreeLine: true,
                      trailing: TextButton(
                        onPressed: () => ref.read(adminControllerProvider.notifier).togglePremium(user.id),
                        child: const Text('Revoke Pro', style: TextStyle(color: Colors.red)),
                      ),
                    );
                  },
                ),
    );
  }
}
