import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/thought.dart';
import '../providers/thought_provider.dart';
import '../utils/theme.dart';
import '../utils/animations.dart';
import '../widgets/thought_card.dart';
import '../widgets/empty_state.dart';
import 'thought_detail_screen.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String _searchQuery = '';
  String? _selectedTag;

  List<String> _extractTags(List<Thought> thoughts) {
    final tags = thoughts
        .where((t) => t.tag != null && t.tag!.isNotEmpty)
        .map((t) => t.tag!)
        .toSet()
        .toList();
    tags.sort();
    return tags;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final thoughtsAsync = ref.watch(thoughtListProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              '常记库',
              style: TextStyle(
                fontSize: AppFont.scale(context, ref, 28),
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSearchBar(context),
          const SizedBox(height: 16),
          _buildTagBar(context, thoughtsAsync),
          const SizedBox(height: 16),
          Expanded(child: _buildList(context, thoughtsAsync)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded,
                size: 20, color: c.textTertiary),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                style: TextStyle(
                    fontSize: AppFont.scale(context, ref, 15), color: c.textPrimary),
                decoration: InputDecoration(
                  hintText: '搜索想法或标签',
                  hintStyle:
                      TextStyle(fontSize: AppFont.scale(context, ref, 15), color: c.textTertiary),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagBar(BuildContext context, AsyncValue<List<Thought>> thoughtsAsync) {
    final allTags = thoughtsAsync.when(
      data: (list) => _extractTags(list),
      loading: () => <String>[],
      error: (_, __) => <String>[],
    );

    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 1 + allTags.length,
        itemBuilder: (context, index) {
          final c = AppColors.of(context);
          final isAll = index == 0;
          final tag = isAll ? null : allTags[index - 1];
          final isSelected = _selectedTag == tag;
          final label = isAll ? '全部' : tag!;
          final color =
              isAll ? c.accent : AppColors.getTagColor(tag!);

          return GestureDetector(
            onTap: () {
              setState(() => _selectedTag = tag);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : c.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? color : c.divider,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: AppFont.scale(context, ref, 13),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? color : c.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, AsyncValue<List<Thought>> thoughtsAsync) {
    final c = AppColors.of(context);
    return thoughtsAsync.when(
      loading: () => Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: c.accent,
          ),
        ),
      ),
      error: (e, _) => Center(child: Text('出错了: $e')),
      data: (allThoughts) {
        List<Thought> thoughts = allThoughts;
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          thoughts = thoughts
              .where((t) =>
                  t.content.toLowerCase().contains(q) ||
                  (t.tag?.toLowerCase().contains(q) ?? false))
              .toList();
        } else if (_selectedTag != null) {
          thoughts =
              thoughts.where((t) => t.tag == _selectedTag).toList();
        }

        if (thoughts.isEmpty) {
          return const EmptyState(
            title: '还没有记录',
            subtitle: '写下第一念吧。',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          itemCount: thoughts.length,
          itemBuilder: (context, index) {
            final thought = thoughts[index];
            return Dismissible(
              key: Key(thought.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                ref
                    .read(thoughtListProvider.notifier)
                    .deleteThought(thought.id);
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: c.danger,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delete_outline,
                    color: Colors.white, size: 24),
              ),
              child: ThoughtCard(
                thought: thought,
                index: index,
                onTap: () {
                  Navigator.push(
                    context,
                    buildSlideRoute(
                        ThoughtDetailScreen(thought: thought)),
                  );
                },
                onFavorite: () {
                  ref
                      .read(thoughtListProvider.notifier)
                      .toggleFavorite(thought.id);
                },
              ),
            );
          },
        );
      },
    );
  }
}
