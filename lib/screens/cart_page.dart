import 'package:e_commerce_app/resource/app_dimenstion.dart';
import 'package:e_commerce_app/widget/primary_scaffold.dart';
import 'package:e_commerce_app/widget/primary_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/app_routes.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../resource/app_colors.dart';
import '../resource/app_font.dart';
import '../responsive/responsive_layout.dart';
import '../widget/rating_bar.dart';


class CartPage extends ConsumerStatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  ScrollController scrollController = ScrollController();
  List<bool> selectedItems = [];

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    double totalPrice = ref.watch(cartProvider.notifier).getTotalPrice();

    if (selectedItems.length != cartItems.length) {
      selectedItems = List.generate(cartItems.length, (index) => true);
    }

    double selectedTotal = 0;
    for (int i = 0; i < cartItems.length; i++) {
      if (selectedItems[i]) {
        selectedTotal += cartItems[i].product.price * cartItems[i].quantity;
      }
    }

    return PrimaryScaffold(
      scrollController: scrollController,
      appBarTitle: "Cart",
      body: cartItems.isEmpty
          ? Center(child: PrimaryText(text: "Your cart is empty"))
          :  ResponsiveLayout(
        mobile: buildMobileLayout(
          cartItems: cartItems,
          selectedTotal: selectedTotal,
        ),
        tablet: buildWebLayout(
          cartItems: cartItems,
          selectedTotal: selectedTotal,
        ),
        desktop: buildWebLayout(
          cartItems: cartItems,
          selectedTotal: selectedTotal,
        ),
      ),
    );
  }

  Widget buildMobileLayout({var cartItems, var selectedTotal}) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Expanded(
            child: ListView.builder(
                controller: scrollController,
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  return _cardWidget(cartItems[index], index, "mobile");
                })),
        Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PrimaryText(
                    text: "Total Amount: \$${selectedTotal.toStringAsFixed(2)}",
                    size: 20,
                    weight: FontWeight.bold,
                  ),
                ],
              ),
              ...bottomButton(selectedTotal),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> bottomButton(var selectedTotal){
    double totalPrice = ref.watch(cartProvider.notifier).getTotalPrice();
    return [
      SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed:  totalPrice > 0
              ? () {
            AppRoutes.instance.navigateScreen(context, AppRoutesEnum.checkoutPage, selectedItems);
          }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 5,
          ),
          child: PrimaryText(
            text: "Proceed to Checkout",
            color: Colors.white,
          ),
        ),
      ),
      TextButton(
          onPressed: () {
            AppRoutes.instance.navigateScreen(context, AppRoutesEnum.productPage);
          },
          child: PrimaryText(text: "Continue to shopping")),
    ];
  }

  Widget buildWebLayout({var cartItems, var selectedTotal}) {

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: ListView.builder(
                controller: scrollController,
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  return _cardWidget(cartItems[index], index, "web");
                })),
        Container(
          margin: EdgeInsetsDirectional.only(start: 40),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PrimaryText(
                    text: "Total Amount: \$${selectedTotal.toStringAsFixed(2)}",
                    size: 20,
                    weight: FontWeight.bold,
                  ),
                ],
              ),
              ...bottomButton(selectedTotal),
            ],
          ),
        ),
      ],
    );
  }


  Widget _cardWidget(CartItem cartItem, int index, String layout) {
    var selectedItems = ref.watch(cartProvider.notifier).selectedItems;
    bool isSelected = selectedItems[index];

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            ref.read(cartProvider.notifier).toggleSelection(index);
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.all(20.0),
            margin: EdgeInsets.only(bottom: 20.0),
            width: double.infinity,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.containerBackgroundColor.withOpacity(0.2)
                  : AppColors.containerBackgroundColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected ? AppColors.primaryColor : Colors.transparent,
                width: isSelected? 2 : 0,
              ),
            ),
            child: layout == "web"
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _product(cartItem, layout),
                _price(cartItem),
                _quantity(cartItem, index),
                _totTalPrice(cartItem, index),
              ],
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _product(cartItem, layout),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _price(cartItem),
                    _quantity(cartItem, index),
                    _totTalPrice(cartItem, index),
                  ],
                )
              ],
            ),
          ),
        ),
        Positioned(
          top: layout == "mobile" ? 5 : null,
          bottom: layout == "web" ? 40 : null,
          right: 15,
          child: IconButton(
            onPressed: () {
              ref.read(cartProvider.notifier).toggleSelection(index);
            },
            icon: Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked_outlined,
              color: AppColors.primaryColor,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _product(CartItem cartItem, String layout) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PrimaryText(text: "Product", size: AppDimen.textSize18, weight: AppFont.bold),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                cartItem.product.image,
                height: 120,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PrimaryText(
                  text: "Category: ${cartItem.product.category}",
                  size: AppDimen.textSize14,
                  color: AppColors.secondaryTextColor,
                ),
                SizedBox(height: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: layout == "web" ? 320 : 200, minWidth: 120),
                  child: PrimaryText(text: cartItem.product.title, maxLine: 1),
                ),
                SizedBox(height: 10),
                RatingBarIndicator(
                  rating: cartItem.product.rating,
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
                SizedBox(height: 5),
                PrimaryText(text: "${cartItem.product.ratingCount} ratings"),
                SizedBox(height: 10),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _price(CartItem cartItem) {
    return Column(
      children: [
        PrimaryText(text: "Price", size: AppDimen.textSize16, weight: AppFont.bold),
        PrimaryText(text: "\$${cartItem.product.price}", size: AppDimen.textSize16),
      ],
    );
  }

  Widget _quantity(CartItem cartItem, int index) {
    return Column(
      children: [
        PrimaryText(text: "Quantity", size: AppDimen.textSize16, weight: AppFont.bold),
        Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: cartItem.quantity > 1
                  ? () {
                ref.read(cartProvider.notifier).updateQuantity(index, cartItem.quantity - 1);
              }
                  : null,
            ),
            SizedBox(width: 10),
            PrimaryText(text: "${cartItem.quantity}", size: AppDimen.textSize18, weight: AppFont.bold),
            SizedBox(width: 10),
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.add_circle_outline, color: AppColors.priceTextColor),
              onPressed: () {
                ref.read(cartProvider.notifier).updateQuantity(index, cartItem.quantity + 1);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _totTalPrice(CartItem cartItem, int index) {
    double itemTotal = cartItem.product.price * cartItem.quantity;
    return Column(
      children: [
        PrimaryText(text: "Total Price", size: AppDimen.textSize16, weight: AppFont.bold),
        PrimaryText(text: "\$${itemTotal.toStringAsFixed(2)}", size: AppDimen.textSize16),
      ],
    );
  }
}
