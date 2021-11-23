import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_driver/AllScreens/mainscreen.dart';
import 'package:uber_driver/main.dart';
import 'package:uber_driver/CustomWidgets/progressDialog.dart';

class RegistrationScreen extends StatelessWidget {
  static const String idScreen = "register";
  TextEditingController nameController = TextEditingController();
  TextEditingController fornameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
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
            Text(
              "Créer un compte en tant que client",
              style: TextStyle(
                fontSize: 20,
                fontFamily: "Brand Bold",
                color: Colors.black,
              ),

            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(height: 1),
                  TextFormField(
                    controller: nameController,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: "Nom",
                      labelStyle: TextStyle(
                        fontSize: 14,
                      ),
                      hintStyle: TextStyle(color: Colors.black, fontSize: 10),
                    ),
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 1),
                  TextFormField(
                    controller: fornameController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: "Prénom",
                      labelStyle: TextStyle(
                        fontSize: 14,
                      ),
                      hintStyle: TextStyle(color: Colors.black, fontSize: 10),
                    ),
                    style: TextStyle(fontSize: 14),
                  ),

                  SizedBox(height: 1),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(
                        fontSize: 14,
                      ),
                      hintStyle: TextStyle(color: Colors.black, fontSize: 10),
                    ),
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 1),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: "Téléphone",
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
                      labelText: "Password",
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
                        if (nameController.text.length < 1) {
                          displayToastMessage("Il faut mettre au moins une lettre", context);
                        }
                        else if (!emailController.text.contains("@")) {
                          displayToastMessage("L'adresse mail n'est pas valide", context);
                        }
                        else if (passwordController.text.isEmpty) {
                          displayToastMessage("Le mot de passe est obligatoire", context);
                        }
                        else if (passwordController.text.length < 7) {
                          displayToastMessage("Le mot de passe n'est pas assez long (Au moins 7 caractères)", context);
                        }
                        else {
                          registerUser(context);
                        }
                      },
                      child: Text(
                        "Valider l'inscription",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: "Brand Bold",
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  registerUser(BuildContext context) async {
    showDialog(context: context, barrierDismissible: false, builder: (BuildContext context) {
      return ProgressDialog(message: "Patientez s'il vous plaît");
    });
    final User firebaseUser = (await _firebaseAuth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text
    ).catchError((errMsg) {
      displayToastMessage("Error: " + errMsg.toString(), context);
    })).user;

    if (firebaseUser != null) {
      Map userDataMap = {
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
      };
      userRef.child(firebaseUser.uid).set(userDataMap);
      displayToastMessage("L'inscription a été validé avec succès", context);
      Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
    }
    else {
      displayToastMessage("Error", context);
    }
  }

  displayToastMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }
}
