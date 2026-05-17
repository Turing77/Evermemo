import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/sync_service.dart';
import '../utils/theme.dart';
import '../utils/animations.dart';
import 'main_tab_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = '请输入邮箱和密码');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = '密码至少 6 位');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final supabase = SupabaseService.instance;
      if (_isLogin) {
        await supabase.signIn(email, password);
      } else {
        await supabase.signUp(email, password);
      }

      if (!mounted) return;

      // 登录成功后同步数据
      await SyncService.fullSync();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        buildFadeRoute(const MainTabScreen()),
      );
    } catch (e) {
      setState(() => _error = _isLogin ? '登录失败：${e.toString()}' : '注册失败：${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              // Logo
              const Center(
                child: Text(
                  '常记',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: 4,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Evermemo',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // 切换 登录/注册
              Row(
                children: [
                  _buildTabButton('登录', _isLogin),
                  const SizedBox(width: 24),
                  _buildTabButton('注册', !_isLogin),
                ],
              ),
              const SizedBox(height: 32),
              // 邮箱
              _buildTextField(
                controller: _emailController,
                hint: '邮箱',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // 密码
              _buildTextField(
                controller: _passwordController,
                hint: '密码',
                icon: Icons.lock_outline_rounded,
                obscure: true,
              ),
              const SizedBox(height: 8),
              // 错误提示
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 13,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              // 提交按钮
              GestureDetector(
                onTap: _isLoading ? null : _submit,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _isLoading
                        ? AppColors.accent.withValues(alpha: 0.5)
                        : AppColors.accent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.background,
                            ),
                          )
                        : Text(
                            _isLogin ? '登录' : '注册',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.background,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 跳过登录
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      buildFadeRoute(const MainTabScreen()),
                    );
                  },
                  child: const Text(
                    '跳过，先看看',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, bool selected) {
    return GestureDetector(
      onTap: () => setState(() {
        _isLogin = label == '登录';
        _error = null;
      }),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AppColors.textPrimary : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 24,
            height: 2,
            decoration: BoxDecoration(
              color: selected ? AppColors.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textTertiary),
          prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
