import 'package:flutter/material.dart';
import '../utils/theme.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyState({
    super.key,
    this.title = '还没有记录',
    this.subtitle = '写下第一念吧。',
    this.icon = Icons.edit_note_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: c.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 36,
              color: c.textTertiary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: c.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
