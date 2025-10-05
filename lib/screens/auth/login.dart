import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:tasking/core/constants/constants.dart';
import 'package:tasking/core/widgets/custom_button.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ValueNotifier<String?> _errorText = ValueNotifier<String?>(null);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4a3780),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: SvgPicture.asset('assets/ellipse1.svg'),
          ),
          Align(
            alignment: Alignment.topRight,
            child: SvgPicture.asset('assets/ellipse2.svg'),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    spacing: 10,
                    children: [
                      _buildAuthTextField(
                        _emailController,
                        'E-Mail',
                        Icon(Icons.mail_outline),
                      ),
                      ValueListenableBuilder(
                        valueListenable: _errorText,
                        builder: (context, value, child) {
                          return _buildAuthTextField(
                            _passwordController,
                            'Password',
                            Icon(Icons.lock_outline),
                            errorText: value,
                          );
                        },
                      ),
                      CustomButton(
                        text: 'Login',
                        borderRadius: 5,
                        color: Colors.deepPurpleAccent,
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            _errorText.value = null;
                            UserCredential response = await _login();
                            if (response.user != null && context.mounted) {
                              context.go('/home');
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthTextField(
    TextEditingController controller,
    String hintText,
    Widget icon, {
    String? errorText,
  }) {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return 'Required Field';
        }
        return null;
      },
      controller: controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),

        prefixIcon: icon,
        prefixIconColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        errorText: errorText,
        errorStyle: TextStyle(color: const Color.fromARGB(255, 255, 17, 0)),
      ),
    );
  }

  Future<UserCredential> _login() async {
    try {
      UserCredential response = await fireAuthInstance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      return response;
    } on FirebaseAuthException catch (ex) {
      log(ex.code);
      switch (ex.code) {
        case 'invalid-credential':
          _errorText.value = 'Wrong Email or Password';
          break;
        default:
          _errorText.value = ex.message;
          break;
      }

      throw ex.message!;
    }
  }
}
