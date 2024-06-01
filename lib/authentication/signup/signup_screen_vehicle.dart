import 'package:flutter/material.dart';
import 'package:vihanga_cabs_driver_app/authentication/image_picker_page.dart';
import 'package:vihanga_cabs_driver_app/authentication/signup/signup_screen_final.dart';
import 'package:vihanga_cabs_driver_app/authentication/signup/signup_screen_personal.dart';
import 'package:vihanga_cabs_driver_app/authentication/year_picker_page.dart';
import 'package:vihanga_cabs_driver_app/methods/common_methods.dart';
import 'package:vihanga_cabs_driver_app/models/driver_data.dart';

class SignupVehicle extends StatefulWidget {
  final DriverData driverData;

  const SignupVehicle({super.key, required this.driverData});

  @override
  State<SignupVehicle> createState() => _SignupVehicleState();
}

class _SignupVehicleState extends State<SignupVehicle> {

  TextEditingController vehicleModelTextEditingController = TextEditingController();
  TextEditingController vehicleInsidePicController = TextEditingController();
  TextEditingController vehicleOutsidePicController = TextEditingController();
  TextEditingController vehicleRegNumTextEditingController = TextEditingController();
  TextEditingController manufacturedYearTextEditingController = TextEditingController();
  TextEditingController lastServiceDateTextEditingController = TextEditingController();
  TextEditingController mileageTextEditingController = TextEditingController();
  TextEditingController emissionTestTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with data from driverData if available
    vehicleModelTextEditingController.text = widget.driverData.vehicleModel ?? '';
    vehicleInsidePicController.text = widget.driverData.vehicleInsidePic ?? '';
    vehicleOutsidePicController.text = widget.driverData.vehicleOutsidePic ?? '';
    vehicleRegNumTextEditingController.text = widget.driverData.vehicleRegNum ?? '';
    manufacturedYearTextEditingController.text = widget.driverData.manufacturedYear ?? '';
    lastServiceDateTextEditingController.text = widget.driverData.lastServiceDate ?? '';
    mileageTextEditingController.text = widget.driverData.mileage ?? '';
    emissionTestTextEditingController.text = widget.driverData.emissionTest ?? '';
  }

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
        lastServiceDateTextEditingController.text = picked.toString().split(" ")[0];
      });
    }
  }

  Future<bool> checkConnectivity(BuildContext context) async {
    bool isConnected = await commonMethods.checkConnectivity(context);
    return isConnected ?? false; // Handle the case if isConnected is null
  }



  bool checkFormValidation(BuildContext context){
    // Perform form validation

    if (vehicleModelTextEditingController.text.isEmpty ||
        vehicleInsidePicController.text.isEmpty ||
        vehicleOutsidePicController.text.isEmpty ||
        vehicleRegNumTextEditingController.text.isEmpty ||
        manufacturedYearTextEditingController.text.isEmpty ||
        lastServiceDateTextEditingController.text.isEmpty ||
        mileageTextEditingController.text.isEmpty ||
        emissionTestTextEditingController.text.isEmpty ) {
      commonMethods.displaySnackBar("Fill all the fields before going to the next page", context);
      return false;
    }

    return true;
  }

  void _onImageUploaded(String imageUrl, String fieldName) {
    setState(() {
      switch (fieldName) {
        case 'vehicleInsidePic':
          widget.driverData.vehicleInsidePic = imageUrl;
          break;
        case 'vehicleOutsidePic':
          widget.driverData.vehicleOutsidePic = imageUrl;
          break;
        case 'emissionTest':
          widget.driverData.emissionTest = imageUrl;
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
              Padding(
                  padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    TextField(
                      controller: vehicleModelTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Vehicle Model",
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

                    ImagePickerTextField(
                      controller: vehicleOutsidePicController,
                      labelText: 'Outside Picture of the vehicle',
                      helperText: "",
                      onImageUploaded: (imageUrl) => _onImageUploaded(imageUrl, 'vehicleOutsidePic'),
                      driverEmail: widget.driverData.email!,
                    ),

                    const SizedBox(height: 22,),

                    ImagePickerTextField(
                      controller: vehicleInsidePicController,
                      labelText: 'Inside Picture of the vehicle',
                      helperText: "",
                      onImageUploaded: (imageUrl) => _onImageUploaded(imageUrl, 'vehicleInsidePic'),
                      driverEmail: widget.driverData.email!,
                    ),

                    const SizedBox(height: 22,),

                    TextField(
                      controller: vehicleRegNumTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Vehicle Registration Number",
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

                    YearPickerTextField(
                      controller: manufacturedYearTextEditingController,
                      labelText: 'Vehicle Manufactured Year',
                    ),

                    const SizedBox(height: 22,),

                    TextField(
                      controller: lastServiceDateTextEditingController,
                      decoration: InputDecoration(
                        labelText: "Last Service Date",
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
                      controller: mileageTextEditingController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Mileage",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        suffixText: 'km', // Add 'km' as suffix text
                        suffixStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.black, // Adjust the color of the suffix text if needed
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 22,),

                    ImagePickerTextField(
                      controller: emissionTestTextEditingController,
                      labelText: 'Picture of Emission Test Report',
                      helperText: "Rename the picture as 'Emission_Test'",
                      onImageUploaded: (imageUrl) => _onImageUploaded(imageUrl, 'emissionTest'),
                      driverEmail: widget.driverData.email!,
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
                            backgroundColor: Colors.deepPurpleAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                          ),
                          child: const Text(
                            "Back",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:15,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            bool isConnected = await checkConnectivity(context);
                            bool formIsValid = checkFormValidation(context);

                            if (isConnected && formIsValid) {

                              widget.driverData.vehicleModel = vehicleModelTextEditingController.text;
                              widget.driverData.vehicleInsidePic = vehicleInsidePicController.text;
                              widget.driverData.vehicleOutsidePic = vehicleOutsidePicController.text;
                              widget.driverData.vehicleRegNum = vehicleRegNumTextEditingController.text;
                              widget.driverData.manufacturedYear = manufacturedYearTextEditingController.text;
                              widget.driverData.lastServiceDate = lastServiceDateTextEditingController.text;
                              widget.driverData.mileage = mileageTextEditingController.text;
                              widget.driverData.emissionTest = emissionTestTextEditingController.text;

                              Navigator.push(context, MaterialPageRoute(builder: (context) => SignupFinal(driverData: widget.driverData),),);
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
                          ),
                        ),
                      ],
                    ),


                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
