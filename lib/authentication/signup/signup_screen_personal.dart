import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vihanga_cabs_driver_app/authentication/Login/login_screen.dart';
import 'package:vihanga_cabs_driver_app/authentication/signup/signup_screen_vehicle.dart';
import 'package:vihanga_cabs_driver_app/methods/common_methods.dart';
import '../image_picker_page.dart';
import 'package:vihanga_cabs_driver_app/models/driver_data.dart';


class SignUpScreen extends StatefulWidget {
  final DriverData driverData;

  const SignUpScreen({super.key, required this.driverData});

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
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController dobTextEditingController = TextEditingController();
  TextEditingController nicTextEditingController = TextEditingController();
  TextEditingController nicPicFrontController = TextEditingController();
  TextEditingController nicPicBackController = TextEditingController();
  TextEditingController licenceNumTextEditingController = TextEditingController();
  TextEditingController licensePicFrontController = TextEditingController();
  TextEditingController licensePicBackController = TextEditingController();
  TextEditingController selfPicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with data from driverData if available
    firstNameTextEditingController.text = widget.driverData.firstName ?? '';
    lastNameTextEditingController.text = widget.driverData.lastName ?? '';
    houseNumAddressTextEditingController.text = widget.driverData.houseNumAddress ?? '';
    provinceAddressTextEditingController.text = widget.driverData.provinceAddress ?? '';
    cityAddressTextEditingController.text = widget.driverData.cityAddress ?? '';
    telNumTextEditingController.text = widget.driverData.telNum ?? '';
    emailTextEditingController.text = widget.driverData.email ?? '';
    dobTextEditingController.text = widget.driverData.dob ?? '';
    nicTextEditingController.text = widget.driverData.nic ?? '';
    nicPicFrontController.text = widget.driverData.nicPicFront ?? '';
    nicPicBackController.text = widget.driverData.nicPicBack ?? '';
    licenceNumTextEditingController.text = widget.driverData.licenceNum ?? '';
    licensePicFrontController.text = widget.driverData.licensePicFront ?? '';
    licensePicBackController.text = widget.driverData.licensePicBack ?? '';
    selfPicController.text = widget.driverData.selfPic ?? '';
  }


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

  bool isValidEmail(String email) {
    String emailPattern = r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9]+(?:\.[a-zA-Z0-9]+)*$';
    RegExp regex = RegExp(emailPattern);
    return regex.hasMatch(email);
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

  // Callback function to handle image upload
  void _onImageUploaded(String imageUrl, String fieldName) {
    setState(() {
      switch (fieldName) {
        case 'nicPicFront':
          widget.driverData.nicPicFront = imageUrl;
          break;
        case 'nicPicBack':
          widget.driverData.nicPicBack = imageUrl;
          break;
        case 'licensePicFront':
          widget.driverData.licensePicFront = imageUrl;
          break;
        case 'licensePicBack':
          widget.driverData.licensePicBack = imageUrl;
          break;
        case 'selfPic':
          widget.driverData.selfPic = imageUrl;
          break;
      }
    });
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
                      onImageUploaded: _onImageUploaded,
                      driverEmail: emailTextEditingController.text,
                      fieldName: 'nicPicFront',
                    ),

                    const SizedBox(height: 22,),

                    ImagePickerTextField(
                      controller: nicPicBackController,
                      labelText: 'Back Picture of NIC',
                      helperText: "Rename the picture as 'NIC_Back'",
                      onImageUploaded:  _onImageUploaded,
                      driverEmail: emailTextEditingController.text,
                      fieldName: 'nicPicBack',
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
                      onImageUploaded: _onImageUploaded,
                      driverEmail: emailTextEditingController.text,
                      fieldName: 'licensePicFront',
                    ),

                    const SizedBox(height: 22,),

                    ImagePickerTextField(
                      controller: licensePicBackController,
                      labelText: 'Back Picture of License',
                      helperText: "Rename the picture as 'License_Back'",
                      onImageUploaded: _onImageUploaded,
                      driverEmail: emailTextEditingController.text,
                      fieldName: 'licensePicBack',
                    ),

                    const SizedBox(height: 22,),


                    ImagePickerTextField(
                      controller: selfPicController,
                      labelText: 'Picture of Yourself',
                      helperText: "Rename the picture with your first name.",
                      onImageUploaded: _onImageUploaded,
                      driverEmail: emailTextEditingController.text,
                      fieldName: 'selfPic',
                    ),

                    const SizedBox(height: 22,),



                    const SizedBox(height: 32,),

                    ElevatedButton(
                        onPressed: () async {
                          // Validate email format
                          String email = emailTextEditingController.text;
                          if (!isValidEmail(email)) {
                            setState(() {
                              _errorText = "The email address is badly formatted.";
                            });
                            return;
                          }


                          bool isReadyToNavigate = await checkIfNetworkIsAvailable(context);

                          print(widget.driverData.nicPicFront);


                          if (isReadyToNavigate) {

                            widget.driverData.firstName = firstNameTextEditingController.text;
                            widget.driverData.lastName = lastNameTextEditingController.text;
                            widget.driverData.houseNumAddress = houseNumAddressTextEditingController.text;
                            widget.driverData.provinceAddress = provinceAddressTextEditingController.text;
                            widget.driverData.cityAddress = cityAddressTextEditingController.text;
                            widget.driverData.telNum = telNumTextEditingController.text;
                            widget.driverData.email = emailTextEditingController.text;
                            widget.driverData.dob = dobTextEditingController.text;
                            widget.driverData.nic = nicTextEditingController.text;
                            widget.driverData.licenceNum = licenceNumTextEditingController.text;




                            Navigator.push(context, MaterialPageRoute(builder: (context) => SignupVehicle(driverData: widget.driverData),),);

                          }
                        },



                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                        ),
                        child: const Text(
                            "Next",
                            style: TextStyle(
                              color: Colors.white,
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











