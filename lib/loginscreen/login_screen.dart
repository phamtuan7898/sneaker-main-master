import 'package:flutter/material.dart';
import 'package:sneaker/home/main_screen.dart';
import 'package:sneaker/service/auth_service%20.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _inputController =
      TextEditingController(); // TextField dùng chung cho email/username
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _login() async {
    try {
      final user = await _authService.login(
        _inputController.text,
        _passwordController.text,
      );
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(
                userId: user.id), // Use user.id instead of user.userId
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng nhập không thành công')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng Nhập'),
        centerTitle: true,
        backgroundColor: Colors.white24,
        foregroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white24,
              Colors.lightBlueAccent.shade700,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: Duration(seconds: 1),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 3),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/img_logo/modern-sneaker-shoe-logo-vector.jpg',
                          width: 150,
                          height: 150,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller:
                        _inputController, // Dùng chung cho email/username
                    label: 'Tên đăng nhập hoặc Email',
                    icon: Icons.person,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Mật khẩu',
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  _buildElevatedButton(),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot-password');
                    },
                    child: Text('Quên mật khẩu?',
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text('Đăng ký',
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Colors.black54,
              fontSize: 18), // Enhanced label for better visibility
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          prefixIcon:
              Icon(icon, color: Colors.black), // Biểu tượng cho trường nhập
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.black, // Màu viền khi trường nhập được chọn
            ),
          ),
        ),
        obscureText: obscureText,
      ),
    );
  }

  Widget _buildElevatedButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black12,
            Colors.lightBlueAccent.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _login,
        child: Text(
          'Đăng Nhập',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 50),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          textStyle: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
