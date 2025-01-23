import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/app_routes.dart';
import '../resource/app_colors.dart';
import '../resource/app_dimenstion.dart';
import 'primary_text.dart';
import '../screens/cart_page.dart';
import '../providers/product_search_provider.dart';

class PrimaryAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final String appBarTitle;
  final bool isBackArrowEnable;
  const PrimaryAppBar({super.key, required this.appBarTitle,this.isBackArrowEnable = true});

  @override
  ConsumerState<PrimaryAppBar> createState() => _PrimaryAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class _PrimaryAppBarState extends ConsumerState<PrimaryAppBar> {
  bool isMobile = !kIsWeb;
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return PreferredSize(
      preferredSize: Size.fromHeight(80),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        height: 80,
        color: AppColors.appBarColor,
        child: SafeArea(
          child: Row(
            children: [
              if(!isMobile)
              ...[
              PrimaryText(
                text: widget.appBarTitle,
                color: AppColors.containerBackgroundColor,
                size: isMobile ? AppDimen.textSize16 : AppDimen.textSize22,
                weight: FontWeight.bold,
              ),
              SizedBox(width: 10),
              ]
              else if(widget.isBackArrowEnable)
                IconButton(onPressed: (){
                  Navigator.pop(context);
                }, icon: Icon(Icons.arrow_back,color: AppColors.containerBackgroundColor,)
                )
              else
                SizedBox.shrink(),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal:  !isMobile ? 60 : 20),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.containerBackgroundColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child:  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 12.5),
                      hintText: "Search products",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      prefixIcon:  Icon(Icons.search),
                    ),
                    onChanged: (query) {
                      ref.read(productSearchProvider.notifier).updateSearchQuery(query);
                    },
                  ),
                ),
              ),
              SizedBox(width: 10),

              if(ModalRoute.of(context)?.settings.name != '/cart_page')
              IconButton(
                icon: Icon(Icons.shopping_cart, color: AppColors.iconColor),
                onPressed: () {
                  AppRoutes.instance.navigateScreen(context, AppRoutesEnum.cartPage
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
