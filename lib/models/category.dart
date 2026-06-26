class Category {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;
  final String? image;
  final int productsCount;

  Category({required this.id, required this.name, required this.slug, this.description, this.icon, this.image, this.productsCount = 0});

  factory Category.fromJson(Map<String, dynamic> j) => Category(
        id: j['id'],
        name: j['name'] ?? '',
        slug: j['slug'] ?? '',
        description: j['description'],
        icon: j['icon'],
        image: j['image'],
        productsCount: j['products_count'] ?? 0,
      );
}
