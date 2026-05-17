import 'package:flutter/material.dart';
import '../utils/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                        '关于常记',
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
            const Spacer(),
            // App 图标
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.edit_note_rounded,
                size: 44,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '常记',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Evermemo',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textTertiary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '把今日一念，留给来日回望。',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
            const Spacer(flex: 2),
            // 版权信息
            const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Text(
                'Made with Flutter',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
