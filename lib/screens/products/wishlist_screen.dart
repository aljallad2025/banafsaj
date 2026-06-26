import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/toast.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});
  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WishlistProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('المفضلة')),
      body: wishlist.loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : wishlist.items.isEmpty
              ? const Center(child: Text('قائمة المفضلة فارغة', style: TextStyle(color: AppColors.muted)))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.66),
                  itemCount: wishlist.items.length,
                  itemBuilder: (context, i) {
                    final item = wishlist.items[i];
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(slug: item.slug))),
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(children: [
                                Positioned.fill(child: item.mainImage != null ? CachedNetworkImage(imageUrl: item.mainImage!, fit: BoxFit.cover) : Container(color: AppColors.off)),
                                Positioned(
                                  top: 6, left: 6,
                                  child: GestureDetector(
                                    onTap: () async { await context.read<WishlistProvider>().toggle(item.id); ToastUtil.show('تمت الإزالة من المفضلة'); },
                                    child: const CircleAvatar(radius: 14, backgroundColor: Colors.white, child: Icon(Icons.close, size: 14, color: AppColors.red)),
                                  ),
                                ),
                              ]),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                    Text('${item.currentPrice.toStringAsFixed(0)} ر.س', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy)),
                                    GestureDetector(
                                      onTap: () async {
                                        await context.read<CartProvider>().add(item.id);
                                        ToastUtil.show('✓ تمت الإضافة للسلة');
                                      },
                                      child: const CircleAvatar(radius: 14, backgroundColor: AppColors.gold, child: Icon(Icons.add_shopping_cart, size: 14, color: Colors.white)),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
