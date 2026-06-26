import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/theme.dart';
import 'home_screen.dart';
import '../products/products_screen.dart';
import '../cart/cart_screen.dart';
import '../products/wishlist_screen.dart';
import '../account/account_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});
  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    ProductsScreen(),
    CartScreen(),
    WishlistScreen(),
    AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<CartProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'الرئيسية'),
          const BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view), label: 'المنتجات'),
          BottomNavigationBarItem(
            icon: Badge(label: Text('${cart.itemCount}'), isLabelVisible: cart.itemCount > 0, backgroundColor: AppColors.gold, child: const Icon(Icons.shopping_cart_outlined)),
            activeIcon: Badge(label: Text('${cart.itemCount}'), isLabelVisible: cart.itemCount > 0, backgroundColor: AppColors.gold, child: const Icon(Icons.shopping_cart)),
            label: 'السلة',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'المفضلة'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}
