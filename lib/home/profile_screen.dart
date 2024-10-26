import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sneaker/models/user_model.dart';
import 'package:sneaker/service/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ApiService apiService;
  UserModel? user;
  final ImagePicker _picker = ImagePicker();
  String? absoluteImagePath;

  // TextEditingControllers for each editable field
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final fetchedUser = await apiService.getUserProfile(widget.userId);
      if (fetchedUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user profile.')),
        );
        return;
      }
      setState(() {
        user = fetchedUser;
        absoluteImagePath =
            user?.img != null && user!.img!.isNotEmpty ? user!.img : null;

        // Initialize the controllers with the current user data
        usernameController.text = user!.username ?? '';
        emailController.text = user!.email ?? '';
        phoneController.text = user!.phone ?? '';
        addressController.text = user!.address ?? '';
      });
    } catch (error) {
      print('Error fetching user profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user profile.')),
      );
    }
  }

  Future<void> saveProfileChanges() async {
    try {
      // Prepare the updated data as a map
      final updatedData = {
        'username': usernameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'address': addressController.text,
      };

      // Call the updateUserProfile method with the userId and updatedData
      final success =
          await apiService.updateUserProfile(widget.userId, updatedData);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
        fetchUserProfile(); // Refresh the user profile
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update profile. Please try again.')),
        );
      }
    } catch (error) {
      print('Error updating profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An error occurred while updating your profile.')),
      );
    }
  }

  Future<void> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        uploadImage(File(pickedFile.path));
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> uploadImage(File imageFile) async {
    try {
      final uploadSuccess =
          await apiService.uploadProfileImage(widget.userId, imageFile);
      if (uploadSuccess) {
        fetchUserProfile(); // Refresh user profile
      } else {
        print('Upload failed: $uploadSuccess');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $uploadSuccess')),
        );
      }
    } catch (e) {
      print('Error occurred while uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  Future<String> getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> getAbsoluteImagePath(String relativePath) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/uploads/$relativePath';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
      body: user == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          FutureBuilder<String?>(
                            future: getAbsoluteImagePath(user!.img!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircleAvatar(
                                  radius: 70,
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError ||
                                  snapshot.data == null) {
                                return CircleAvatar(
                                  radius: 70,
                                  backgroundColor: Colors.grey.shade300,
                                  child: Icon(Icons.person,
                                      size: 70, color: Colors.white),
                                );
                              } else {
                                final imagePath = snapshot.data!;
                                final file = File(imagePath);
                                if (!file.existsSync()) {
                                  // If the file doesn't exist, show a default avatar
                                  return CircleAvatar(
                                    radius: 70,
                                    backgroundColor: Colors.grey.shade200,
                                    child: Icon(Icons.person,
                                        size: 70, color: Colors.white),
                                  );
                                }
                                return CircleAvatar(
                                  radius: 70,
                                  backgroundImage: FileImage(file),
                                  backgroundColor: Colors.grey.shade200,
                                );
                              }
                            },
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.edit, color: Colors.white),
                              onPressed: pickImage,
                              padding: EdgeInsets.all(8),
                              constraints: BoxConstraints(),
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              iconSize: 24,
                              tooltip: 'Change Profile Image',
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildProfileEditField('Username', usernameController),
                    SizedBox(height: 10),
                    _buildProfileEditField('Email', emailController),
                    SizedBox(height: 10),
                    _buildProfileEditField('Phone', phoneController),
                    SizedBox(height: 10),
                    _buildProfileEditField('Address', addressController),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: saveProfileChanges,
                      child: Text(
                        'Save Changes',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  TextField _buildProfileEditField(
      String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}
