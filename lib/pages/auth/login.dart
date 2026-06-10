import 'package:didula_api/services/auth_services.dart';
import 'package:didula_api/utils/function.dart';
import 'package:didula_api/widgets/custom/custom_button.dart';
import 'package:didula_api/widgets/custom/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  // Sign in with email and password
  // ignore: unused_element
  Future<void> _signInEmailPassword(BuildContext context) async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      await AuthService().signInUser(email: email, password: password);
      if (context.mounted) {
        UtileFunctions().showSnackBar(context, "User Login Sucessfully");
        GoRouter.of(context).go("/HomePage");
      }
    } catch (e) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Error signing in with email and password: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 1, 18),
        // ignore: sized_box_for_whitespace
        // ignore: sized_box_for_whitespace
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 0, 1, 18),
              // ignore: sized_box_for_whitespace
              borderRadius: BorderRadius.circular(100),
            ),

            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    "assets/logo.jpeg",

                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.54,
                    fit: BoxFit.cover,
                  ),
                  Text(
                    "MORE THAN A TOURNAMENT",
                    style: TextStyle(
                      letterSpacing: 6,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            Custominput(
                              controller: _emailController,
                              lableText: "Email",
                              icon: Icons.email,
                              obscureText: false,
                              validator: (value) {
                                if (!RegExp(
                                  r'^[^@]+@[^@]+\.[^@]+',
                                ).hasMatch(value!)) {
                                  return "Please enter a valid email address";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            Custominput(
                              controller: _passwordController,
                              lableText: "Password",
                              icon: Icons.lock,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your password";
                                }
                                if (value.length < 6) {
                                  return "Password must be at least 6 characters";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Custombutton(
                    text: "Login",
                    width: MediaQuery.of(context).size.width * 0.9,
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        await _signInEmailPassword(context);
                      }
                      // Handle login logic here
                    },
                  ),
                  SizedBox(height: 2),
                  TextButton(
                    onPressed: () {
                      GoRouter.of(context).go("/Register");
                    },
                    child: Text(
                      "Don't have an account?  Register",
                      style: TextStyle(color: Colors.white.withOpacity(0.5)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
