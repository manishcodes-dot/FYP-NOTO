import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../friends/providers/friends_provider.dart';
import '../models/journal_entry.dart';
import '../providers/journal_provider.dart';

class JournalDetailScreen extends ConsumerStatefulWidget {
  const JournalDetailScreen({super.key, required this.entry});
  final JournalEntry entry;

  @override
  ConsumerState<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends ConsumerState<JournalDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(friendsControllerProvider.notifier).refreshAll());
  }

  Future<void> _openShareSheet() async {
    final friends = ref.read(friendsControllerProvider).friends;
    if (!mounted) return;
    if (friends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add friends first — use Friends from the Journal tab.')),
      );
      return;
    }

    final selected = Set<String>.from(widget.entry.sharedWithIds);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewPadding.bottom + 20,
                top: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Share with friends', style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Friends you select can read this note. They must have accepted your friend request.',
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 280,
                    child: ListView(
                      children: friends
                          .map(
                            (f) => CheckboxListTile(
                              value: selected.contains(f.id),
                              onChanged: (v) {
                                setModalState(() {
                                  if (v == true) {
                                    selected.add(f.id);
                                  } else {
                                    selected.remove(f.id);
                                  }
                                });
                              },
                              title: Text(f.fullName),
                              subtitle: Text(f.email),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  FilledButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await ref.read(journalControllerProvider.notifier).shareEntry(widget.entry.id, selected.toList());
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sharing updated')),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final auth = ref.watch(authControllerProvider);
    final owned = entry.isOwnedBy(auth.user?.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(entry.title),
        actions: [
          if (owned) ...[
            Stack(
              children: [
                IconButton(onPressed: _openShareSheet, icon: const Icon(Icons.share_outlined), tooltip: 'Share'),
                if (entry.sharedWithIds.isNotEmpty)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        entry.sharedWithIds.length.toString(),
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            IconButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.editEntry, arguments: entry),
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
            ),
            IconButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete entry'),
                    content: const Text('Are you sure you want to delete this journal entry?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete'),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(journalControllerProvider.notifier).deleteEntry(entry.id);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Delete',
            ),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            if (!owned && (entry.ownerName != null && entry.ownerName!.isNotEmpty))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Chip(
                  avatar: const Icon(Icons.person_outline, size: 18),
                  label: Text('Shared by ${entry.ownerName}'),
                ),
              ),
            Row(
              children: [
                Text(
                  'Mood: ${_cap(entry.mood.name)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                const Spacer(),
                if (entry.tags.isNotEmpty)
                  Text(
                    entry.tags.map((t) => '#$t').join(' '),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontSize: 13),
                  ),
              ],
            ),
            const Divider(height: 32),
            Text(entry.content, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
