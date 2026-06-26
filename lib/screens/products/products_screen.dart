import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../utils/theme.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_shimmer.dart';

class ProductsScreen extends StatefulWidget {
  final String? categorySlug;
  final String? categoryName;
  final bool isNew;
  final bool sale;
  const ProductsScreen({super.key, this.categorySlug, this.categoryName, this.isNew = false, this.sale = false});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();
  List<Product> _products = [];
  bool _loading = true;
  String _sort = 'newest';
  int _page = 1;
  int _totalPages = 1;
  String? _query;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool reset = true}) async {
    if (reset) { setState(() { _loading = true; _page = 1; }); }
    try {
      final result = await ProductService.list(
        category: widget.categorySlug, q: _query, sort: _sort,
        isNew: widget.isNew, sale: widget.sale, page: _page,
      );
      setState(() {
        _products = reset ? result.products : [..._products, ...result.products];
        _totalPages = result.totalPages;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName ?? (widget.isNew ? 'المنتجات الجديدة' : widget.sale ? 'العروض' : 'جميع المنتجات'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن منتج...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: AppColors.off,
                    ),
                    onSubmitted: (v) { _query = v; _load(); },
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort, color: AppColors.navy),
                  onSelected: (v) { setState(() => _sort = v); _load(); },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'newest', child: Text('الأحدث')),
                    PopupMenuItem(value: 'price_asc', child: Text('السعر: الأقل')),
                    PopupMenuItem(value: 'price_desc', child: Text('السعر: الأعلى')),
                    PopupMenuItem(value: 'popular', child: Text('الأكثر مشاهدة')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const ProductGridShimmer()
                : _products.isEmpty
                    ? const Center(child: Text('لا توجد منتجات', style: TextStyle(color: AppColors.muted)))
                    : RefreshIndicator(
                        color: AppColors.gold,
                        onRefresh: () => _load(),
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (n) {
                            if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200 && _page < _totalPages && !_loading) {
                              _page++;
                              _load(reset: false);
                            }
                            return false;
                          },
                          child: GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.66),
                            itemCount: _products.length,
                            itemBuilder: (context, i) => ProductCard(product: _products[i]),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
