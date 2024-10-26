import 'package:flutter/material.dart';
import 'package:sneaker/models/products_model.dart';
import 'package:sneaker/product_screen/product_detail.dart';
import 'package:sneaker/service/product_service.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    _products = await ProductService().fetchProducts();
  }

  void _filterProducts(String query) {
    setState(() {
      _filteredProducts = _products.where((product) {
        return product.productName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm'),
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _filterProducts(_searchController.text);
                  },
                ),
              ),
              onChanged: _filterProducts,
            ),
            Expanded(
              child: _searchController
                      .text.isNotEmpty // Chỉ hiển thị khi có truy vấn tìm kiếm
                  ? _filteredProducts.isNotEmpty
                      ? GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Số cột trong lưới
                            childAspectRatio:
                                0.7, // Tỉ lệ chiều rộng/chiều cao của mỗi ô
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductDetail(product: product),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 4,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: Image.network(
                                        product.image[
                                            0], // Đường dẫn đến hình ảnh sản phẩm
                                        fit:
                                            BoxFit.contain, // Đổ hình ảnh vào ô
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.productName,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            product.price,
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : Center(child: Text('Không có sản phẩm nào.'))
                  : Center(
                      child: Text(
                          'Vui lòng nhập từ khóa tìm kiếm.')), // Thông báo nếu không có tìm kiếm
            ),
          ],
        ),
      ),
    );
  }
}
