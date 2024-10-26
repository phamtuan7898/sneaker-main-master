import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sneaker/models/user_model.dart';

class ApiService {
  final String baseUrl =
      'http://192.168.1.7:5002'; // Replace with your server URL

  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/User/$userId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromMap(data);
      } else {
        print('Failed to load profile: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching user profile: $error');
    }
    return null;
  }

  Future<bool> updateUserProfile(
      String userId, Map<String, dynamic> updatedData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/User/$userId'), // Ensure this matches your API
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        return true; // Update successful
      } else {
        final responseBody = response.body; // Get response body for error
        print(
            'Failed to update profile: ${response.statusCode}, body: $responseBody');
        return false; // Update failed
      }
    } catch (e) {
      print('Error updating user profile: $e');
      return false; // Return false on error
    }
  }

  Future<bool> uploadProfileImage(String userId, File imageFile) async {
    try {
      final request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/User/$userId/upload-image'));

      request.fields['userId'] = userId;
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        return true; // Success
      } else {
        final responseBody = await response.stream.bytesToString();
        print(
            'Upload failed with status: ${response.statusCode}, body: $responseBody');
        return false; // Failed
      }
    } catch (e) {
      print('Error uploading image: $e');
      return false; // Return false on error
    }
  }
}
