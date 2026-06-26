import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/cart_provider.dart';
import '../../utils/theme.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('سلة التسوق')),
      body: cart.loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : cart.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.gold),
                      const SizedBox(height: 16),
                      const Text('سلتك فارغة!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      const Text('أضف منتجات إلى سلتك للبدء في التسوق', style: TextStyle(color: AppColors.muted)),
                      const SizedBox(height: 20),
                      ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('تصفّح المنتجات')),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: cart.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final item = cart.items[i];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: item.image != null
                                      ? CachedNetworkImage(imageUrl: item.image!, width: 70, height: 70, fit: BoxFit.cover)
                                      : Container(width: 70, height: 70, color: AppColors.off),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                                      if (item.variant != null) Text(item.variant!, style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
                                      const SizedBox(height: 4),
                                      Text(item.priceFormatted, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 13)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        InkWell(onTap: () => context.read<CartProvider>().updateQuantity(item.cartItemId, item.quantity - 1 < 1 ? 1 : item.quantity - 1), child: const Icon(Icons.remove_circle_outline, size: 20, color: AppColors.muted)),
                                        Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w700))),
                                        InkWell(onTap: () => context.read<CartProvider>().updateQuantity(item.cartItemId, item.quantity + 1), child: const Icon(Icons.add_circle_outline, size: 20, color: AppColors.gold)),
                                      ],
                                    ),
                                    IconButton(
                                      onPressed: () => context.read<CartProvider>().remove(item.cartItemId),
                                      icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.red),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: AppColors.off, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('الإجمالي', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                Text(cart.subtotalFormatted, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.gold)),
                              ],
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
                                child: const Text('إتمام الطلب ←'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
