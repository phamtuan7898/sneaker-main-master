class CartItem {
  String id; // Product ID
  String productName;
  String price; // Price as a string, consider converting to double if needed
  int quantity;

  CartItem({
    required this.id,
    required this.productName,
    required this.price,
    this.quantity = 1, // Default quantity is 1
  });

  // Convert CartItem to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'price': price,
      'quantity': quantity,
    };
  }

  double getTotalPrice() {
    // Remove commas and currency symbols, then parse the string to double
    final priceWithoutFormatting =
        price.replaceAll(RegExp(r'[^\d]'), ''); // Remove non-numeric characters
    return double.parse(priceWithoutFormatting) /
        1; // Convert string to double (adjust divisor as needed)
  }
}
