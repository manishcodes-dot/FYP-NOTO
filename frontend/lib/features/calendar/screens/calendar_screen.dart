import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../app/routes.dart';
import '../../../shared/widgets/ui_helpers.dart';
import '../../journal/providers/journal_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});
  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime selected = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(journalControllerProvider.notifier).fetchByDate(selected));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(journalControllerProvider);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2035),
            focusedDay: selected,
            selectedDayPredicate: (d) => isSameDay(d, selected),
            onDaySelected: (d, _) async {
              setState(() => selected = d);
              await ref.read(journalControllerProvider.notifier).fetchByDate(d);
            },
            eventLoader: (day) => ref.read(journalControllerProvider.notifier).markedDates.any((d) => isSameDay(d, day)) ? [1] : [],
          ),
          const SizedBox(height: 12),
          if (state.selectedDateEntries.isEmpty)
            const EmptyState(title: 'No entries this day', subtitle: 'Tap + to add a reflection.')
          else
            ...state.selectedDateEntries
                .map((entry) => JournalCard(entry: entry, onTap: () => Navigator.pushNamed(context, AppRoutes.entryDetail, arguments: entry))),
        ],
      ),
    );
  }
}
