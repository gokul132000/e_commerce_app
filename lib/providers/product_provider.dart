import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/product.dart';


final productProvider = FutureProvider<List<Product>>((ref) async {
  final response = await Dio().get('https://fakestoreapi.com/products');
  final products = (response.data as List).map((e) => Product.fromJson(e)).toList();
    return products;
});
