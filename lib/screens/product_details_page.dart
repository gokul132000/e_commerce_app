import 'package:e_commerce_app/widget/primary_scaffold.dart';
import 'package:e_commerce_app/responsive/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/app_routes.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import '../resource/app_colors.dart';
import '../widget/rating_bar.dart';


final selectedQuantityProvider = StateProvider<int>((ref) => 1);

class ProductDetailsPage extends ConsumerWidget {
  final Product product;

  ProductDetailsPage({required this.product});
  ScrollController scrollController = ScrollController();


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedQuantity = ref.watch(selectedQuantityProvider);
    double itemTotal = product.price * selectedQuantity;

    return PrimaryScaffold(
      scrollController: scrollController,
      appBarTitle: "Product Details",
      body: ResponsiveLayout(
        mobile: buildMobileLayout(context, ref, itemTotal),
        tablet: buildWebLayout(context, ref, itemTotal),
        desktop: buildWebLayout(context, ref, itemTotal),
      ),
    );
  }

  Widget buildMobileLayout(BuildContext context, WidgetRef ref, double itemTotal) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Expanded(
          child: ListView(
            controller: scrollController,
            shrinkWrap: true,
            children: [
              buildProductImage(250),
              SizedBox(height: 20),
              buildProductDetails(context, NeverScrollableScrollPhysics()),
              SizedBox(height: 20),
            ],
          ),
        ),
        SizedBox(
          height: 250,
          width: double.infinity,
          child: buildCartSection(context, ref, itemTotal),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildWebLayout(BuildContext context, WidgetRef ref, double itemTotal) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: buildProductImage(400)),
          SizedBox(width: 40),
          Expanded(flex: 3, child: buildProductDetails(context)),
          SizedBox(width: 40),
          Expanded(flex: 2, child: buildCartSection(context, ref, itemTotal)),
        ],
      ),
    );
  }

  Widget buildCartSection(BuildContext context, WidgetRef ref, double itemTotal) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Quantity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryTextColor)),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400, width: 1),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: ref.watch(selectedQuantityProvider),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    ref.read(selectedQuantityProvider.notifier).state = newValue;
                  }
                },
                items: List.generate(10, (index) => index + 1)
                    .map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString(), style: TextStyle(fontSize: 16)),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 16),
          Text("Total: \$${itemTotal.toStringAsFixed(2)}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryTextColor)),
          SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final cartItem = CartItem(product: product, quantity: ref.read(selectedQuantityProvider));
              ref.read(cartProvider.notifier).addToCart(cartItem);
              AppRoutes.instance.navigateScreen(context, AppRoutesEnum.cartPage);
            },
            icon: Icon(Icons.shopping_cart_outlined, color: Colors.white),
            label: Text("Add to Cart", style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget buildProductDetails(BuildContext context, [ScrollPhysics? physics]) {
    return SingleChildScrollView(
      physics: physics ?? AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryTextColor)),
          SizedBox(height: 8),
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
            itemPadding:
            const EdgeInsets.symmetric(horizontal: 0.0),
            unratedColor: AppColors.ratingBarDefaultColor,
          ),
          SizedBox(height: 12),
          Text(product.description, style: TextStyle(fontSize: 16, color: AppColors.primaryTextColor.withOpacity(0.7))),
          SizedBox(height: 16),
          Text("Price: \$${product.price.toStringAsFixed(2)}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
        ],
      ),
    );
  }

  Widget buildProductImage(double size) {
    return Image.network(
      product.image,
      height: size,
      width: size,
      fit: BoxFit.cover,
    );
  }
}
