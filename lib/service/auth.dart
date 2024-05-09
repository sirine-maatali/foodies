import 'package:demoproject/service/database.dart';
import 'package:demoproject/service/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final BuildContext context;

  AuthMethods(this.context);
  getCurrentUser() async {
    return await auth.currentUser;
  }

  Future SignOut() async {
    try {
      await auth.signOut();
      await SharedPreferenceHelper().saveUserName("");
      await SharedPreferenceHelper().saveUserEmail("");
      await SharedPreferenceHelper().saveUserWallet('0');
      await SharedPreferenceHelper().saveUserId("");
      await SharedPreferenceHelper().saveUserPassword("");

      Navigator.pushReplacementNamed(context, '/signup');
    } catch (e) {
      print("Error during sign out: $e");
    }
  }

  Future deleteuser() async {
    User? user = await FirebaseAuth.instance.currentUser;
    user?.delete();
  }
}
