import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sneaker/models/carts_model.dart';
import 'package:sneaker/service/auth_service%20.dart';
import 'package:sneaker/service/cart_service.dart';
import 'package:sneaker/models/user_model.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> cartItems = [];
  final CartService _cartService = CartService();
  UserModel? currentUser;
  bool isLoading = true;
  bool isUpdating = false;
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'VND',
    decimalDigits: 0,
  );

  // Helper method to parse price string to double
  double parsePrice(String price) {
    // Remove currency symbol, commas and spaces
    String cleanPrice = price.replaceAll(RegExp(r'[^\d]'), '');
    return double.parse(cleanPrice);
  }

  // Rest of the initialization and user management methods remain the same...
  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      final user = await AuthService().getCurrentUser();
      setState(() {
        currentUser = user;
        isLoading = false;
      });
      if (user != null) {
        await fetchCartItems();
      }
    } catch (e) {
      print('Error getting current user: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCartItems() async {
    if (currentUser == null) return;

    try {
      final items = await _cartService.fetchCartItems(currentUser!.id);
      setState(() {
        cartItems = items;
      });
    } catch (e) {
      print('Error fetching cart items: $e');
      _showErrorMessage('Không thể tải giỏ hàng');
    }
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    if (currentUser == null || isUpdating) return;

    if (newQuantity < 1) {
      _showErrorMessage('Số lượng không thể nhỏ hơn 1');
      return;
    }

    setState(() {
      isUpdating = true;
    });

    try {
      // Sử dụng item.productId thay vì item.id
      await _cartService.updateCartItemQuantity(
        currentUser!.id,
        item.productId,
        newQuantity,
      );

      setState(() {
        final index = cartItems.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          cartItems[index].quantity = newQuantity;
        }
      });

      _showSuccessMessage('Đã cập nhật số lượng');
    } catch (e) {
      print('Error updating cart item quantity: $e');
      _showErrorMessage('Không thể cập nhật số lượng');
      // Khôi phục lại số lượng cũ nếu cập nhật thất bại
      setState(() {
        final index = cartItems.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          cartItems[index].quantity = item.quantity;
        }
      });
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildQuantityControls(CartItem item) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.remove_circle_outline),
          color: Colors.red,
          onPressed: isUpdating
              ? null
              : () => _updateQuantity(item, item.quantity - 1),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            item.quantity.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.add_circle_outline),
          color: Colors.green,
          onPressed: isUpdating
              ? null
              : () => _updateQuantity(item, item.quantity + 1),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('GIỎ HÀNG')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GIỎ HÀNG',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white24, Colors.lightBlueAccent.shade700],
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Giá: ${currencyFormatter.format(parsePrice(item.price))}',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.blueAccent),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            _buildQuantityControls(item),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.grey),
                              onPressed: isUpdating
                                  ? null
                                  : () => _removeCartItem(item),
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
            'Tổng: ${currencyFormatter.format(getTotalPriceInVND())}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Future<void> _removeCartItem(CartItem item) async {
    if (currentUser == null) return;

    try {
      // Sử dụng item.productId thay vì item.id
      await _cartService.removeCartItem(currentUser!.id, item.productId);
      setState(() {
        cartItems.remove(item);
      });
      _showSuccessMessage('Đã xóa sản phẩm khỏi giỏ hàng');
    } catch (e) {
      print('Error removing cart item: $e');
      _showErrorMessage('Không thể xóa sản phẩm');
    }
  }

  double getTotalPriceInVND() {
    return cartItems.fold(
      0.0,
      (total, item) => total + (parsePrice(item.price) * item.quantity),
    );
  }
}
