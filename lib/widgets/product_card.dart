import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../utils/theme.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/auth_provider.dart';
import '../screens/products/product_detail_screen.dart';
import '../screens/auth/login_screen.dart';
import 'toast.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final inWishlist = wishlist.contains(product.id);

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(slug: product.slug))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: product.mainImage != null
                        ? CachedNetworkImage(
                            imageUrl: product.mainImage!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: AppColors.off),
                            errorWidget: (_, __, ___) => Container(color: AppColors.off, child: const Icon(Icons.image_not_supported_outlined, color: AppColors.muted)),
                          )
                        : Container(color: AppColors.off, child: const Icon(Icons.local_florist, color: AppColors.muted, size: 36)),
                  ),
                  if (product.discountPercent > 0)
                    Positioned(top: 8, right: 8, child: _badge('-${product.discountPercent}%', AppColors.red)),
                  if (product.discountPercent == 0 && product.isNew)
                    Positioned(top: 8, right: 8, child: _badge('جديد', AppColors.navy, textColor: AppColors.gold2)),
                  Positioned(
                    top: 6, left: 6,
                    child: Material(
                      color: Colors.white.withOpacity(0.92),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () async {
                          final auth = context.read<AuthProvider>();
                          if (!auth.isLoggedIn) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                            return;
                          }
                          final added = await context.read<WishlistProvider>().toggle(product.id);
                          ToastUtil.show(added ? '♥ تمت الإضافة للمفضلة' : 'تمت الإزالة من المفضلة');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(inWishlist ? Icons.favorite : Icons.favorite_border, size: 16, color: inWishlist ? AppColors.red : AppColors.navy),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (product.brand != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(product.brand!.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppColors.gold, fontWeight: FontWeight.w700)),
                    ),
                  Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy, height: 1.3)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (product.discountPercent > 0)
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text('${product.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                              ),
                            Text('${product.currentPrice.toStringAsFixed(0)} ر.س', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.navy)),
                          ],
                        ),
                      ),
                      Material(
                        color: AppColors.gold,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: product.stock > 0 ? () async {
                            final auth = context.read<AuthProvider>();
                            if (!auth.isLoggedIn) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                              return;
                            }
                            try {
                              await context.read<CartProvider>().add(product.id);
                              ToastUtil.show('✓ تمت الإضافة للسلة');
                            } catch (e) {
                              ToastUtil.show('$e', isError: true);
                            }
                          } : null,
                          child: const Padding(padding: EdgeInsets.all(7), child: Icon(Icons.add_shopping_cart, size: 16, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color bg, {Color textColor = Colors.white}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: TextStyle(color: textColor, fontSize: 10.5, fontWeight: FontWeight.w700)),
      );
}
