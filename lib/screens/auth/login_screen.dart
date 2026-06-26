import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/toast.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      return ToastUtil.show('يرجى تعبئة جميع الحقول', isError: true);
    }
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().login(_emailController.text.trim(), _passwordController.text);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ToastUtil.show('$e', isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text('مرحباً بعودتك', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.navy)),
            const SizedBox(height: 6),
            const Text('سجّل دخولك لمتابعة التسوق', style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 28),
            TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'البريد الإلكتروني')),
            const SizedBox(height: 14),
            TextField(
              controller: _passwordController, obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 20), onPressed: () => setState(() => _obscure = !_obscure)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('تسجيل الدخول'),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: const Text.rich(TextSpan(text: 'ليس لديك حساب؟ ', style: TextStyle(color: AppColors.muted), children: [TextSpan(text: 'إنشاء حساب', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700))])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
