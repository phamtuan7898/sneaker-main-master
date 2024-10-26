import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sneaker/models/user_model.dart';

class AuthService {
  final String apiUrl = 'http://192.168.1.7:5002';

  Future<void> register(String username, String password, String email,
      {String img = '', String phone = '', String address = ''}) async {
    final response = await http.post(
      Uri.parse('$apiUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
        'email': email,
        'img': img,
        'phone': phone,
        'address': address,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to register');
    }
  }

  Future<UserModel> login(String usernameOrEmail, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username':
            usernameOrEmail, // usernameOrEmail có thể là email hoặc username
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return UserModel.fromMap(json.decode(response.body));
    } else {
      throw Exception('Đăng nhập không thành công');
    }
  }

  Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$apiUrl/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send reset password link');
    }
  }
}
