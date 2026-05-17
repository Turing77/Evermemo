import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/animations.dart';
import '../services/supabase_service.dart';
import '../services/sync_service.dart';
import 'main_tab_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _subtitleController;
  late AnimationController _buttonController;

  @override
  void initState() {
    super.initState();
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _subtitleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _titleController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _subtitleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _enter() {
    final supabase = SupabaseService.instance;
    if (supabase.isLoggedIn) {
      SyncService.fullSync();
      Navigator.of(context).pushReplacement(
        buildFadeRoute(const MainTabScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        buildFadeRoute(const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            // App 名称
            Center(
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _titleController,
                  curve: Curves.easeOut,
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _titleController,
                    curve: Curves.easeOutCubic,
                  )),
                  child: const Text(
                    '常记',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 副标题
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _subtitleController,
                curve: Curves.easeOut,
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _subtitleController,
                  curve: Curves.easeOutCubic,
                )),
                child: const Text(
                  '把今日一念，留给来日回望。',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textTertiary,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const Spacer(flex: 2),
            // 分页小圆点
            FadeTransition(
              opacity: _buttonController,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // 进入按钮
            FadeTransition(
              opacity: _buttonController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _buttonController,
                  curve: Curves.easeOutCubic,
                )),
                child: GestureDetector(
                  onTap: _enter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      '开始记录',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.background,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
