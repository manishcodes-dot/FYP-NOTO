import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/admin_provider.dart';

class AdminUserManagementScreen extends ConsumerStatefulWidget {
  const AdminUserManagementScreen({super.key});
  @override
  ConsumerState<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends ConsumerState<AdminUserManagementScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminControllerProvider.notifier).fetchUsers());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search email or name...',
              leading: const Icon(Icons.search),
              onChanged: (v) => ref.read(adminControllerProvider.notifier).fetchUsers(search: v),
            ),
          ),
        ),
      ),
      body: state.isLoading && state.users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.users.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final user = state.users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user.isPremium ? Colors.orange : Colors.grey[200],
                    child: Icon(user.isPremium ? Icons.star_rounded : Icons.person_outline, color: user.isPremium ? Colors.white : Colors.grey),
                  ),
                  title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email, style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildChip(user.role.toUpperCase(), user.role == 'admin' ? Colors.red : Colors.blue),
                          const SizedBox(width: 8),
                          _buildChip(user.isActive ? 'ACTIVE' : 'BLOCKED', user.isActive ? Colors.green : Colors.grey),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text(user.isActive ? 'Block User' : 'Unblock User'),
                        onTap: () => ref.read(adminControllerProvider.notifier).toggleUserStatus(user.id),
                      ),
                      PopupMenuItem(
                        child: Text(user.isPremium ? 'Remove Pro' : 'Give Pro Access'),
                        onTap: () => ref.read(adminControllerProvider.notifier).togglePremium(user.id),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
