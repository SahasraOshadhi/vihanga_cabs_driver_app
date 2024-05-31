import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:vihanga_cabs_driver_app/methods/common_methods.dart';
import 'package:vihanga_cabs_driver_app/models/driver_data.dart';
import 'package:vihanga_cabs_driver_app/pages/home_page.dart';
import 'package:vihanga_cabs_driver_app/widgets/loading_dialog.dart';

class SignupFinal extends StatefulWidget {
  final DriverData driverData;

  const SignupFinal({super.key, required this.driverData});

  @override
  State<SignupFinal> createState() => _SignupFinalState();
}

class _SignupFinalState extends State<SignupFinal> {

  bool _isLoading = false;

  String? _errorTextUsername;
  String? _errorTextPassword;
  String? _errorTextConfirmPassword;

  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController confirmPasswordTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userNameTextEditingController.text = widget.driverData.userName ?? '';
    confirmPasswordTextEditingController.text = widget.driverData.password ?? '';
  }

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  CommonMethods commonMethods = CommonMethods();

  Future<bool> checkConnectivity(BuildContext context) async {
    bool isConnected = await commonMethods.checkConnectivity(context);
    return isConnected ?? false; // Handle the case if isConnected is null
  }


  bool checkFormValidation(BuildContext context){
    // Perform form validation

    if (userNameTextEditingController.text.isEmpty ||
        passwordTextEditingController.text.isEmpty ||
        confirmPasswordTextEditingController.text.isEmpty  ) {
      commonMethods.displaySnackBar("Fill all the fields before going to the next page", context);
      return false;
    }

    if (!_isValidUsername(userNameTextEditingController.text)) {
      commonMethods.displaySnackBar("Username must be at least 6 characters long.", context);
      return false;
    }

    if (!_isValidPassword(passwordTextEditingController.text)) {
      commonMethods.displaySnackBar("Password must be at least 8 characters long and contain at least one lowercase letter, one uppercase letter, one digit, and one special character.", context);
      return false;
    }

    if (!_isPasswordMatching(passwordTextEditingController.text, confirmPasswordTextEditingController.text)) {
      commonMethods.displaySnackBar("Passwords do not match.", context);
      return false;
    }

    return true;
  }


  bool _isValidUsername(String value) {
    return value.length >= 6;
  }

  bool _isValidPassword(String value) {
    // Password must contain at least one lowercase letter,
    // one uppercase letter, one digit, and one special character
    String pattern = r'^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#$%^&*()-_=+{}|;:,<.>]).{8,}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(value);
  }

  bool _isPasswordMatching(String password, String confirmPassword) {
    return password == confirmPassword;
  }

  Future<void> registerNewDriver() async
  {
    widget.driverData.userName = userNameTextEditingController.text;
    widget.driverData.password = confirmPasswordTextEditingController.text;

    if (widget.driverData.email == null || widget.driverData.password == null) {
      Navigator.pop(context);
      commonMethods.displaySnackBar("Email or Password is missing", context);
      return;
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext) => LoadingDialog(messageText: "Registering your account. This might take some time...." )
    );


    try {
      final User? driverFirebase = (
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: widget.driverData.email.toString(),
            password: widget.driverData.password.toString(),
          ).catchError((errorMsg) {
            Navigator.pop(context); // Dismiss the loading dialog
            commonMethods.displaySnackBar(errorMsg.toString(), context);
            return null; // Return null to handle the error properly
          })
      ).user;

      if (driverFirebase != null) {
        DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("drivers").child(driverFirebase.uid);

        Map<String, String> driverDataMap = {
          "firstName": widget.driverData.firstName!,
          "lastName": widget.driverData.lastName!,
          "houseNumAddress": widget.driverData.houseNumAddress!,
          "provinceAddress": widget.driverData.provinceAddress!,
          "cityAddress": widget.driverData.cityAddress!,
          "telNum": widget.driverData.telNum!,
          "email": widget.driverData.email!,
          "dob": widget.driverData.dob!,
          "nic": widget.driverData.nic!,
          "nicPicFront": widget.driverData.nicPicFront!,
          "nicPicBack": widget.driverData.nicPicBack!,
          "licenceNum": widget.driverData.licenceNum!,
          "licensePicFront": widget.driverData.licensePicFront!,
          "licensePicBack": widget.driverData.licensePicBack!,
          "selfPic": widget.driverData.selfPic!,
          "vehicleModel": widget.driverData.vehicleModel!,
          "vehicleInsidePic": widget.driverData.vehicleInsidePic!,
          "vehicleOutsidePic": widget.driverData.vehicleOutsidePic!,
          "vehicleRegNum": widget.driverData.vehicleRegNum!,
          "manufacturedYear": widget.driverData.manufacturedYear!,
          "lastServiceDate": widget.driverData.lastServiceDate!,
          "mileage": widget.driverData.mileage!,
          "emissionTest": widget.driverData.emissionTest!,
          "userName": widget.driverData.userName!,
          "password": widget.driverData.password!,
          "id": driverFirebase.uid,
          "blockStatus": "no"
        };

        await driversRef.set(driverDataMap);

        // Save the username and email in the usernames node
        DatabaseReference usernamesRef = FirebaseDatabase.instance.ref().child("usernames").child(widget.driverData.userName!);
        await usernamesRef.set(widget.driverData.email);

        Navigator.pop(context); // Dismiss the loading dialog
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => HomePage()));
      } else {
        Navigator.pop(context); // Dismiss the loading dialog if registration fails
        commonMethods.displaySnackBar("Registration failed. Please try again.", context);
      }
    } catch (e) {
      Navigator.pop(context); // Dismiss the loading dialog
      commonMethods.displaySnackBar(e.toString(), context);
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
              Image.asset(
                  "assets/images/startup.jpg"
              ),

              const Text(
                "Create Driver\'s Account",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(22),
                child: Column(
                  children: [

                    TextField(
                      controller: userNameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration:  InputDecoration(
                       labelText: "User Name",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        errorText: _errorTextUsername,

                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _errorTextUsername = !_isValidUsername(value) ? "Username must be at least 6 characters long." : null;
                        });
                      },
                    ),

                    const SizedBox(height: 22,),


                    TextField(
                      controller: passwordTextEditingController,
                      keyboardType: TextInputType.text,
                      obscureText: !_passwordVisible,
                      decoration:  InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                          errorText: _errorTextPassword
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _errorTextPassword = !_isValidPassword(value) ? "Password must be at least 8 characters long and contain at least one lowercase letter, one uppercase letter, one digit, and one special character." : null;
                        });
                      },
                    ),

                    const SizedBox(height: 22,),

                    TextField(
                      controller: confirmPasswordTextEditingController,
                      keyboardType: TextInputType.text,
                      obscureText: !_confirmPasswordVisible,
                      decoration:  InputDecoration(
                        labelText: "Confirm Password",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        errorText: !_isPasswordMatching(passwordTextEditingController.text, confirmPasswordTextEditingController.text) ? "Passwords do not match." : null,
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _errorTextConfirmPassword = !_isPasswordMatching(passwordTextEditingController.text, value) ? "Passwords do not match." : null;
                        });
                      },
                    ),

                    const SizedBox(height: 22,),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            bool isConnected = await checkConnectivity(context);

                            if (isConnected) {
                              Navigator.pop(context);  // Example of back navigation
                            } else {
                              commonMethods.displaySnackBar("Network is not available. Please check your connection.", context);
                            }
                          },


                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
                            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                          ),
                          child: const Text(
                            "Back",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize:15,
                            ),
                          ),
                        ),


                        ElevatedButton(
                          onPressed: () async {
                            bool isConnected = await checkConnectivity(context);
                            bool formIsValid = checkFormValidation(context);

                            if (isConnected && formIsValid) {
                              registerNewDriver();
                            }
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
                            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize:15,
                            ),
                          ),
                        ),
                      ],
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
