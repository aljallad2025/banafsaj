import '../models/product.dart';
import '../models/category.dart';
import 'api_service.dart';

class ProductListResult {
  final List<Product> products;
  final int page;
  final int totalPages;
  final int total;
  ProductListResult({required this.products, required this.page, required this.totalPages, required this.total});
}

class ProductService {
  static Future<ProductListResult> list({
    String? category, int? brand, String? q, String sort = 'newest',
    bool isNew = false, bool sale = false, bool featured = false, bool bestseller = false, int page = 1,
  }) async {
    final params = <String, String>{'sort': sort, 'page': '$page'};
    if (category != null) params['category'] = category;
    if (brand != null) params['brand'] = '$brand';
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (isNew) params['is_new'] = '1';
    if (sale) params['sale'] = '1';
    if (featured) params['featured'] = '1';
    if (bestseller) params['bestseller'] = '1';

    final query = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    final data = await ApiService.get('products.php?$query');
    final products = List<Product>.from((data['products'] as List).map((p) => Product.fromJson(p)));
    return ProductListResult(
      products: products,
      page: data['pagination']['page'],
      totalPages: data['pagination']['total_pages'],
      total: data['pagination']['total'],
    );
  }

  static Future<Product> detail(String slug) async {
    final data = await ApiService.get('products.php?slug=$slug');
    return Product.fromJson(data);
  }

  static Future<List<Category>> categories() async {
    final data = await ApiService.get('categories.php');
    return List<Category>.from((data as List).map((c) => Category.fromJson(c)));
  }

  static Future<void> submitReview(int productId, int rating, String body) async {
    await ApiService.post('reviews.php', {'product_id': productId, 'rating': rating, 'body': body});
  }
}
