import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rigel_fyp_project/services/auth.dart';
import 'package:rigel_fyp_project/services/firebase_services.dart';
import 'package:rigel_fyp_project/services/response.dart';
import 'package:rigel_fyp_project/services/validator.dart';
import 'constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:rigel_fyp_project/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rigel_fyp_project/screens/client/home.dart';
import 'package:wc_form_validators/wc_form_validators.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

class _SignUpState extends State<SignUp> {
  final _auth = FirebaseAuth.instance;
  FirebaseServices firebaseServices = FirebaseServices();
  Auth authenticate = new Auth();
  bool showSpinner = false;
  late String email;
  late String password;
  late String username;
  late String wallet_address;

  final usernameController = TextEditingController();
  final wallet_addressController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var userCollection = FirebaseFirestore.instance.collection('user_info');

  Validator validator = Validator();
  Response response = Response();

  validateAndSave() async {
    setState(() {
      showSpinner = true;
    });

    try {
      final newUser =
          await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // final newUser = authenticate.createUser(email, password);

      final User user = await _auth.currentUser!;
      user.updateDisplayName(usernameController.text);
      print(user.displayName);

      if (user!= null && !user.emailVerified) {
        await user.sendEmailVerification();
      }

      if (newUser != null) {
        firebaseServices.addUser(
            usernameController.text, emailController.text, wallet_addressController.text);
        firebaseServices.setUserInfoToSearchDatabase(
            usernameController.text, emailController.text, wallet_addressController.text);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      }

      setState(() {
        showSpinner = false;
      });
    }

    on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        response.failureAlertDialog(context, title: 'Weak Password', desc: 'Your password should be at least 8 characters.');
        setState(() {
          showSpinner = false;
        });
      }

      else if (e.code == 'email-already-in-use') {
        print('Account already exists for that email.');
        response.failureAlertDialog(context, title: 'Email already exists', desc: 'The account already exists for that email.');


        setState(() {
          showSpinner = false;
        });

      }

      else if (e.code == 'invalid-email') {
        print('Invalid email');
        response.failureAlertDialog(context, title: 'Error!',  desc: 'Email address is invalid.');


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

      else {
        response.failureAlertDialog(context, title: 'Error in signing in', desc: 'Please try again with correct credentials.');
        setState(() {
          showSpinner = false;

        });
      }
    }
    catch (e) {
      print(e);
    }
  }

  Future<bool> usernameCheck(String username) async {
    final result = await FirebaseFirestore.instance
        .collection('usernames')
        .where('username', isEqualTo: username)
        .get();
    return result.docs.isEmpty;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        progressIndicator: CircularProgressIndicator(
          color: color1,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  "Create Account,",
                  style: GoogleFonts.aBeeZee(
                      fontSize: 32.0,
                      color: color1,
                  ),
                ),
                kSizedBox(),
                Text(
                  "Sign up to get started!",
                  style: GoogleFonts.aBeeZee(fontSize: 18.0, color: Colors.grey),
                ),
                SizedBox(
                  height: 52.0,
                ),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: usernameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                      labelText: "Username",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0))),
                  onChanged: (value) {
                    username = value;
                  },
                  validator: Validators.compose([
                    Validators.required('Username is required'),
                    Validators.minLength(4, "Username should be minimum of 4 characters"),
                    Validators.maxLength(12, "Username should be maximum of 12 characters"),
                    Validators.patternString(r'^[a-zA-Z0-9]{4,12}$', 'Invalid username')
                  ]),
                ),

                SizedBox(
                  height: 22.0,
                ),
                TextFormField(
                  controller: emailController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: "Email Address",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0))),
                  onChanged: (value) {
                    email = value;
                  },
                  validator: (email) => email!.isValidEmail() ? null : "Please check your email",

                ),
                SizedBox(
                  height: 22.0,
                ),
                TextFormField(
                  controller: passwordController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0))),
                  onChanged: (value) {
                    password = value;
                  },
                  validator: Validators.compose([
                    Validators.required('Password is required'),
                    Validators.minLength(8, "Password should be minimum of 8 characters")
                  ]),
                ),
                SizedBox(
                  height: 32.0,
                ),
                TextFormField(
                  controller: wallet_addressController,
                  decoration: InputDecoration(
                      labelText: "Wallet Address",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0))),
                  onChanged: (value) {
                    wallet_address = value;
                  },
                  validator: Validators.compose([
                    Validators.required('Wallet Address is required'),
                  ]),
                ),
                SizedBox(
                  height: 32.0,
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
                      final valid = await usernameCheck(username);


                      if (usernameController.text.isNotEmpty || emailController.text.isNotEmpty ||
                          passwordController.text.isNotEmpty || wallet_addressController.text.isNotEmpty) {

                        if (!valid) {
                          setState(() {
                            showSpinner = false;
                          });
                          print('This username is already taken.');
                          response.failureAlertDialog(context,
                              title: 'Username exists!',
                              desc: 'This username is already taken.');
                        }

                        else {
                          setState(() {
                            showSpinner = false;
                          });
                          validateAndSave();
                        }

                      } else {
                        setState(() {
                          showSpinner = false;
                        });
                        print('Please enter the required fields');
                        response.failureAlertDialog(context,
                            title: 'Error Signing Up!',
                            desc: 'Please enter the required fields');
                      }
                         },
                    child: Text(
                      "Sign Up",
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
                SizedBox(
                  height: 52.0,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "I'm already a member, ",
                        style: GoogleFonts.aBeeZee(
                          fontSize: 16.0,
                          color: Colors.grey,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => SignIn()));
                        },
                        child: Text(
                          "Sign In",
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
      ),
    );
  }
}
