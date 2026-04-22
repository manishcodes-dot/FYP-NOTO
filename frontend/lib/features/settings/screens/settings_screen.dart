import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/screens/profile_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => const _SettingsBody();
}

class _SettingsBody extends ConsumerWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ProfileScreen(),
          const SizedBox(height: 12),
          _buildPremiumStatusCard(context, ref),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.star_outline_rounded, color: AppColors.primary),
                  title: const Text('Subscription'),
                  subtitle: const Text('Manage your NOTO Pro plan'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.subscription),
                ),
                if (user?.role == 'admin')
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings_outlined, color: Colors.red),
                    title: const Text('Admin Dashboard'),
                    subtitle: const Text('Manage users, stats and system'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.adminDashboard),
                  ),
                ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: const Text('Friends & sharing'),
                  subtitle: const Text('Add friends and manage shared notes'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.friends),
                ),
                SwitchListTile(
                  value: isDark,
                  onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
                  secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                  title: const Text('Dark Mode'),
                  subtitle: Text(isDark ? 'Dark theme active' : 'Light theme active'),
                ),
                const ListTile(title: Text('About NOTO'), subtitle: Text('A calm journal companion.')),
                const ListTile(title: Text('Privacy note'), subtitle: Text('Your entries stay with your account.')),
                ListTile(
                  leading: const Icon(Icons.feedback_outlined),
                  title: const Text('Feedback'),
                  subtitle: const Text('Send us your suggestions'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.feedback),
                ),
                const ListTile(title: Text('Version'), subtitle: Text('1.0.0')),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (_) => false);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStatusCard(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final isPremium = user?.isPremium ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPremium ? [AppColors.primary, AppColors.primary.withOpacity(0.8)] : [Colors.grey[800]!, Colors.black],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: (isPremium ? AppColors.primary : Colors.black).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Icon(isPremium ? Icons.auto_awesome : Icons.lock_outline, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPremium ? 'NOTO PRO ACTIVE' : 'FREE ACCOUNT',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2),
                ),
                Text(
                  isPremium ? 'Enjoying unlimited AI features' : 'Upgrade to unlock AI Chatbot',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
                ),
              ],
            ),
          ),
          if (!isPremium)
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.subscription),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('UPGRADE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
        ],
      ),
    );
  }
}
