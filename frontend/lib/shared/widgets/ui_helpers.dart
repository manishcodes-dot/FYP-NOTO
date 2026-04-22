import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../features/journal/models/journal_entry.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.onPressed, this.isLoading = false});
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(label),
      );
}

class AppTextField extends StatelessWidget {
  const AppTextField({super.key, required this.controller, required this.hint, this.maxLines = 1, this.obscure = false, this.onChanged});
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final bool obscure;
  final ValueChanged<String>? onChanged;
  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        maxLines: maxLines,
        obscureText: obscure,
        onChanged: onChanged,
        decoration: InputDecoration(hintText: hint),
      );
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.menu_book_rounded, size: 50, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(subtitle, textAlign: TextAlign.center),
          ]),
        ),
      );
}

class JournalCard extends StatelessWidget {
  const JournalCard({super.key, required this.entry, this.onTap, this.onDelete, this.onShare});
  final JournalEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          onTap: onTap,
          isThreeLine: entry.ownerName != null && entry.ownerName!.isNotEmpty,
          title: Text(entry.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (entry.ownerName != null && entry.ownerName!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'From ${entry.ownerName}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primary),
                  ),
                ),
              Text(
                DateFormat.yMMMd().add_jm().format(entry.entryDate),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (entry.isFavorite) const Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.favorite, size: 20, color: Colors.red)),
              if (onShare != null) IconButton(onPressed: onShare, icon: const Icon(Icons.ios_share, size: 20)),
              if (onDelete != null) IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline, size: 20)),
            ],
          ),
        ),
      );
}
