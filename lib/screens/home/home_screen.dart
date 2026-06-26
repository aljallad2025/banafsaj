import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../models/product.dart';
import '../../models/category.dart';
import '../../services/product_service.dart';
import '../../services/config_service.dart';
import '../../utils/theme.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../products/products_screen.dart';
import '../products/product_detail_screen.dart';
import 'category_products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _slides = [];
  List<Category> _categories = [];
  List<Product> _featured = [];
  List<Product> _newProducts = [];
  List<Product> _bestsellers = [];
  int _tabIndex = 0;
  bool _loading = true;
  final _pageController = PageController();
  int _currentSlide = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        ConfigService.slides(),
        ProductService.categories(),
        ProductService.list(featured: true),
        ProductService.list(isNew: true),
        ProductService.list(bestseller: true),
      ]);
      setState(() {
        _slides = results[0] as List<Map<String, dynamic>>;
        _categories = results[1] as List<Category>;
        _featured = (results[2] as ProductListResult).products;
        _newProducts = (results[3] as ProductListResult).products;
        _bestsellers = (results[4] as ProductListResult).products;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<Product> get _activeTabProducts => [_featured, _newProducts, _bestsellers][_tabIndex];

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.gold)));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              title: const Text('بنفسج ستور', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: AppColors.navy),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen())),
                ),
              ],
            ),
            if (_slides.isNotEmpty) SliverToBoxAdapter(child: _buildSlider()),
            SliverToBoxAdapter(child: _buildFeaturesBar()),
            SliverToBoxAdapter(child: _buildCategories()),
            SliverToBoxAdapter(child: _buildTabs()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.66),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => ProductCard(product: _activeTabProducts[i]),
                  childCount: _activeTabProducts.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Center(
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen())),
                    child: const Text('عرض جميع المنتجات ←'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider() {
    return Column(
      children: [
        SizedBox(
          height: 230,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _currentSlide = i),
            itemBuilder: (context, i) {
              final s = _slides[i];
              return Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(imageUrl: s['image'], fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.centerRight, end: Alignment.centerLeft, colors: [AppColors.navy.withOpacity(0.88), AppColors.navy.withOpacity(0.2)])),
                  ),
                  Positioned(
                    right: 20, top: 0, bottom: 0,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (s['subtitle'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.18), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.gold.withOpacity(0.5))),
                                child: Text(s['subtitle'], style: const TextStyle(color: AppColors.gold3, fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                            const SizedBox(height: 10),
                            Text(s['title'] ?? '', textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, height: 1.3)),
                            const SizedBox(height: 14),
                            if (s['button_text'] != null)
                              ElevatedButton(onPressed: () {}, child: Text(s['button_text'])),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        SmoothPageIndicator(
          controller: _pageController,
          count: _slides.length,
          effect: ExpandingDotsEffect(dotColor: AppColors.border, activeDotColor: AppColors.gold, dotHeight: 7, dotWidth: 7, expansionFactor: 3),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildFeaturesBar() {
    final feats = [
      ['🚚', 'شحن سريع'],
      ['✅', 'منتجات أصلية'],
      ['🔄', 'إرجاع مجاني'],
      ['🔒', 'دفع آمن'],
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: feats.map((f) => Column(
          children: [
            Text(f[0], style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(f[1], style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600)),
          ],
        )).toList(),
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('تسوق حسب الفئة', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.navy)),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final c = _categories[i];
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryProductsScreen(category: c))),
                  child: SizedBox(
                    width: 72,
                    child: Column(
                      children: [
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.off,
                            shape: BoxShape.circle,
                            image: c.image != null ? DecorationImage(image: CachedNetworkImageProvider(c.image!), fit: BoxFit.cover) : null,
                          ),
                          child: c.image == null ? Center(child: Text(c.icon ?? '🌸', style: const TextStyle(fontSize: 24))) : null,
                        ),
                        const SizedBox(height: 6),
                        Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.navy)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final labels = ['المميزة', 'الجديدة', 'الأكثر مبيعاً'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: const Color(0xFFECE8E0), borderRadius: BorderRadius.circular(50)),
        child: Row(
          children: List.generate(3, (i) {
            final active = _tabIndex == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _tabIndex = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: active ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: active ? [const BoxShadow(color: Colors.black12, blurRadius: 8)] : null,
                  ),
                  child: Text(labels[i], textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: active ? AppColors.navy : AppColors.muted)),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
