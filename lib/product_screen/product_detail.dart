import 'package:flutter/material.dart';
import 'package:sneaker/models/carts_model.dart';
import 'package:sneaker/models/products_model.dart';
import 'package:sneaker/service/cart_service.dart';

class ProductDetail extends StatelessWidget {
  final ProductModel product;

  ProductDetail({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.productName),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageCarousel(),
              SizedBox(height: 20),
              _buildTitleAndPrice(),
              SizedBox(height: 10),
              _buildDescription(),
              SizedBox(height: 20),
              _buildAvailableSizes(),
              SizedBox(height: 20),
              _buildAvailableColors(),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildAddToCartButton(context),
    );
  }

  Widget _buildImageCarousel() {
    return Container(
      height: 300,
      child: PageView.builder(
        itemCount: product.image.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.network(
              product.image[index],
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitleAndPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            product.productName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          product.price,
          style: TextStyle(
            fontSize: 20,
            color: Colors.blueAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          product.description,
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
      ),
    );
  }

  Widget _buildAvailableSizes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kích cỡ có sẵn:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          children: product.size.map((size) {
            return Chip(
              label: Text(size),
              backgroundColor: Colors.blue[100],
              padding: EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2, // Adding shadow to chips
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAvailableColors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Màu sắc có sẵn:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 8.0),
        Row(
          children: product.color.map((colorHex) {
            Color color =
                Color(int.parse(colorHex)); // Convert hex code to Color
            return Container(
              width: 30,
              height: 30,
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(color: Colors.black54, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10), // Padding for button
      child: ElevatedButton(
        onPressed: () {
          _showQuantityDialog(context);
        },
        child: Text(
          'Thêm vào giỏ hàng',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15),
          backgroundColor: Colors.blueAccent,
          textStyle: TextStyle(fontSize: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          minimumSize: Size(double.infinity, 50), // Full-width button
        ),
      ),
    );
  }

  void _showQuantityDialog(BuildContext context) {
    int quantity = 1; // Default quantity

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chọn số lượng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      if (quantity > 1) {
                        quantity--;
                        (context as Element)
                            .markNeedsBuild(); // Refresh the dialog
                      }
                    },
                  ),
                  Text(
                    '$quantity',
                    style: TextStyle(fontSize: 24),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      quantity++;
                      (context as Element)
                          .markNeedsBuild(); // Refresh the dialog
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Thêm'),
              onPressed: () async {
                CartItem cartItem = CartItem(
                  id: product.id,
                  productName: product.productName,
                  price: product.price,
                  quantity: quantity, // Use the selected quantity
                );

                try {
                  await CartService().addCartItem(cartItem);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${product.productName} đã được thêm vào giỏ hàng!'),
                    ),
                  );
                  Navigator.of(context).pop(); // Close the dialog
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Không thể thêm sản phẩm vào giỏ hàng.'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
