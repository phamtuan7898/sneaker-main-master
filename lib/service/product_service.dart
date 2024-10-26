import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sneaker/models/products_model.dart';

class ProductService {
  final String apiUrl = 'http://192.168.1.7:5002';

  // Function to send product data
  Future<void> addProduct(
    String productName,
    String shoeType,
    List<String> image, // Updated to List<String> to match the ProductModel
    String price,
    double rating,
    String description,
    List<String> color, // Added color parameter
    List<String> size, // Added size parameter
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'productName': productName,
          'shoeType': shoeType,
          'image': image, // Sending list of images
          'price': price,
          'rating': rating,
          'description': description,
          'color': color, // Send color list
          'size': size, // Send size list
        }),
      );

      if (response.statusCode == 201) {
        // Successfully added the product
        print('Product added successfully');
      } else {
        // Handle unexpected status codes
        throw Exception('Failed to add product: ${response.body}');
      }
    } catch (e) {
      // Catch any exceptions and print them
      print('Error adding product: $e');
      throw Exception('Failed to add product');
    }
  }

  // Function to fetch product data
  Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/products'));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((product) => ProductModel.fromJson(product))
            .toList();
      } else {
        throw Exception('Failed to load products: ${response.body}');
      }
    } catch (e) {
      // Catch any exceptions and print them
      print('Error fetching products: $e');
      throw Exception('Failed to load products');
    }
  }
}
