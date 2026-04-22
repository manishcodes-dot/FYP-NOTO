import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/ui_helpers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../friends/models/friend_user.dart';
import '../../friends/providers/friends_provider.dart';
import '../models/journal_entry.dart';
import '../providers/journal_provider.dart';
import '../widgets/share_sheet.dart';

class JournalListScreen extends ConsumerStatefulWidget {
  const JournalListScreen({super.key});
  @override
  ConsumerState<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends ConsumerState<JournalListScreen> {
  final search = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(journalControllerProvider.notifier).fetchEntries();
      await ref.read(friendsControllerProvider.notifier).refreshAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(journalControllerProvider);
    final auth = ref.watch(authControllerProvider);
    final friendsState = ref.watch(friendsControllerProvider);
    final user = auth.user;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await ref.read(friendsControllerProvider.notifier).refreshAll();
          if (state.tab == JournalListTab.mine) {
            await ref.read(journalControllerProvider.notifier).fetchEntries();
          } else {
            await ref.read(journalControllerProvider.notifier).fetchSharedWithMe();
          }
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            _ProfileFriendsHeader(
              displayName: user?.fullName ?? 'Writer',
              email: user?.email ?? '',
              onProfileTap: () => Navigator.pushNamed(context, AppRoutes.friends),
              friends: friendsState.friends,
              pendingCount: friendsState.incoming.length,
              onAddFriend: () => Navigator.pushNamed(context, AppRoutes.friends),
            ),
            const SizedBox(height: 16),
            SegmentedButton<JournalListTab>(
              segments: const [
                ButtonSegment(value: JournalListTab.mine, label: Text('My journal'), icon: Icon(Icons.book_outlined)),
                ButtonSegment(
                  value: JournalListTab.sharedWithMe,
                  label: Text('Shared with me'),
                  icon: Icon(Icons.people_outline),
                ),
              ],
              selected: {state.tab},
              onSelectionChanged: (s) {
                ref.read(journalControllerProvider.notifier).setTab(s.first);
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: search,
              hint: 'Search entries',
              onChanged: (v) {
                ref.read(journalControllerProvider.notifier).setQuery(v);
                ref.read(journalControllerProvider.notifier).fetchEntries();
              },
            ),
            const SizedBox(height: 8),
            if (state.tab == JournalListTab.mine)
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: state.moodFilter == null,
                    onSelected: (_) {
                      ref.read(journalControllerProvider.notifier).setMood(null);
                      ref.read(journalControllerProvider.notifier).fetchEntries();
                    },
                  ),
                  ...Mood.values.map(
                    (m) => ChoiceChip(
                      label: Text(m.name),
                      selected: state.moodFilter == m,
                      onSelected: (_) {
                        ref.read(journalControllerProvider.notifier).setMood(m);
                        ref.read(journalControllerProvider.notifier).fetchEntries();
                      },
                    ),
                  ),
                ],
              ),
            // Tag filter — collects unique tags from all loaded entries
            if (state.tab == JournalListTab.mine) ...[
              const SizedBox(height: 8),
              Builder(builder: (context) {
                final allTags = state.entries
                    .expand((e) => e.tags)
                    .toSet()
                    .toList()
                  ..sort();
                if (allTags.isEmpty) return const SizedBox.shrink();
                return Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All Tags'),
                      selected: state.tagFilter == null,
                      onSelected: (_) {
                        ref.read(journalControllerProvider.notifier).setTag(null);
                        ref.read(journalControllerProvider.notifier).fetchEntries();
                      },
                    ),
                    ...allTags.map(
                      (tag) => ChoiceChip(
                        label: Text('#$tag'),
                        selected: state.tagFilter == tag,
                        onSelected: (_) {
                          ref.read(journalControllerProvider.notifier).setTag(
                                state.tagFilter == tag ? null : tag,
                              );
                          ref.read(journalControllerProvider.notifier).fetchEntries();
                        },
                      ),
                    ),
                  ],
                );
              }),
            ],

            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.entries.isEmpty)
              EmptyState(
                title: state.tab == JournalListTab.mine ? 'No entries found' : 'Nothing shared yet',
                subtitle: state.tab == JournalListTab.mine
                    ? 'Create your first journal note.'
                    : 'When friends share notes with you, they appear here.',
              )
            else
              ...state.entries.map(
                (entry) => JournalCard(
                  entry: entry,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.entryDetail, arguments: entry),
                  onDelete: state.tab == JournalListTab.mine && entry.isOwnedBy(user?.id)
                      ? () => ref.read(journalControllerProvider.notifier).deleteEntry(entry.id)
                      : null,
                  onShare: state.tab == JournalListTab.mine && entry.isOwnedBy(user?.id)
                      ? () => showJournalShareSheet(context, ref, entry)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileFriendsHeader extends StatelessWidget {
  const _ProfileFriendsHeader({
    required this.displayName,
    required this.email,
    required this.onProfileTap,
    required this.friends,
    required this.pendingCount,
    required this.onAddFriend,
  });

  final String displayName;
  final String email;
  final VoidCallback onProfileTap;
  final List<FriendUser> friends;
  final int pendingCount;
  final VoidCallback onAddFriend;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x14000000)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Friends & profile', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 2),
                        Text(displayName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        Text(email, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary.withOpacity(0.8)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Text('Friends', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            if (pendingCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.35), borderRadius: BorderRadius.circular(999)),
                child: Text('$pendingCount pending', style: Theme.of(context).textTheme.labelSmall),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  avatar: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: const Text('Add friends'),
                  onPressed: onAddFriend,
                ),
              ),
              ...friends.map((f) {
                final name = f.fullName;
                final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    avatar: CircleAvatar(radius: 12, backgroundColor: AppColors.primaryLight, child: Text(initial, style: const TextStyle(fontSize: 10))),
                    label: Text(name.split(' ').first, overflow: TextOverflow.ellipsis),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
