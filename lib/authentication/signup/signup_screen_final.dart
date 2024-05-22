import 'package:flutter/material.dart';
import 'package:vihanga_cabs_driver_app/methods/common_methods.dart';

class SignupFinal extends StatefulWidget {
  const SignupFinal({super.key});

  @override
  State<SignupFinal> createState() => _SignupFinalState();
}

class _SignupFinalState extends State<SignupFinal> {

  String? _errorTextUsername;
  String? _errorTextPassword;
  String? _errorTextConfirmPassword;

  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController confirmPasswordTextEditingController = TextEditingController();

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
                              //update here
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
