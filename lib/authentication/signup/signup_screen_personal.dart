import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vihanga_cabs_driver_app/authentication/Login/login_screen.dart';
import 'package:vihanga_cabs_driver_app/authentication/signup/signup_screen_vehicle.dart';
import 'package:vihanga_cabs_driver_app/methods/common_methods.dart';
import '../image_picker_page.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {


  TextEditingController firstNameTextEditingController = TextEditingController();
  TextEditingController lastNameTextEditingController = TextEditingController();
  TextEditingController houseNumAddressTextEditingController = TextEditingController();
  TextEditingController provinceAddressTextEditingController = TextEditingController();
  TextEditingController cityAddressTextEditingController = TextEditingController();
  TextEditingController telNumTextEditingController = TextEditingController();
  TextEditingController dobTextEditingController = TextEditingController();
  TextEditingController nicTextEditingController = TextEditingController();
  TextEditingController nicPicFrontController = TextEditingController();
  TextEditingController nicPicBackController = TextEditingController();
  TextEditingController licenceNumTextEditingController = TextEditingController();
  TextEditingController licensePicFrontController = TextEditingController();
  TextEditingController licensePicBackController = TextEditingController();
  TextEditingController selfPicController = TextEditingController();


  String? _errorText = '' ;
  String? _errorTextLicense = '';
  CommonMethods commonMethods = CommonMethods();



  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null ) {
      setState(() {
        dobTextEditingController.text = picked.toString().split(" ")[0];
      });
    }
  }

  Future<bool> checkIfNetworkIsAvailable(BuildContext context) async {
    bool isConnected = await commonMethods.checkConnectivity(context);
    bool isFormValid = signUpFormValidation();

    // Handle null case
    if (isConnected == null || isFormValid == null) {
      return false;
    }

    return isConnected && isFormValid;
  }


  bool signUpFormValidation() {
    // Perform form validation

    if (firstNameTextEditingController.text.isEmpty ||
        lastNameTextEditingController.text.isEmpty ||
        houseNumAddressTextEditingController.text.isEmpty ||
        provinceAddressTextEditingController.text.isEmpty ||
        cityAddressTextEditingController.text.isEmpty ||
        telNumTextEditingController.text.isEmpty ||
        dobTextEditingController.text.isEmpty ||
        nicTextEditingController.text.isEmpty ||
        nicPicFrontController.text.isEmpty ||
        nicPicBackController.text.isEmpty ||
        licenceNumTextEditingController.text.isEmpty ||
        licensePicFrontController.text.isEmpty ||
        licensePicBackController.text.isEmpty ||
        selfPicController.text.isEmpty) {
      commonMethods.displaySnackBar("Fill all the fields before going to the next page", context);
      return false;
    }

    return true;
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

              //Input text fields + button
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [

                    TextField(
                      controller: firstNameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "First Name",
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
                      controller: lastNameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Last Name",
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


                    const SizedBox(height: 22,),

                    TextField(
                      controller: houseNumAddressTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration:  InputDecoration(
                        labelText: "Address",
                        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        helperText: "Street, house/apartment/unit", // Additional text
                        helperStyle: TextStyle(color: Colors.grey.withOpacity(0.7)), // Style for helper text floatingLabelBehavior: FloatingLabelBehavior.always, // Show label text always
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 10,),

                    TextField(
                      controller: cityAddressTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        helperText: "City", // Additional text
                        helperStyle: TextStyle(color: Colors.grey.withOpacity(0.5)), // Style for helper text floatingLabelBehavior: FloatingLabelBehavior.always, // Show label text always
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 10,),


                    TextField(
                      controller: provinceAddressTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        helperText: "State/province", // Additional text
                        helperStyle: TextStyle(color: Colors.grey.withOpacity(0.5)), // Style for helper text floatingLabelBehavior: FloatingLabelBehavior.always, // Show label text always
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 22,),

                    TextField(
                      controller: telNumTextEditingController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Mobile Number",
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
                          controller: dobTextEditingController,
                          decoration: InputDecoration(
                            labelText: "Date of Birth",
                            labelStyle: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                      readOnly: true,
                      onTap: (){
                            _selectDate();
                      },
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        ),
                    ),


                    const SizedBox(height: 22,),


                    TextField(
                      controller: nicTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration:  InputDecoration(
                        errorText: _errorText?.isNotEmpty ?? false ? _errorText : null,
                        labelText: "NIC",
                        labelStyle: TextStyle (
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                      maxLength: 12, // Enforce maximum length
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      onChanged: (value) {
                        setState(() {
                          _errorText = _validateNIC(value);
                        });
                      },
                    ),

                    const SizedBox(height: 22,),

                    ImagePickerTextField(
                      controller: nicPicFrontController,
                      labelText: 'Front Picture of NIC',
                      helperText: "Rename the picture as 'NIC_Front'",
                    ),

                    const SizedBox(height: 22,),

                    ImagePickerTextField(
                      controller: nicPicBackController,
                      labelText: 'Back Picture of NIC',
                      helperText: "Rename the picture as 'NIC_Back'",
                    ),

                    const SizedBox(height: 22,),


                    TextField(
                      controller: licenceNumTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "License Number",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        errorText: _errorTextLicense?.isNotEmpty ?? false ? _errorTextLicense : null,
                      ),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                      maxLength: 8, // Enforce maximum length
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      onChanged: (value) {
                        setState(() {
                          _errorTextLicense = _validateLicenseNum(value);
                        });
                      },
                    ),

                    const SizedBox(height: 22,),

                    ImagePickerTextField(
                      controller: licensePicFrontController,
                      labelText: 'Front Picture of License',
                      helperText: "Rename the picture as 'License_Front'",
                    ),

                    const SizedBox(height: 22,),

                    ImagePickerTextField(
                      controller: licensePicBackController,
                      labelText: 'Back Picture of License',
                      helperText: "Rename the picture as 'License_Back'",
                    ),

                    const SizedBox(height: 22,),


                    ImagePickerTextField(
                      controller: selfPicController,
                      labelText: 'Picture of Yourself',
                      helperText: "Rename the picture with your first name.",
                    ),

                    const SizedBox(height: 22,),



                    const SizedBox(height: 32,),

                    ElevatedButton(
                        onPressed: () async {
                          print("Button pressed");

                          bool isReadyToNavigate = await checkIfNetworkIsAvailable(context);
                          print("Network and form validation result: $isReadyToNavigate");

                          if (isReadyToNavigate) {
                            print("Navigating to SignUpVehicle");
                            Navigator.push(context, MaterialPageRoute(builder: (c) => SignupVehicle()));
                          }
                        },



                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                        ),
                        child: const Text(
                            "Next",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize:15,
                            ),
                        )
                    ),

                  ],
                ),
              ),

              //text button
              TextButton(
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> LogInScreen()));
                },
                child: const Text(
                  "Already have an account? Login Here",
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


//NIC validation
String? _validateNIC(String value) {
  if (value.isEmpty) {
    return 'NIC number cannot be empty';
  }

  if (value.length < 10) {
    return 'NIC number should be at least 10 characters long';
  }

  if (value.length > 12) {
    return 'NIC number cannot be more than 12 characters';
  }

  if (value.length == 12) {
    if (_containsNonNumeric(value)) {
      return 'NIC number should contain only numbers';
    }
  }

  if (value.contains('V')) {
    if (value.length != 10) {
      return 'If "V" is present, NIC number should be 10 characters long';
    }
  }

  return null; // Input is valid
}


bool _containsNonNumeric(String value) {
  return value.split('').any((char) => !RegExp(r'[0-9]').hasMatch(char));
}


//license number validation
String? _validateLicenseNum(String value) {
  if (value.isEmpty) {
    return 'License number cannot be empty';
  }

  if (value.length != 8) {
    return 'License number should be exactly 8 characters long';
  }

  if (!RegExp(r'^[A-Za-z]').hasMatch(value)) {
    return 'First character of the license number must be a letter';
  }

  return null; // Input is valid
}











