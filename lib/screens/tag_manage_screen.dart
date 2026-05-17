import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/thought_provider.dart';
import '../utils/theme.dart';

class TagManageScreen extends ConsumerWidget {
  const TagManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听全局数据变化
    final thoughtsAsync = ref.watch(thoughtListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
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
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: AppColors.textPrimary),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        '标签管理',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: thoughtsAsync.when(
                loading: () => const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                error: (e, _) => Center(child: Text('出错了: $e')),
                data: (allThoughts) {
                  // 统计每个标签的数量
                  final tagMap = <String, int>{};
                  for (final t in allThoughts) {
                    if (t.tag != null && t.tag!.isNotEmpty) {
                      tagMap[t.tag!] = (tagMap[t.tag!] ?? 0) + 1;
                    }
                  }
                  final tags = tagMap.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));

                  if (tags.isEmpty) {
                    return const Center(
                      child: Text(
                        '还没有标签',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: tags.length,
                    itemBuilder: (context, index) {
                      final tag = tags[index];
                      final color = AppColors.getTagColor(tag.key);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              tag.key,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${tag.value}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
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
