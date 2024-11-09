import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sneaker/models/carts_model.dart';

class CartService {
  final String apiUrl = 'http://192.168.1.4:5002';

  // Helper method to handle MongoDB ObjectId conversion
  String normalizeId(String id) {
    // Remove any quotes and trim whitespace
    return id.replaceAll('"', '').trim();
  }

  Future<void> addCartItem(String userId, CartItem cartItem) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/cart'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          ...cartItem.toJson(),
          'userId': normalizeId(userId),
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to add cart item: ${response.body}');
      }
    } catch (e) {
      print('Error adding cart item: $e');
      throw Exception('Failed to add cart item');
    }
  }

  Future<List<CartItem>> fetchCartItems(String userId) async {
    try {
      final normalizedUserId = normalizeId(userId);
      final response = await http.get(
        Uri.parse('$apiUrl/cart/$normalizedUserId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => CartItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load cart items: ${response.body}');
      }
    } catch (e) {
      print('Error fetching cart items: $e');
      throw Exception('Failed to load cart items');
    }
  }

  Future<void> removeCartItem(String userId, String itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/cart/$userId/$itemId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete cart item: ${response.body}');
      }
    } catch (e) {
      print('Error deleting cart item: $e');
      throw Exception('Failed to delete cart item');
    }
  }

  Future<void> updateCartItemQuantity(
    String userId,
    String itemId,
    int newQuantity,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/cart/$userId/$itemId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'quantity': newQuantity}),
      );

      if (response.statusCode != 200) {
        print('Server response: ${response.body}');
        throw Exception(
            'Failed to update cart item quantity: ${response.body}');
      }
    } catch (e) {
      print('Error updating cart item quantity: $e');
      throw Exception('Failed to update cart item quantity');
    }
  }
}
