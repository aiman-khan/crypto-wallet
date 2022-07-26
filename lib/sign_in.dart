import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rigel_fyp_project/screens/admin/admin_home.dart';
import 'package:rigel_fyp_project/services/response.dart';
import 'constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rigel_fyp_project/sign_up.dart';
import 'package:rigel_fyp_project/screens/client/home.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignIn extends StatefulWidget {
  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _auth = FirebaseAuth.instance;
  Response response = Response();
  bool showSpinner = false;
  late String email;
  late String full_name;
  late String password;
  late String title;
  late String desc;

  @override
  Widget build(BuildContext context) {

    signInWithEmailAndPassword() async {
      try {
        final newUser = await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        if (newUser != null) {

          if (email == 'admin@gmail.com') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminHome()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          }


        }

        setState(() {
          showSpinner = false;
        });

      } on FirebaseAuthException catch (e) {

        if (e.code == 'user-not-found') {
          print('No user found for that email.');
          response.failureAlertDialog(context, title: 'User not found', desc: 'Please try to register first.');

          setState(() {
            showSpinner = false;
          });
        }

        else if (e.code == 'invalid-email') {
          print('Invalid email');
          response.failureAlertDialog(context, title: 'Error!', desc: 'Email address is invalid.');


          setState(() {
            showSpinner = false;
          });

        }

        else if (e.code == 'user-disabled') {
          print('User Disabled');
          response.failureAlertDialog(context, title: 'Error!', desc: 'Your account has been disabled.');


          setState(() {
            showSpinner = false;
          });

        }

        else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
          response.failureAlertDialog(context, title: 'Invalid Password', desc: "You've entered a wrong password.");

          setState(() {
            showSpinner = false;
          });

        }


      } catch (e) {
        print(e);
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        progressIndicator: CircularProgressIndicator(
          color: color1,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Container(
              //     child: Image.asset(
              //   'assets/images/logo.png',
              //   height: 100,
              // )),
              kSizedBox(),
              Text(
                "Welcome,",
                style:
                    GoogleFonts.aBeeZee(fontSize: 32.0, color: color1),
              ),
              kSizedBox(),
              Text(
                "Sign in to Continue!",
                style: GoogleFonts.aBeeZee(fontSize: 18.0, color: Colors.grey),
              ),
              SizedBox(
                height: 52.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    labelText: "Email Address",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0))),
                onChanged: (value) {
                  email = value;
                },
              ),
              SizedBox(
                height: 22.0,
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0))),
                onChanged: (value) {
                  password = value;
                },
              ),
              SizedBox(height: 8.0),
              Container(
                alignment: Alignment.centerRight,
                width: MediaQuery.of(context).size.width,
                child: InkWell(
                  onTap: (){
                      _auth.sendPasswordResetEmail(email: email);
                   },
                  child: Text(
                    "Forget Password?",
                    style: GoogleFonts.aBeeZee(color: Colors.black, fontSize: 14.0),
                  ),
                ),
              ),
              SizedBox(
                height: 22.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  gradient: LinearGradient(
                    colors: [color1, color2],
                  ),
                ),
                child: MaterialButton(
                  onPressed: () async {
                    setState(() {
                      showSpinner = true;
                    });

                    signInWithEmailAndPassword();

                  },
                  child: Text(
                    "Sign In",
                    style: GoogleFonts.aBeeZee(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 22.0,
              ),
              // Container(
              //   width: MediaQuery.of(context).size.width,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(8.0),
              //     gradient: LinearGradient(
              //       colors: [Color(0xffECEFF4), Color(0xffECEFF4)],
              //     ),
              //   ),
              // ),
              SizedBox(
                height: 52.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "I'm new user, ",
                      style: GoogleFonts.aBeeZee(
                        fontSize: 16.0,
                        color: Colors.grey,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => SignUp()));
                      },
                      child: Text(
                        "Sign Up",
                        style: GoogleFonts.aBeeZee(
                          fontSize: 18.0,
                          color: color2,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

