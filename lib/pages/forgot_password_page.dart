import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:organizer/components/my_button.dart';
import 'package:organizer/components/my_textfield.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async{
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(
        context: context, 
        builder: (context){
          return const AlertDialog(
            content: Text("Password reset link sent! Check your email"),
        );
      });
    } on FirebaseAuthException catch(e){
      print(e);
      showDialog(
        context: context, 
        builder: (context){
          return AlertDialog(
            content: Text(e.message.toString()),
        );
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0,vertical: 10),
            child: Text("Enter your email and we will send you a link to reset your password",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20,color: Colors.black),
              ),
            ),
        

          const SizedBox(height:20),

          MyTextField(
                  controller: _emailController,
                  hintText: "Email",
                  obscureText: false,
                ),

          const SizedBox(height:20,),

          MyButton(
                  onTap: passwordReset,
                  text: "Reset Password",
                ),
        ],
      ),
    );
  }
  
} 