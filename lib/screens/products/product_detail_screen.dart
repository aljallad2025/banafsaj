import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../utils/theme.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/toast.dart';
import '../auth/login_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String slug;
  const ProductDetailScreen({super.key, required this.slug});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _loading = true;
  int _imageIndex = 0;
  int? _selectedVariantId;
  double _variantModifier = 0;
  int _quantity = 1;
  int _reviewRating = 0;
  final _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await ProductService.detail(widget.slug);
      setState(() {
        _product = p;
        if (p.variants.isNotEmpty) {
          _selectedVariantId = p.variants.first.id;
          _variantModifier = p.variants.first.priceModifier;
        }
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _addToCart() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    try {
      await context.read<CartProvider>().add(_product!.id, variantId: _selectedVariantId, quantity: _quantity);
      ToastUtil.show('✓ تمت الإضافة إلى السلة');
    } catch (e) {
      ToastUtil.show('$e', isError: true);
    }
  }

  Future<void> _submitReview() async {
    if (_reviewRating == 0) return ToastUtil.show('اختر تقييماً أولاً', isError: true);
    if (_reviewController.text.trim().isEmpty) return ToastUtil.show('اكتب تعليقك أولاً', isError: true);
    try {
      await ProductService.submitReview(_product!.id, _reviewRating, _reviewController.text.trim());
      ToastUtil.show('تم إرسال تقييمك وسيظهر بعد المراجعة');
      _reviewController.clear();
      setState(() => _reviewRating = 0);
    } catch (e) {
      ToastUtil.show('$e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.gold)));
    if (_product == null) return const Scaffold(body: Center(child: Text('المنتج غير موجود')));

    final p = _product!;
    final wishlist = context.watch<WishlistProvider>();
    final inWishlist = wishlist.contains(p.id);
    final displayPrice = p.currentPrice + _variantModifier;
    final images = p.images.isNotEmpty ? p.images : (p.mainImage != null ? [p.mainImage!] : []);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.navy,
            flexibleSpace: FlexibleSpaceBar(
              background: images.isNotEmpty
                  ? CachedNetworkImage(imageUrl: images[_imageIndex], fit: BoxFit.cover)
                  : Container(color: AppColors.off, child: const Icon(Icons.local_florist, size: 60, color: AppColors.muted)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (images.length > 1)
                    SizedBox(
                      height: 64,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => GestureDetector(
                          onTap: () => setState(() => _imageIndex = i),
                          child: Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: i == _imageIndex ? AppColors.gold : AppColors.border, width: 2),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: CachedNetworkImage(imageUrl: images[i], fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),
                  if (p.brand != null) Text(p.brand!.toUpperCase(), style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(p.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.navy)),
                  if (p.ratingCount > 0) ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      ...List.generate(5, (i) => Icon(i < p.ratingAverage.round() ? Icons.star : Icons.star_border, size: 16, color: const Color(0xFFF39C12))),
                      const SizedBox(width: 6),
                      Text('(${p.ratingCount} تقييم)', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                    ]),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${displayPrice.toStringAsFixed(2)} ر.س', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.gold)),
                      if (p.discountPercent > 0) Padding(
                        padding: const EdgeInsets.only(right: 10, bottom: 4),
                        child: Text('${p.price.toStringAsFixed(2)} ر.س', style: const TextStyle(fontSize: 15, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                      ),
                    ],
                  ),
                  if (p.shortDescription != null) ...[
                    const SizedBox(height: 10),
                    Text(p.shortDescription!, style: const TextStyle(color: AppColors.muted, fontSize: 14, height: 1.6)),
                  ],
                  if (p.variants.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('${p.variants.first.name}:', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: p.variants.map((v) {
                        final selected = _selectedVariantId == v.id;
                        return GestureDetector(
                          onTap: () => setState(() { _selectedVariantId = v.id; _variantModifier = v.priceModifier; }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: selected ? AppColors.gold : AppColors.border, width: 1.5),
                              borderRadius: BorderRadius.circular(8),
                              color: selected ? AppColors.gold.withOpacity(0.06) : Colors.white,
                            ),
                            child: Text(v.value, style: TextStyle(color: selected ? AppColors.gold : AppColors.text, fontSize: 13.5)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    p.stock > 10 ? '✓ متوفر في المخزن' : p.stock > 0 ? '⚠ كميات محدودة — باقي ${p.stock}' : '✗ غير متوفر',
                    style: TextStyle(color: p.stock > 10 ? AppColors.green : p.stock > 0 ? Colors.orange : AppColors.red, fontWeight: FontWeight.w600, fontSize: 13.5),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(border: Border.all(color: AppColors.border, width: 1.5), borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [
                          IconButton(onPressed: () => setState(() => _quantity = (_quantity > 1) ? _quantity - 1 : 1), icon: const Icon(Icons.remove, size: 18)),
                          Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.w700)),
                          IconButton(onPressed: () => setState(() => _quantity = (_quantity < p.stock) ? _quantity + 1 : _quantity), icon: const Icon(Icons.add, size: 18)),
                        ]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: p.stock > 0 ? _addToCart : null,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy),
                          child: const Text('أضف إلى السلة'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(border: Border.all(color: AppColors.border, width: 1.5), shape: BoxShape.circle),
                        child: IconButton(
                          onPressed: () async {
                            final auth = context.read<AuthProvider>();
                            if (!auth.isLoggedIn) { Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())); return; }
                            final added = await context.read<WishlistProvider>().toggle(p.id);
                            ToastUtil.show(added ? '♥ تمت الإضافة للمفضلة' : 'تمت الإزالة من المفضلة');
                          },
                          icon: Icon(inWishlist ? Icons.favorite : Icons.favorite_border, color: inWishlist ? AppColors.red : AppColors.muted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text('الوصف', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.navy)),
                  const SizedBox(height: 10),
                  Text(p.description ?? 'لا يوجد وصف متاح', style: const TextStyle(height: 1.8, color: AppColors.text)),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('التقييمات (${p.ratingCount})', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.navy)),
                  const SizedBox(height: 12),
                  if (p.reviews.isEmpty)
                    const Text('لا توجد تقييمات بعد', style: TextStyle(color: AppColors.muted))
                  else
                    ...p.reviews.map((r) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Text(r.customerName ?? 'عميل', style: const TextStyle(fontWeight: FontWeight.w700)),
                                const Spacer(),
                                ...List.generate(5, (i) => Icon(i < r.rating ? Icons.star : Icons.star_border, size: 13, color: const Color(0xFFF39C12))),
                              ]),
                              const SizedBox(height: 6),
                              Text(r.body, style: const TextStyle(color: AppColors.muted, fontSize: 13.5)),
                            ],
                          ),
                        )),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.off, borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('أضف تقييمك', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        Row(
                          children: List.generate(5, (i) => GestureDetector(
                                onTap: () => setState(() => _reviewRating = i + 1),
                                child: Icon(i < _reviewRating ? Icons.star : Icons.star_border, size: 28, color: const Color(0xFFF39C12)),
                              )),
                        ),
                        const SizedBox(height: 10),
                        TextField(controller: _reviewController, maxLines: 3, decoration: const InputDecoration(hintText: 'اكتب تعليقك هنا...')),
                        const SizedBox(height: 10),
                        ElevatedButton(onPressed: _submitReview, child: const Text('إرسال التقييم')),
                      ],
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
