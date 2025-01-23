import 'dart:ui';

import 'package:e_commerce_app/app/app_routes.dart';
import 'package:e_commerce_app/screens/cart_page.dart';
import 'package:e_commerce_app/screens/product_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_commerce_app/models/product.dart';
import 'package:e_commerce_app/screens/checkout_page.dart';

import '../resource/app_colors.dart';
import '../screens/product_page.dart';


class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(Colors.grey),
          trackColor: MaterialStateProperty.all(Colors.grey[300]),
        ),
        useMaterial3: true,
      ),
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutesEnum.productPage.routeName,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
                builder: (context) => ProductPage(),
                settings: settings
            );
          case '/product_details':
            final product = settings.arguments as Product;
            return MaterialPageRoute(
                builder: (context) => ProductDetailsPage(product: product),
                settings: settings
            );
          case '/cart_page':
            return MaterialPageRoute(builder: (context) => CartPage(),
                settings: settings);
          case '/checkout_page':
            final product = settings.arguments as List<bool>;
            return MaterialPageRoute(builder: (context) =>  CheckoutPage(selectedItems: product),
                settings: settings);

          default:
            return MaterialPageRoute(builder: (context) => ProductPage(),
                settings: settings);
        }
      },
    );
  }
}

class MyCustomScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}