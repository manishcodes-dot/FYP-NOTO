import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes.dart';
import '../../../shared/widgets/ui_helpers.dart';
import '../models/journal_entry.dart';
import '../providers/journal_provider.dart';

class NewEntryScreen extends ConsumerStatefulWidget {
  const NewEntryScreen({super.key, this.initialContent, this.initialTitle});
  final String? initialContent;
  final String? initialTitle;
  @override
  ConsumerState<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends ConsumerState<NewEntryScreen> {
  late final title = TextEditingController(text: widget.initialTitle);
  late final content = TextEditingController(text: widget.initialContent);
  final tags = TextEditingController();
  Mood? selectedMood;
  JournalCategory category = JournalCategory.personal;
  bool favorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Journal Entry')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppTextField(controller: title, hint: 'Title'),
          const SizedBox(height: 10),
          AppTextField(controller: content, hint: 'Write your thoughts...', maxLines: 7),
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
          const SizedBox(height: 10),
          AppTextField(controller: tags, hint: 'Tags (comma separated)'),
          SwitchListTile(value: favorite, onChanged: (v) => setState(() => favorite = v), title: const Text('Favorite')),
          PrimaryButton(
            label: 'Save Entry',
            onPressed: () async {
              final entry = JournalEntry(
                id: '',
                userId: '',
                title: title.text.trim(),
                content: content.text.trim(),
                mood: selectedMood ?? Mood.neutral,
                category: JournalCategory.personal,
                tags: tags.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                entryDate: DateTime.now(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                isFavorite: favorite,
                isPinned: false,
              );
              await ref.read(journalControllerProvider.notifier).createEntry(entry);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry saved')));
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            },
          ),
        ],
      ),
    );
  }
}
