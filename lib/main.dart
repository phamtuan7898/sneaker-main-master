import 'package:flutter/material.dart';
import 'package:sneaker/home/cart_screen.dart';
import 'package:sneaker/home/home_screen.dart';
import 'package:sneaker/home/main_screen.dart';
import 'package:sneaker/loginscreen/forgot_password_screen.dart';
import 'package:sneaker/loginscreen/login_screen.dart';
import 'package:sneaker/loginscreen/register_screen.dart';
import 'package:sneaker/loginscreen/wellcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: WelcomeScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/home': (context) => HomeScreen(), // Thêm HomeScreen vào routes
      },
    );
  }
}
