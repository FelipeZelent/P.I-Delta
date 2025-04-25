class ShoppingCart {
  static List<dynamic> cartItems = [];

  static void addItem(dynamic product) {
    final existingItem = cartItems.firstWhere(
      (item) => item['id'] == product['id'],
      orElse: () => null,
    );

    if (existingItem != null) {
      existingItem['quantity']++;
    } else {
      cartItems.add({...product, 'quantity': 1});
    }
  }
}