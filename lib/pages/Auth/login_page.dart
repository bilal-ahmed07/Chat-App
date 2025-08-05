import 'package:chatapp/pages/Auth/Auth_button.dart';
import 'package:chatapp/pages/Auth/login_auth_logic.dart';
import 'package:chatapp/pages/Auth/signup_page.dart';
import 'package:chatapp/pages/chat-and-home-page/home_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static route() {
    return MaterialPageRoute(builder: (context) => const LoginPage());
  }

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isObscure = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Let's Go!",
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Username",
                  filled: true,
                  fillColor: const Color.fromARGB(255, 216, 216, 216),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(63, 221, 76, 1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: passwordController,
                obscureText: isObscure,
                decoration: InputDecoration(
                  labelText: "Password",
                  filled: true,
                  fillColor: const Color.fromARGB(255, 216, 216, 216),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isObscure =  !isObscure ;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),
              AppGradientButton(
                buttonText: "Login",
                onPressed: () async {
                  final auth = AuthMethods();

                  String res = await auth.loginUser(
                    username: emailController.text.trim(),
                    password: passwordController.text.trim(),
                  );

                  if (res == 'success') {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("User not found!")));
                  }
                },
              ),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  text: "Don't have an account? ",
                  style: Theme.of(context).textTheme.titleMedium,
                  children: [
                    TextSpan(
                      text: "Sign up",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        // color: const Color.fromRGBO(251, 109, 169, 1),
                        color: Color.fromRGBO(63, 221, 76, 1),
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupPage(),
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
    );
  }
}
