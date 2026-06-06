import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/thought.dart';
import '../providers/thought_provider.dart';
import '../utils/theme.dart';
import '../utils/animations.dart';
import '../widgets/thought_card.dart';
import '../widgets/empty_state.dart';
import 'thought_detail_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);
    final bodyFont = AppFont.body(context, ref);
    final thoughtsAsync = ref.watch(thoughtListProvider);

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部栏
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: c.textPrimary),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '我的收藏',
                        style: TextStyle(
                          fontSize: AppFont.scale(context, ref, 17),
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: thoughtsAsync.when(
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
                  final favorites =
                      allThoughts.where((t) => t.isFavorite).toList();

                  if (favorites.isEmpty) {
                    return const EmptyState(
                      title: '还没有收藏',
                      subtitle: '点击想法卡片的星标即可收藏',
                      icon: Icons.star_outline_rounded,
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final thought = favorites[index];
                      return ThoughtCard(
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
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
