import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sneaker/models/carts_model.dart'; // Import your CartItem model

class CartService {
  final String apiUrl = 'http://192.168.1.7:5002';

  // Function to add cart item
  Future<void> addCartItem(CartItem cartItem) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/cart'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(cartItem.toJson()),
      );

      if (response.statusCode == 201) {
        print('Cart item added successfully');
      } else {
        throw Exception('Failed to add cart item: ${response.body}');
      }
    } catch (e) {
      print('Error adding cart item: $e');
      throw Exception('Failed to add cart item');
    }
  }

  // Function to fetch cart items
  Future<List<CartItem>> fetchCartItems() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/cart'));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((item) => CartItem(
                  id: item['id'],
                  productName: item['productName'],
                  price: item['price'],
                  quantity: item['quantity'],
                ))
            .toList();
      } else {
        throw Exception('Failed to load cart items: ${response.body}');
      }
    } catch (e) {
      print('Error fetching cart items: $e');
      throw Exception('Failed to load cart items');
    }
  }

  // Function to remove cart item
  Future<void> removeCartItem(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/cart/$id'));

      if (response.statusCode == 200) {
        print('Cart item deleted successfully');
      } else {
        throw Exception('Failed to delete cart item: ${response.body}');
      }
    } catch (e) {
      print('Error deleting cart item: $e');
      throw Exception('Failed to delete cart item');
    }
  }

  // Function to update cart item quantity
  Future<void> updateCartItemQuantity(String itemId, int newQuantity) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/cart/$itemId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'quantity': newQuantity,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update cart item quantity: ${response.body}');
      }
    } catch (e) {
      print('Error updating cart item quantity: $e');
      throw Exception('Failed to update cart item quantity');
    }
  }
}
