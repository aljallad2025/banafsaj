import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../auth/login_screen.dart';
import 'orders_screen.dart';
import '../products/wishlist_screen.dart';
import 'addresses_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('حسابي')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_outline, size: 64, color: AppColors.gold),
                const SizedBox(height: 16),
                const Text('سجّل دخولك للوصول لحسابك', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())), child: const Text('تسجيل الدخول')),
              ],
            ),
          ),
        ),
      );
    }

    final customer = auth.customer!;
    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(radius: 36, backgroundColor: AppColors.gold, child: Text(customer.name.isNotEmpty ? customer.name[0] : '؟', style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w800))),
                const SizedBox(height: 12),
                Text(customer.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                Text(customer.email, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _menuItem(context, Icons.receipt_long_outlined, 'طلباتي', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()))),
          _menuItem(context, Icons.favorite_border, 'المفضلة', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen()))),
          _menuItem(context, Icons.location_on_outlined, 'عناويني', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressesScreen()))),
          _menuItem(context, Icons.chat_bubble_outline, 'تواصل معنا عبر واتساب', () async {
            final uri = Uri.parse('https://wa.me/966500000000');
            if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
          }),
          const Divider(height: 32),
          _menuItem(context, Icons.logout, 'تسجيل الخروج', () async {
            await context.read<AuthProvider>().logout();
          }, color: AppColors.red),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String label, VoidCallback onTap, {Color color = AppColors.navy}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14.5)),
      trailing: const Icon(Icons.chevron_left, color: AppColors.muted),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
