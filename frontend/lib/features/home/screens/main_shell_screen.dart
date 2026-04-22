import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes.dart';
import '../../calendar/screens/calendar_screen.dart';
import '../../journal/screens/journal_list_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../ai/screens/ai_chat_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/screens/subscription_screen.dart';
import 'home_screen.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  int index = 0;
  final screens = const [
    HomeScreen(),
    JournalListScreen(),
    AIChatScreen(),
    CalendarScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final isPremium = user?.isPremium ?? false;

    return Scaffold(
      body: (index == 2 && !isPremium) ? const SubscriptionScreen() : screens[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (v) => setState(() => index = v),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Journal'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_rounded), label: 'AI Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
      floatingActionButton: (index == 2 || index == 4)
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.newEntry),
              label: const Text('New Entry'),
              icon: const Icon(Icons.add),
            ),
    );
  }
}
