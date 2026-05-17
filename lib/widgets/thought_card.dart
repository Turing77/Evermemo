import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/thought.dart';
import '../utils/theme.dart';

class ThoughtCard extends StatelessWidget {
  final Thought thought;
  final int index;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  const ThoughtCard({
    super.key,
    required this.thought,
    this.index = 0,
    this.onDelete,
    this.onTap,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      DateFormat('MM月dd日 HH:mm').format(thought.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const Spacer(),
                    if (thought.tag != null && thought.tag!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.getTagColor(thought.tag!)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          thought.tag!,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.getTagColor(thought.tag!),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (onFavorite != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onFavorite,
                        child: Icon(
                          thought.isFavorite
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 20,
                          color: thought.isFavorite
                              ? const Color(0xFFFFD666)
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  thought.content,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                // 附件指示器
                if (thought.imagePathList.isNotEmpty ||
                    (thought.audioPath != null &&
                        thought.audioPath!.isNotEmpty)) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (thought.imagePathList.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.image_outlined,
                                  size: 14, color: AppColors.textTertiary),
                              const SizedBox(width: 4),
                              Text(
                                '${thought.imagePathList.length}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (thought.imagePathList.isNotEmpty &&
                          thought.audioPath != null &&
                          thought.audioPath!.isNotEmpty)
                        const SizedBox(width: 8),
                      if (thought.audioPath != null &&
                          thought.audioPath!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.mic_outlined,
                                  size: 14, color: AppColors.textTertiary),
                              SizedBox(width: 4),
                              Text(
                                '语音',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
