import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/thought_provider.dart';
import '../utils/theme.dart';

class TagManageScreen extends ConsumerWidget {
  const TagManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);
    final bodyFont = AppFont.body(context, ref);
    // 监听全局数据变化
    final thoughtsAsync = ref.watch(thoughtListProvider);

    return Scaffold(
      backgroundColor: c.background,
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
                        '标签管理',
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
            const SizedBox(height: 24),
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
                    return Center(
                      child: Text(
                        '还没有标签',
                        style: TextStyle(
                          fontSize: AppFont.scale(context, ref, 15),
                          color: c.textTertiary,
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
                          color: c.surface,
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
                              style: TextStyle(
                                fontSize: AppFont.scale(context, ref, 15),
                                color: c.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${tag.value}',
                              style: TextStyle(
                                fontSize: AppFont.scale(context, ref, 14),
                                color: c.textTertiary,
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
