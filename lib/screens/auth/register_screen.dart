import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/toast.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  bool _obscure1 = true, _obscure2 = true;

  Future<void> _register() async {
    if (_firstNameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      return ToastUtil.show('يرجى تعبئة جميع الحقول المطلوبة', isError: true);
    }
    if (_passwordController.text.length < 8) return ToastUtil.show('كلمة المرور يجب أن تكون 8 أحرف على الأقل', isError: true);
    if (_passwordController.text != _confirmController.text) return ToastUtil.show('كلمة المرور غير متطابقة', isError: true);

    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().register(
            firstName: _firstNameController.text.trim(), email: _emailController.text.trim(),
            phone: _phoneController.text.trim(), password: _passwordController.text,
          );
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
      appBar: AppBar(title: const Text('إنشاء حساب')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('انضم لعائلة بنفسج ستور', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.navy)),
            const SizedBox(height: 24),
            TextField(controller: _firstNameController, decoration: const InputDecoration(labelText: 'الاسم *')),
            const SizedBox(height: 12),
            TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'البريد الإلكتروني *')),
            const SizedBox(height: 12),
            TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الجوال')),
            const SizedBox(height: 12),
            TextField(controller: _passwordController, obscureText: _obscure1, decoration: InputDecoration(labelText: 'كلمة المرور *', suffixIcon: IconButton(icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility, size: 20), onPressed: () => setState(() => _obscure1 = !_obscure1)))),
            const SizedBox(height: 12),
            TextField(controller: _confirmController, obscureText: _obscure2, decoration: InputDecoration(labelText: 'تأكيد كلمة المرور *', suffixIcon: IconButton(icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility, size: 20), onPressed: () => setState(() => _obscure2 = !_obscure2)))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('إنشاء الحساب'),
              ),
            ),
            const SizedBox(height: 14),
            Center(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('لديك حساب؟ تسجيل الدخول', style: TextStyle(color: AppColors.gold)))),
          ],
        ),
      ),
    );
  }
}
