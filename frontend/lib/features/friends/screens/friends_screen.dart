import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/ui_helpers.dart';
import '../providers/friends_provider.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(friendsControllerProvider.notifier).refreshAll());
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _addFriend() async {
    final email = emailController.text.trim();
    if (email.isEmpty) return;
    final err = await ref.read(friendsControllerProvider.notifier).requestByEmail(email);
    if (!mounted) return;
    emailController.clear();
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Friend request sent')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(friendsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(friendsControllerProvider.notifier).refreshAll(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Find a friend', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Search by name to send a friend request.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            AppTextField(
              controller: emailController,
              hint: 'Search names...',
              onChanged: (v) => ref.read(friendsControllerProvider.notifier).searchUsers(v),
            ),
            if (state.searchResults.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: state.searchResults.map((u) {
                    final userId = u['_id']?.toString() ?? '';
                    final name = u['fullName']?.toString() ?? '';
                    final mail = u['email']?.toString() ?? '';
                    return ListTile(
                      title: Text(name),
                      subtitle: Text(mail),
                      trailing: TextButton(
                        onPressed: () {
                          ref.read(friendsControllerProvider.notifier).requestById(userId);
                          emailController.clear();
                          ref.read(friendsControllerProvider.notifier).searchUsers('');
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request sent')));
                        },
                        child: const Text('Add'),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 28),
            if (state.incoming.isNotEmpty) ...[
              Text('Incoming requests', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...state.incoming.map((r) {
                final from = r['from'] as Map<String, dynamic>? ?? {};
                final id = r['id']?.toString() ?? '';
                final name = from['fullName']?.toString() ?? 'Someone';
                final mail = from['email']?.toString() ?? '';
                return Card(
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text(mail),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => ref.read(friendsControllerProvider.notifier).reject(id),
                          child: const Text('Decline'),
                        ),
                        FilledButton(
                          onPressed: () => ref.read(friendsControllerProvider.notifier).accept(id),
                          child: const Text('Accept'),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
            Text('Your friends', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (state.friends.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: EmptyState(
                  title: 'No friends yet',
                  subtitle: 'Add someone by email to share journal entries.',
                ),
              )
            else
              ...state.friends.map(
                (f) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Text(f.fullName.isNotEmpty ? f.fullName[0].toUpperCase() : '?'),
                    ),
                    title: Text(f.fullName),
                    subtitle: Text(f.email),
                    trailing: IconButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Remove friend'),
                            content: Text('Are you sure you want to remove ${f.fullName}?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Remove'),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          ref.read(friendsControllerProvider.notifier).removeFriend(f.id);
                        }
                      },
                      icon: const Icon(Icons.person_remove_outlined),
                      color: Colors.redAccent.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
