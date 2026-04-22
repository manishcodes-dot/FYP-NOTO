import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../app/routes.dart';
import '../providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminControllerProvider.notifier).fetchStats());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminControllerProvider);
    final stats = state.stats;

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Console')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminControllerProvider.notifier).fetchStats(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dashboard Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildStatsGrid(stats),
              const SizedBox(height: 32),
              const Text('Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildManagementCard(
                title: 'User Management',
                subtitle: 'Manage roles, premium status, & blocks',
                icon: Icons.people_rounded,
                onTap: () => Navigator.pushNamed(context, AppRoutes.adminUsers),
              ),
              _buildManagementCard(
                title: 'Payment Management',
                subtitle: 'Monitor revenue and subscription plans',
                icon: Icons.payments_rounded,
                onTap: () => Navigator.pushNamed(context, AppRoutes.adminPayments),
              ),
              _buildManagementCard(
                title: 'Feedback & Reports',
                subtitle: 'Review user-submitted feedback',
                icon: Icons.feedback_rounded,
                onTap: () => Navigator.pushNamed(context, AppRoutes.adminFeedback),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Users', '${stats['totalUsers'] ?? 0}', Colors.blue),
        _buildStatCard('Pro Users', '${stats['premiumUsers'] ?? 0}', Colors.orange),
        _buildStatCard('Entries', '${stats['totalNotes'] ?? 0}', Colors.green),
        _buildStatCard('Feedbacks', '${stats['totalFeedback'] ?? 0}', Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildManagementCard({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), child: Icon(icon, color: AppColors.primary)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
