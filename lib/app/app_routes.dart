import 'package:flutter/material.dart';


enum AppRoutesEnum{
  productPage("/"),
  productDetailsPage("/product_detail"),
  cartPage("/cart_page"),
  checkoutPage("/checkout_page");
  final String routeName;
  const AppRoutesEnum(this.routeName);
}

class AppRoutes {
  AppRoutes._privateConstructor();
  static final AppRoutes _instance = AppRoutes._privateConstructor();

  static AppRoutes get instance => _instance;

  void navigateScreen(BuildContext context, AppRoutesEnum appRouteEnum,[dynamic param,final dynamic onChanged]) {
    Navigator.pushNamed(
      context,
      appRouteEnum.routeName,
      arguments: param,
    );
  }
}



