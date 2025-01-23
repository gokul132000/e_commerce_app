import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';


final productSearchProvider = StateNotifierProvider<ProductSearchNotifier, ProductSearchState>((ref) {
  return ProductSearchNotifier(ref);
});

class ProductSearchState {
  final String searchQuery;
  final List<Product> filteredProducts;
  final String filterString;

  ProductSearchState({
    this.searchQuery = '',
    this.filterString = '',
    this.filteredProducts = const [],
  });
}

class ProductSearchNotifier extends StateNotifier<ProductSearchState> {
  final Ref ref;
  ProductSearchNotifier(this.ref) : super(ProductSearchState());

  void updateSearchQuery(String query,[String filterStringQuery = ""]) {
    state = ProductSearchState(
      searchQuery: query,
      filterString: filterStringQuery,
      filteredProducts: filterProducts(filterStringQuery.isNotEmpty ? filterStringQuery : query), // Update filtered products based on query
    );
  }

  List<Product> filterProducts(String query) {
    final allProducts = ref.read(productProvider).value ?? [];
    return allProducts.where((product) => product.title.contains(query)).toList();
  }
}

