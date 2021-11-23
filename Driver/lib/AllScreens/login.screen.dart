import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_driver/AllScreens/mainscreen.dart';
import 'package:uber_driver/AllScreens/registation.screen.dart';
import 'package:uber_driver/CustomWidgets/progressDialog.dart';

import 'package:uber_driver/main.dart';

class LoginScreen extends StatelessWidget {
  static const String idScreen = "loginScreen";
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Image(
              image: AssetImage("assets/images/Uber_logo.png"),
              width: 200,
              height: 200,
              alignment: Alignment.center,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(height: 1),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: "Adresse email",
                      labelStyle: TextStyle(
                        fontSize: 14,
                      ),
                      hintStyle: TextStyle(color: Colors.black, fontSize: 10),
                    ),
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 1),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: "Mot de passe",
                      labelStyle: TextStyle(
                        fontSize: 14,
                      ),
                      hintStyle: TextStyle(color: Colors.black, fontSize: 10),
                    ),
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 50),
                  Container(
                    height: 50,
                    width: 350,
                    child: TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(15)))),
                      onPressed: () {
                        if (passwordController.text.isEmpty) {
                          displayToastMessage("Le mot de passe est obligatoire pour se connecter", context);
                        }
                        else if (!emailController.text.contains("@")) {
                          displayToastMessage("Renseignez une adresse mail valide", context);
                        }
                        else {
                          login(context);
                        }
                      },
                      child: Text(
                        "Connexion",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: "Brand Bold",
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    height: 50,
                    width: 350,
                    child: TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(15)))),
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context,
                            RegistrationScreen.idScreen, (route) => false);
                      },
                      child: Text(
                        "Inscription",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: "Brand Bold",
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  login(BuildContext context) async {
    showDialog(context: context, barrierDismissible: false, builder: (BuildContext context) {
      return ProgressDialog(message: "Patientez s'il vous plaît",);
    }
    );

    final User firebaseUser = (await _firebaseAuth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text
    ).catchError((errMsg) {
      Navigator.pop(context);
      displayToastMessage("Error: " + errMsg.toString(), context);
    })).user;

    if (firebaseUser != null) {

      userRef.child(firebaseUser.uid).once().then((DataSnapshot snap) {
        if (snap.value != null) {
          Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
          displayToastMessage("Connexion réussie", context);
        }
        else {
          _firebaseAuth.signOut();
          displayToastMessage("Adresse mail ou mot de passe incorrect", context);
        }
      });
    }
    else {
      Navigator.pop(context);
      displayToastMessage("Error", context);
    }
  }
  displayToastMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }
}
