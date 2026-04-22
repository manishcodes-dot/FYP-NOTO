import 'package:flutter/material.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/welcome_screen.dart';
import '../features/home/screens/main_shell_screen.dart';
import '../features/journal/models/journal_entry.dart';
import '../features/journal/screens/edit_entry_screen.dart';
import '../features/journal/screens/journal_detail_screen.dart';
import '../features/journal/screens/new_entry_screen.dart';
import '../features/friends/screens/friends_screen.dart';
import '../features/ai/screens/ai_chat_screen.dart';
import '../features/profile/screens/subscription_screen.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/admin/screens/admin_user_management_screen.dart';
import '../features/admin/screens/admin_payment_management_screen.dart';
import '../features/settings/screens/feedback_screen.dart';
import '../features/admin/screens/admin_feedback_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String newEntry = '/journal/new';
  static const String editEntry = '/journal/edit';
  static const String entryDetail = '/journal/detail';
  static const String friends = '/friends';
  static const String ai = '/ai';
  static const String subscription = '/subscription';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminPayments = '/admin/payments';
  static const String feedback = '/feedback';
  static const String adminFeedback = '/admin/feedback';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const MainShellScreen());
      case newEntry:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
            builder: (_) => NewEntryScreen(
                  initialTitle: args?['title'],
                  initialContent: args?['content'],
                ));
      case editEntry:
        final entry = settings.arguments! as JournalEntry;
        return MaterialPageRoute(builder: (_) => EditEntryScreen(entry: entry));
      case entryDetail:
        final entry = settings.arguments! as JournalEntry;
        return MaterialPageRoute(builder: (_) => JournalDetailScreen(entry: entry));
      case friends:
        return MaterialPageRoute(builder: (_) => const FriendsScreen());
      case ai:
        return MaterialPageRoute(builder: (_) => const AIChatScreen());
      case subscription:
        return MaterialPageRoute(builder: (_) => const SubscriptionScreen());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case adminUsers:
        return MaterialPageRoute(builder: (_) => const AdminUserManagementScreen());
      case adminPayments:
        return MaterialPageRoute(builder: (_) => const AdminPaymentManagementScreen());
      case feedback:
        return MaterialPageRoute(builder: (_) => const FeedbackScreen());
      case adminFeedback:
        return MaterialPageRoute(builder: (_) => const AdminFeedbackScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
