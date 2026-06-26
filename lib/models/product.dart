class ProductVariant {
  final int id;
  final String name;
  final String value;
  final double priceModifier;
  final int stock;

  ProductVariant({required this.id, required this.name, required this.value, required this.priceModifier, required this.stock});

  factory ProductVariant.fromJson(Map<String, dynamic> j) => ProductVariant(
        id: j['id'],
        name: j['name'] ?? '',
        value: j['value'] ?? '',
        priceModifier: (j['price_modifier'] ?? 0).toDouble(),
        stock: j['stock'] ?? 0,
      );
}

class ProductReview {
  final int id;
  final String? customerName;
  final int rating;
  final String body;
  final String createdAt;

  ProductReview({required this.id, this.customerName, required this.rating, required this.body, required this.createdAt});

  factory ProductReview.fromJson(Map<String, dynamic> j) => ProductReview(
        id: j['id'],
        customerName: j['customer_name'],
        rating: j['rating'] ?? 0,
        body: j['body'] ?? '',
        createdAt: j['created_at'] ?? '',
      );
}

class Product {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? shortDescription;
  final double price;
  final double? salePrice;
  final double currentPrice;
  final int discountPercent;
  final String priceFormatted;
  final String? sku;
  final int stock;
  final String? categoryName;
  final String? categorySlug;
  final String? brand;
  final String? mainImage;
  final List<String> images;
  final List<ProductVariant> variants;
  final double ratingAverage;
  final int ratingCount;
  final List<ProductReview> reviews;
  final bool isNew;
  final bool isFeatured;
  final bool isBestseller;

  Product({
    required this.id, required this.name, required this.slug, this.description, this.shortDescription,
    required this.price, this.salePrice, required this.currentPrice, required this.discountPercent,
    required this.priceFormatted, this.sku, required this.stock, this.categoryName, this.categorySlug,
    this.brand, this.mainImage, this.images = const [], this.variants = const [],
    this.ratingAverage = 0, this.ratingCount = 0, this.reviews = const [],
    this.isNew = false, this.isFeatured = false, this.isBestseller = false,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'],
        name: j['name'] ?? '',
        slug: j['slug'] ?? '',
        description: j['description'],
        shortDescription: j['short_description'],
        price: (j['price'] ?? 0).toDouble(),
        salePrice: j['sale_price'] != null ? (j['sale_price']).toDouble() : null,
        currentPrice: (j['current_price'] ?? j['price'] ?? 0).toDouble(),
        discountPercent: j['discount_percent'] ?? 0,
        priceFormatted: j['price_formatted'] ?? '',
        sku: j['sku'],
        stock: j['stock'] ?? 0,
        categoryName: j['category']?['name'],
        categorySlug: j['category']?['slug'],
        brand: j['brand'],
        mainImage: j['main_image'],
        images: j['images'] != null ? List<String>.from((j['images'] as List).map((i) => i['url'])) : [],
        variants: j['variants'] != null ? List<ProductVariant>.from((j['variants'] as List).map((v) => ProductVariant.fromJson(v))) : [],
        ratingAverage: j['rating'] != null ? (j['rating']['average'] ?? 0).toDouble() : 0,
        ratingCount: j['rating'] != null ? (j['rating']['count'] ?? 0) : 0,
        reviews: j['reviews'] != null ? List<ProductReview>.from((j['reviews'] as List).map((r) => ProductReview.fromJson(r))) : [],
        isNew: j['is_new'] ?? false,
        isFeatured: j['is_featured'] ?? false,
        isBestseller: j['is_bestseller'] ?? false,
      );
}
