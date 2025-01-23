import 'package:e_commerce_app/resource/app_dimenstion.dart';
import 'package:e_commerce_app/resource/app_font.dart';
import 'package:e_commerce_app/widget/primary_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/cart_provider.dart';
import '../resource/app_colors.dart';
import '../responsive/responsive_layout.dart';
import '../widget/primary_text.dart';

final selectPaymentMethod = StateProvider<String>((ref) => "Cash");

class CheckoutPage extends ConsumerStatefulWidget {
  final List<bool> selectedItems;

  CheckoutPage({super.key, required this.selectedItems});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  String selectedPaymentMethod = "Cash";
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    double selectedTotal = 0;
    List selectedCartItems = [];

    for (int i = 0; i < cartItems.length; i++) {
      if (widget.selectedItems[i]) {
        selectedCartItems.add(cartItems[i]);
        selectedTotal += cartItems[i].product.price * cartItems[i].quantity;
      }
    }

    return PrimaryScaffold(
      scrollController: scrollController,
      appBarTitle: "Checkout",
      body: selectedCartItems.isEmpty
          ? Center(
              child: PrimaryText(
                text: "No items selected for checkout",
                weight: AppFont.medium,
                size: AppDimen.textSize18,
              ),
            )
          : ResponsiveLayout(
              mobile: buildMobileLayout(
                selectedCartItems,
                selectedTotal,
              ),
              tablet: buildWebLayout(
                selectedCartItems,
                selectedTotal,
              ),
              desktop: buildWebLayout(
                selectedCartItems,
                selectedTotal,
              ),
            ),
    );
  }

  List<Widget> _commonView(var selectedCartItems, var selectedTotal,bool isMobileView) {
    Map _paymentMap = {
      "Cash": Icons.money_sharp,
      "Card": Icons.credit_card,
      "Wallet": Icons.wallet,
    };
    return [
      Expanded(
        flex: isMobileView ? 3 : 7,
        child: ListView.builder(
          itemCount: selectedCartItems.length,
          controller: scrollController,
          itemBuilder: (context, index) {
            final item = selectedCartItems[index];
            double itemTotal = item.product.price * item.quantity;
            return Card(
              color: AppColors.containerBackgroundColor,
              margin: EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        item.product.image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PrimaryText(
                            text: item.product.title,
                            size: AppDimen.textSize16,
                            weight: AppFont.bold,
                            maxLine: 2,
                          ),
                          SizedBox(height: 4),
                          PrimaryText(
                            text: "\$${item.product.price} x ${item.quantity}",
                            color: Colors.grey[700] ?? Colors.grey,
                            size: AppDimen.textSize14,
                          ),
                        ],
                      ),
                    ),
                    PrimaryText(
                      text: "\$${itemTotal.toStringAsFixed(2)}",
                      color: AppColors.primaryColor,
                      size: AppDimen.textSize16,
                      weight: AppFont.semiBold,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      SizedBox(height:isMobileView ? 16 : 0,width:isMobileView ? 0 : 16,),
      Expanded(
        flex: 3,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PrimaryText(
                    text: "Total:",
                    weight: AppFont.bold,
                    size: AppDimen.textSize20,
                  ),
                  PrimaryText(
                    text: "\$${selectedTotal.toStringAsFixed(2)}",
                    weight: AppFont.semiBold,
                    size: AppDimen.textSize20,
                  ),
                ],
              ),
              SizedBox(height: 20),
              PrimaryText(
                text: "Select Payment Method",
                size: AppDimen.textSize18,
                weight: AppFont.semiBold,
              ),
              SizedBox(height: 10),
              Column(
                children: _paymentMap.entries.map((entry) {
                  return _buildPaymentOption(entry.key, entry.value);
                }).toList(),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: PrimaryText(
                            text: "Proceeding with $selectedPaymentMethod")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: PrimaryText(
                  text: "Proceed to Pay",
                  size: AppDimen.textSize18,
                  color: AppColors.containerBackgroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget buildMobileLayout(var selectedCartItems, var selectedTotal) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: _commonView(selectedCartItems, selectedTotal, true),
      ),
    );
  }

  Widget buildWebLayout(var selectedCartItems, var selectedTotal) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: _commonView(selectedCartItems, selectedTotal, false),
      ),
    );
  }

  Widget _buildPaymentOption(String method, IconData icon) {
    final _selectPaymentMethod = ref.watch(selectPaymentMethod);
    return GestureDetector(
      onTap: () {
        ref.read(selectPaymentMethod.notifier).state = method;
        selectedPaymentMethod = method;
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: _selectPaymentMethod == method
              ? AppColors.primaryColor.withValues(alpha: 0.75)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: _selectPaymentMethod == method
                    ? Colors.white
                    : Colors.black),
            SizedBox(width: 10),
            PrimaryText(
              text: method,
              size: AppDimen.textSize16,
              weight: FontWeight.bold,
              color:
                  _selectPaymentMethod == method ? Colors.white : Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
