import 'package:organizer/components/my_button.dart';
import 'package:organizer/components/my_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:organizer/pages/forgot_password_page.dart';
import 'package:organizer/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:organizer/components/square_tile.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editing controllers
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  //signUserIn method
  void signUserIn() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      //show error msg
      showDialog(
        context: context, 
        builder: (context){
          return AlertDialog(
            content: Text(e.message.toString()),
        );
      });
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepOrange,
          title: Center(
              child: Text(
            message,
            style: const TextStyle(color: Colors.white),
          )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                // logo
                Image.asset(
                  "lib/images/organizer_logo.png",
                  height: 200,
                  width: 200,
                ),
                // welcome back
                const Text(
                  "Welcome back",
                  style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 16),
                ),

                const SizedBox(height: 25),
                // email textfield
                MyTextField(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false,
                ),

                const SizedBox(height: 25),

                // password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: "Password",
                  obscureText: true,
                ),

                const SizedBox(height: 10),
                // forgot password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context){
                                return const ForgotPasswordPage();
                              },
                            ),
                          );
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),
                // sign in button
                MyButton(
                  onTap: signUserIn,
                  text: "Sign In",
                ),

                const SizedBox(
                  height: 50,
                ),
                // or continue with
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.black,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "or continue with",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 50,
                ),
                // google sign in button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Google button
                    SquareTile(
                        onTap: () => AuthService().signInWithGoogle(),
                        imagePath: "lib/images/Google_Icons-09-512.png"),
                  ],
                ),

                const SizedBox(height: 50),
                // not a member register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Not a member?",
                      style: TextStyle(color: Colors.black),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Register Now",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
