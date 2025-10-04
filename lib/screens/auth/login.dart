import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tasking/core/constants/constants.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: Column(
                spacing: 5,
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
                  _buildLoginButton(),
                ],
              ),
            ),
          ],
        ),
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
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        prefixIcon: icon,
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
      ),
    );
  }

  Widget _buildLoginButton() {
    return TextButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          _errorText.value = null;
          UserCredential response = await _login();
          if (response.user != null && mounted) {
            context.push('/home');
          }
        }
      },
      style: TextButton.styleFrom(
        backgroundColor: Color(0xFF4a3780),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(5),
        ),
      ),
      child: Center(
        child: Text(
          'Login',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
      _errorText.value = ex.message!;
      throw ex.message!;
    }
  }
}
