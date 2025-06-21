import 'dart:convert';
import 'dart:io';
import 'package:chatapp/pages/Auth/login_page.dart';
import 'package:chatapp/pages/Auth/signup_auth_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:flutter/gestures.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isObscure = true;
  double _opacity = 0;
  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  File? _selectedImage;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
      await _uploadToCloudinary(_selectedImage!);
    }
  }

  Future<String> _uploadToCloudinary(File imageFile) async {
    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/ddbyofivo/image/upload",
    );
    final request = http.MultipartRequest('POST', url)
      ..fields["upload_preset"] = "chatApp"
      ..fields["folder"] = "Profile Picture"
      ..files.add(await http.MultipartFile.fromPath("file", imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);
      return data["secure_url"];
    } else {
      throw Exception("Upload failed");
    }
  }

  void _showSplash() {
    setState(() => _opacity = 1);
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() => _opacity = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromRGBO(13, 140, 233, 1),
        body: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    await _pickImage();
                    _showSplash();
                  },
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : AssetImage('assets/noProfile.jpg') as ImageProvider,
                    ),
                  ),
                ),
            
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Text(
                    "Sign up!",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 45,
                    ),
                  ),
                ),
            
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "Name",
                      fillColor: const Color.fromARGB(255, 216, 216, 216),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
            
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      hintText: "Username",
                      fillColor: const Color.fromARGB(255, 216, 216, 216),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
            
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      fillColor: const Color.fromARGB(255, 216, 216, 216),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
            
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: TextField(
                    obscureText: _isObscure,
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      fillColor: const Color.fromARGB(255, 216, 216, 216),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      suffixIcon: Listener(
                        onPointerDown: (_) {
                          setState(() {
                            _isObscure = false;
                          });
                        },
                        onPointerUp: (_) {
                          setState(() {
                            _isObscure = true;
                          });
                        },
                        child: AbsorbPointer(
                          child: Icon(
                            _isObscure ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 42, vertical: 25),
                  child: SlideAction(
                    elevation: 4,
                    borderRadius: 50,
                    submittedIcon: Icon(Icons.check, color: Colors.green),
                    innerColor: Colors.white,
                    outerColor: Color.fromRGBO(9, 121, 201, 0.952),
                    sliderButtonIcon: Icon(
                      Icons.arrow_forward,
                      color: Color.fromRGBO(1, 129, 221, 1),
                    ),
                    text: '     Swipe to Sign up',
                    textStyle: TextStyle(fontSize: 20, color: Colors.white),
            
                    onSubmit: () async {
                      if (_selectedImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a profile picture'),
                          ),
                        );
                        return;
                      }
            
                      final dpUrl = await _uploadToCloudinary(_selectedImage!);
            
                      final error = await AuthService.signUpUser(
                        name: nameController.text.trim(),
                        username: usernameController.text.trim(),
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                        dpUrl: dpUrl,
                      );
            
                      if (error != null) {
                        print(error);
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(error)));
                        return;
                      }
            
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                  ),
                ),
            
                const SizedBox(height: 20),
            
                Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    children: [
                      TextSpan(
                        text: "Login",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            nameController.clear();
                            emailController.clear();
                            passwordController.clear();
                            usernameController.clear();
            
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
