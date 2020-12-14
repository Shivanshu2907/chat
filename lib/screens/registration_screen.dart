import 'package:flash_chat/constants.dart';
import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flash_chat/AuthenticationProvider.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  String email;
  String password;
  bool showPassword = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: Provider.of<AuthenticationProvider>(context).showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    //Do something with the user input.
                    email = value;
                  },
                  decoration:
                      KinputField.copyWith(hintText: 'Enter your email')),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.emailAddress,
                  obscureText: !showPassword,
                  onChanged: (value) {
                    password = value;
                    //Do something with the user input.
                  },
                  decoration:
                      KinputField.copyWith(hintText: 'Enter your password')),
              SizedBox(
                height: 5.0,
              ),
              CheckboxListTile(
                title: Text('Show Password'),
                value: showPassword,
                onChanged: (bool newvalue) {
                  setState(() {
                    showPassword = newvalue;
                  });
                  print(showPassword);
                },
              ),
              SizedBox(
                height: 24.0,
              ),
              MatButton(
                color: Colors.blueAccent,
                name: 'Register',
                onpress: () async {
                  //Go to login screen.
                  // setState(() {
                  //   showSpinner = true;
                  // });
                  // try {
                  //   final newuser = await _auth.createUserWithEmailAndPassword(
                  //       email: email, password: password);
                  //   if (newuser != null) {
                  //     setState(() {
                  //       showSpinner = false;
                  // });
                  String mess = await Provider.of<AuthenticationProvider>(
                          context,
                          listen: false)
                      .signUp(
                    email: email,
                    password: password,
                  );
                  if (mess == "Signed up!") {
                    Navigator.pushNamed(context, '/chat');
                  }
                  //   }
                  // } catch (e) {
                  //   print(e);
                  // }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
