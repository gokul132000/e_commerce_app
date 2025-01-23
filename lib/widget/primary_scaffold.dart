import 'package:e_commerce_app/app/app_routes.dart';
import 'package:e_commerce_app/widget/primary_app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../providers/product_search_provider.dart';
import '../resource/app_colors.dart';

class PrimaryScaffold extends ConsumerStatefulWidget {
  final Widget body;
  final String appBarTitle;
  final Widget? bottomNavigationBar;
  final ScrollController scrollController;
  final bool isBackArrowEnable;

  const PrimaryScaffold({required this.body, required this.appBarTitle, this.bottomNavigationBar,required this.scrollController,this.isBackArrowEnable = true});

  @override
  ConsumerState<PrimaryScaffold> createState() => _PrimaryScaffoldState();
}

class _PrimaryScaffoldState extends ConsumerState<PrimaryScaffold> {
  FocusNode focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    bool isMobile = !kIsWeb;
    final productAsyncValue = ref.watch(productProvider);
    final productSearchState = ref.watch(productSearchProvider);

    return PopScope(
      canPop: true,
      child: SafeArea(
        child: Scaffold(
          appBar: PrimaryAppBar(appBarTitle: widget.appBarTitle,isBackArrowEnable: widget.isBackArrowEnable,),
          backgroundColor: AppColors.mainBackgroundColor,
          body: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if(!isMobile)
                  GestureDetector(
                    onTap: () {
                      _scrollIncrementally(up: true, context: context);
                    },
                    child: Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.arrow_drop_up_outlined,
                        color: Colors.grey,
                        size: 19,
                      ),
                    ),
                  ),
                  Expanded(
                    child: KeyboardListener(
                      focusNode: focusNode,
                      autofocus: true,
                      onKeyEvent: (KeyEvent event) {
                        _keyBoardScrollController(
                            event: event
                        );
                      },
                      child: Scrollbar(
                        thickness: isMobile ? 0 : 15,
                        thumbVisibility: true,
                        scrollbarOrientation: ScrollbarOrientation.right,
                        trackVisibility: true,
                        interactive: true,
                        radius: Radius.zero,
                        controller: widget.scrollController,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: widget.body,
                        ),
                      ),
                    ),
                  ),
                  if(!isMobile)
                  GestureDetector(
                    onTap: () {
                      _scrollIncrementally(up: false, context: context,);
                    },
                    child: Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.arrow_drop_down_outlined,
                        color: Colors.grey,
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),
              if (productSearchState.searchQuery.isNotEmpty)
                Positioned(
                  top: 20,
                  left: 16,
                  right: 16,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    elevation: 2,
                    child: productAsyncValue.when(
                      data: (products) {
                        final filteredProducts = productSearchState.filteredProducts;
                        return Container(
                          constraints: BoxConstraints(
                            maxHeight: 300,
                            minWidth: 150
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return ListTile(
                                onTap: () {
                                  if((ModalRoute.of(context)?.settings.name?.isEmpty ?? false)|| ModalRoute.of(context)?.settings.name == '/'){
                                    ref.read(productSearchProvider.notifier).updateSearchQuery("",product.title);
                                    ref.read(productSearchProvider.notifier).filterProducts(product.title);
                                    FocusScope.of(context).unfocus();
                                  }else{
                                    AppRoutes.instance.navigateScreen(context, AppRoutesEnum.productPage);
                                    Future.delayed(Duration(seconds: 2,),(){
                                      ref.read(productSearchProvider.notifier).updateSearchQuery("",product.title);
                                      ref.read(productSearchProvider.notifier).filterProducts(product.title);
                                      FocusScope.of(context).unfocus();
                                    });
                                  }
                                },
                                title: Text(product.title),
                              );
                            },
                          ),
                        );
                      },
                      loading: () => CircularProgressIndicator(),
                      error: (error, stack) => Center(child: Text('Error: $error')),
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: widget.bottomNavigationBar,
        ),
      ),
    );
  }

  void _scrollIncrementally({required bool up, required BuildContext context,}) {
    final currentOffset = widget.scrollController.offset;
    final viewportHeight = MediaQuery.of(context).size.height;

    final newOffset = up
        ? (currentOffset - viewportHeight * 0.5).clamp(0.0, widget.scrollController.position.maxScrollExtent)
        : (currentOffset + viewportHeight * 0.5).clamp(0.0, widget.scrollController.position.maxScrollExtent);

    widget.scrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  _keyBoardScrollController({required KeyEvent event}){
    double currentScrollPosition = widget.scrollController.position.pixels;
    double maxScroll = widget.scrollController.position.maxScrollExtent;
    double minScroll = widget.scrollController.position.minScrollExtent;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown && currentScrollPosition < maxScroll) {
      widget.scrollController.jumpTo(currentScrollPosition + 50);
    }
    else if (event.logicalKey == LogicalKeyboardKey.arrowUp && currentScrollPosition > minScroll) {
      widget.scrollController.jumpTo(currentScrollPosition - 50);
    }
  }
}
