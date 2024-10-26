import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sneaker/models/carts_model.dart';
import 'package:sneaker/service/cart_service.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> cartItems = [];
  final CartService _cartService = CartService();

  // Exchange rate between USD and VND

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    try {
      final items = await _cartService.fetchCartItems();
      setState(() {
        cartItems = items;
      });
    } catch (e) {
      print('Error fetching cart items: $e');
    }
  }

  void _removeCartItem(CartItem item) async {
    try {
      await _cartService.removeCartItem(item.id);
      setState(() {
        cartItems.remove(item);
      });
    } catch (e) {
      print('Error removing cart item: $e');
    }
  }

  void _updateQuantity(CartItem item, int newQuantity) async {
    try {
      await _cartService.updateCartItemQuantity(
          item.id, newQuantity); // Update in MongoDB
      setState(() {
        item.quantity = newQuantity; // Update locally
      });
    } catch (e) {
      print('Error updating cart item quantity: $e');
    }
  }

  double getTotalPriceInVND() {
    return cartItems.fold(
      0.0,
      (total, item) => total + (item.getTotalPrice() * item.quantity),
    );
  }

  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN', // Vietnamese locale
      symbol: 'VND', // Currency symbol
      decimalDigits: 0, // No decimal places for currency
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ Hàng'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Text('Giỏ hàng trống', style: TextStyle(fontSize: 18)),
            )
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.productName,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('Giá: ${item.price.toString()}',
                                style: TextStyle(
                                    fontSize:
                                        16)), // Ensure item.price is double
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove, color: Colors.red),
                              onPressed: () {
                                if (item.quantity > 1) {
                                  _updateQuantity(item, item.quantity - 1);
                                }
                              },
                            ),
                            Text(item.quantity.toString(),
                                style: TextStyle(fontSize: 18)),
                            IconButton(
                              icon: Icon(Icons.add, color: Colors.green),
                              onPressed: () {
                                _updateQuantity(item, item.quantity + 1);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.grey),
                              onPressed: () => _removeCartItem(item),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Tổng: ${formatCurrency(getTotalPriceInVND())}', // Format the total price
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
