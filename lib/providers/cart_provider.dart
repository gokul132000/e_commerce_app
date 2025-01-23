import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  // Store the selection state for each item
  List<bool> selectedItems = [];

  CartNotifier() : super([]);

  void addToCart(CartItem item) {
    final existingItemIndex = state.indexWhere((cartItem) => cartItem.product.id == item.product.id);

    if (existingItemIndex != -1) {
      state[existingItemIndex].quantity += item.quantity;
    } else {
      state = [
        ...state,
        item,
      ];
      selectedItems.add(true);
    }
    state = [...state];
  }

  void updateQuantity(int index, int newQuantity) {
    if (index >= 0 && index < state.length) {
      state[index].quantity = newQuantity;
      state = [...state];
    }
  }

  void removeFromCart(int index) {
    state.removeAt(index);
    selectedItems.removeAt(index); // Remove the corresponding selection state
    state = [...state];
  }

  double getTotalPrice() {
    double total = 0;
    for (var i = 0; i < state.length; i++) {
      if (selectedItems[i]) {
        total += state[i].product.price * state[i].quantity;
      }
    }
    return total;
  }

  // This method will toggle the selection for a particular item in the cart
  void toggleSelection(int index) {
    selectedItems[index] = !selectedItems[index];
    state = [...state]; // Trigger UI update by updating the state
  }

  // Unselect all items
  void unselectAll() {
    selectedItems = List.generate(selectedItems.length, (index) => false);
    state = [...state]; // Trigger UI update when all are unselected
  }

  // Create a StateProvider for the cart's selected state
  var cartSelectionProvider = StateProvider<List<bool>>((ref) => []);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

