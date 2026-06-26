import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../products/products_screen.dart';

class CategoryProductsScreen extends StatelessWidget {
  final Category category;
  const CategoryProductsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return ProductsScreen(categorySlug: category.slug, categoryName: category.name);
  }
}
