import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/routes.dart';

import '../../../shared/widgets/ui_helpers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../journal/providers/journal_provider.dart';
import '../../journal/widgets/share_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final journal = ref.watch(journalControllerProvider);
    final entries = journal.entries.take(3).toList();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => ref.read(journalControllerProvider.notifier).fetchEntries(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Welcome, ${auth.user?.fullName ?? 'Writer'}', style: Theme.of(context).textTheme.titleLarge),
            Text(DateFormat.yMMMMEEEEd().format(DateTime.now())),
            const SizedBox(height: 16),
            const Card(child: ListTile(title: Text('Prompt'), subtitle: Text('What did today teach you?'))),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              const EmptyState(title: 'No entries yet', subtitle: 'Start your first reflection today.')
            else
              ...entries.map(
                (e) => JournalCard(
                  entry: e,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.entryDetail, arguments: e),
                  onDelete: () => ref.read(journalControllerProvider.notifier).deleteEntry(e.id),
                  onShare: () => showJournalShareSheet(context, ref, e),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
