import 'package:chatapp/pages/Auth/login_auth_logic.dart';
import 'package:chatapp/pages/chat%20and%20home%20page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscure = true;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromRGBO(12, 140, 233, 1),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Text(
                "Welcome Back!",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 56,
                ),
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              child: TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  hintText: "username",
                  fillColor: const Color.fromARGB(255, 216, 216, 216),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
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
                outerColor: Color.fromRGBO(1, 129, 221, 0.397),
                sliderButtonIcon: Icon(
                  Icons.arrow_forward,
                  color: Color.fromRGBO(1, 129, 221, 1),
                ),
                text: 'Swipe to Login',

                onSubmit: () async {
                  final auth = AuthMethods();

                  String res = await auth.loginUser(
                    username: usernameController.text.trim(),
                    password: passwordController.text.trim(),
                  );

                  if (res == 'success') {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(res)));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
