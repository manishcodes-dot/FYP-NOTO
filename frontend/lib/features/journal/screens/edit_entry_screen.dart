import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes.dart';
import '../../../shared/widgets/ui_helpers.dart';
import '../models/journal_entry.dart';
import '../providers/journal_provider.dart';

class EditEntryScreen extends ConsumerStatefulWidget {
  const EditEntryScreen({super.key, required this.entry});
  final JournalEntry entry;
  @override
  ConsumerState<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends ConsumerState<EditEntryScreen> {
  late final TextEditingController title;
  late final TextEditingController content;
  late final TextEditingController tags;
  late Mood? selectedMood;
  late JournalCategory category;
  late bool favorite;

  @override
  void initState() {
    super.initState();
    title = TextEditingController(text: widget.entry.title);
    content = TextEditingController(text: widget.entry.content);
    tags = TextEditingController(text: widget.entry.tags.join(', '));
    selectedMood = widget.entry.mood;
    category = widget.entry.category;
    favorite = widget.entry.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Entry')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppTextField(controller: title, hint: 'Title'),
          const SizedBox(height: 10),
          AppTextField(controller: content, hint: 'Content', maxLines: 7),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: Mood.values
                .map((m) => ChoiceChip(
                      label: Text(m.name),
                      selected: selectedMood == m,
                      onSelected: (selected) {
                        setState(() => selectedMood = selected ? m : null);
                      },
                    ))
                .toList(),
          ),
          AppTextField(controller: tags, hint: 'Tags'),
          SwitchListTile(value: favorite, onChanged: (v) => setState(() => favorite = v), title: const Text('Favorite')),
          PrimaryButton(
            label: 'Update Entry',
            onPressed: () async {
              final entry = JournalEntry(
                id: widget.entry.id,
                userId: widget.entry.userId,
                title: title.text.trim(),
                content: content.text.trim(),
                mood: selectedMood ?? Mood.neutral,
                category: JournalCategory.personal,
                tags: tags.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                entryDate: widget.entry.entryDate,
                createdAt: widget.entry.createdAt,
                updatedAt: DateTime.now(),
                isFavorite: favorite,
                isPinned: false,
                ownerName: widget.entry.ownerName,
                ownerEmail: widget.entry.ownerEmail,
                sharedWithIds: widget.entry.sharedWithIds,
              );
              await ref.read(journalControllerProvider.notifier).updateEntry(widget.entry.id, entry);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry updated')));
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
            },
          ),
        ],
      ),
    );
  }
}
