import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../friends/providers/friends_provider.dart';
import '../models/journal_entry.dart';
import '../providers/journal_provider.dart';

Future<void> showJournalShareSheet(BuildContext context, WidgetRef ref, JournalEntry entry) async {
  final friends = ref.read(friendsControllerProvider).friends;
  if (friends.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add friends first to share notes.')),
    );
    return;
  }

  final selected = Set<String>.from(entry.sharedWithIds);

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
                Text('Share note', style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Friends you select can read this note.',
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
                    await ref.read(journalControllerProvider.notifier).shareEntry(entry.id, selected.toList());
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sharing updated')),
                      );
                    }
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
