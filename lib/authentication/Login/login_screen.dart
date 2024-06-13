import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:vihanga_cabs_driver_app/authentication/signup/signup_screen_personal.dart';

import 'package:vihanga_cabs_driver_app/global/global_var.dart';
import 'package:vihanga_cabs_driver_app/methods/common_methods.dart';
import 'package:vihanga_cabs_driver_app/models/driver_data.dart';
import 'package:vihanga_cabs_driver_app/pages/home_page.dart';
import 'package:vihanga_cabs_driver_app/widgets/loading_dialog.dart';


class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {

  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();

  bool _passwordVisible = false;

  CommonMethods commonMethods = CommonMethods();

  checkIfNetworkIsAvailable(){
    commonMethods.checkConnectivity(context);

    signInFormValidation();
  }



  signInFormValidation(){
    // Perform form validation

    if (userNameTextEditingController.text.isEmpty ||
        passwordTextEditingController.text.isEmpty  ) {
      commonMethods.displaySnackBar("Fill all fields", context);
    } else {
      signInUser();
    }

  }

  signInUser() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext) => LoadingDialog(messageText: "Please wait..." )
    );

      final User? driverFirebase = (
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailTextEditingController.text.trim(),
            password: passwordTextEditingController.text.trim(),
          ).catchError((errorMsg) {
            Navigator.pop(context); // Dismiss the loading dialog
            commonMethods.displaySnackBar(errorMsg.toString(), context);
            return null; // Return null to handle the error properly
          })
      ).user;

      if(!context.mounted) return;
    Navigator.pop(context);

    if (driverFirebase != null) {
      DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("drivers").child(driverFirebase.uid);
      driversRef.once().then((snap) {
        if (snap.snapshot.value != null) {
          if ((snap.snapshot.value as Map)["blockStatus"] == "no") {
            userName = (snap.snapshot.value as Map)["userName"];
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (c) => HomePage(driverId: driverFirebase.uid),
              ),
            );
          } else {
            FirebaseAuth.instance.signOut();
            commonMethods.displaySnackBar("Your account is not approved or blocked. Contact Vihanga Cabs", context);
          }
        } else {
          FirebaseAuth.instance.signOut();
          commonMethods.displaySnackBar("Sign Up as a driver", context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [

              const SizedBox(height: 70,),

              Image.asset(
                  "assets/images/startup.jpg"
              ),

              const Text(
                "Login as a Driver",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              //Input text fields + button
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [

                    //email input
                    TextField(
                      controller: userNameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "User Name",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 22,),

                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "E-mail",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 22,),

                    //password input
                    TextField(
                      controller: passwordTextEditingController,
                      keyboardType: TextInputType.text,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          icon: Icon(
                            _passwordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 32,),

                    ElevatedButton(
                        onPressed: ()  {
                          checkIfNetworkIsAvailable();

                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                        ),
                        child: const Text(
                            "LogIn",
                          style: TextStyle(
                          color: Colors.white,
                          fontSize:15,
                        )
                    ),
                    ),

                  ],
                ),
              ),

              TextButton(
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen(driverData: DriverData(),),),);
                },
                child: const Text(
                  "Don\'t have an Account? Sign Up Here",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}