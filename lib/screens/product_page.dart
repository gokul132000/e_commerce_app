import 'package:e_commerce_app/models/product.dart';
import 'package:e_commerce_app/resource/app_colors.dart';
import 'package:e_commerce_app/resource/app_dimenstion.dart';
import 'package:e_commerce_app/resource/app_font.dart';
import 'package:e_commerce_app/widget/primary_scaffold.dart';
import 'package:e_commerce_app/widget/primary_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../providers/product_search_provider.dart';
import '../responsive/responsive_layout.dart';
import '../widget/rating_bar.dart';
import 'product_details_page.dart';


class ProductPage extends ConsumerStatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends ConsumerState<ProductPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final productAsyncValue = ref.watch(productProvider);
    final filterStringQuery = ref.watch(productSearchProvider).filterString;

    return PrimaryScaffold(
      appBarTitle: "Products",
      isBackArrowEnable: false,
      scrollController: _scrollController,
      body: productAsyncValue.when(
        data: (products) {
          final filteredProducts = filterStringQuery.isEmpty
              ? products
              : products.where((product) {
            return product.title
                .toLowerCase()
                .contains(filterStringQuery.toLowerCase());
          }).toList();

          return Column(
            children: [
              Expanded(
                child: ResponsiveLayout(
                  mobile: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(8),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return SizedBox(
                        height: MediaQuery.of(context).size.height / 2,
                          child: _buildProductCard(context, product));
                    },
                  ),
                  tablet: GridView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _buildProductCard(context, product);
                    },
                  ),
                  desktop: GridView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    padding: EdgeInsets.all(16),
                    scrollDirection: Axis.vertical,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 25,
                      childAspectRatio: 2.2 / 3,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _buildProductCard(context, product);
                    },
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: PrimaryText(text: 'Error: $error')),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(product: product),
            settings: RouteSettings(name: '/product_details')
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: AppColors.containerBackgroundColor,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2),
                ],
              ),
              child: Container(
                margin: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: AppColors.containerBackgroundColor,
                  image: DecorationImage(
                    image: NetworkImage(product.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PrimaryText(
                    text: product.title,
                    maxLine: 2,
                    weight: AppFont.semiBold,
                  ),
                  RatingBarIndicator(
                    rating: product.rating,
                    direction: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) => const Icon(
                      Icons.star,
                      color: AppColors.buttonColor,
                      size: 2,
                    ),
                    itemSize: 16,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                    unratedColor: AppColors.ratingBarDefaultColor,
                  ),
                  SizedBox(height: 4),
                  PrimaryText(
                    text: '\$${product.price}',
                    weight: AppFont.bold,
                    size: AppDimen.textSize18,
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



