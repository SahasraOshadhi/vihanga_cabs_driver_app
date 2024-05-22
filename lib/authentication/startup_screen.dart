import 'package:flutter/material.dart';
import 'package:vihanga_cabs_driver_app/authentication/Login/login_screen.dart';
import 'package:vihanga_cabs_driver_app/methods/common_methods.dart';

class StartUpScreen extends StatefulWidget {
  const StartUpScreen({super.key});

  @override
  State<StartUpScreen> createState() => _StartUpScreenState();
}

class _StartUpScreenState extends State<StartUpScreen> {

  CommonMethods commonMethods = CommonMethods();


  Future<bool> checkIfNetworkIsAvailable(BuildContext context) async {
    return await commonMethods.checkConnectivity(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [

                const SizedBox(height: 100,),

                Image.asset(
                  "assets/images/startup.jpg"
                ),

                const SizedBox(height: 30,),

                const Text(
                  "Welcome to Vihanga Cabs",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),

                ),

                const Padding(
                  padding: EdgeInsets.all(15),
                ),

                const Text(
              "We provide Hire services for the companies. This is not like Uber. Joining with Vihanga Cabs make you a part time worker ",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,

                  ),
               ),

                const SizedBox(height: 40,),

                ElevatedButton(
                  onPressed: () async {
                    bool isConnected = await checkIfNetworkIsAvailable(context);
                    if (isConnected) {
                      Navigator.push(context, MaterialPageRoute(builder: (c) => LogInScreen()));
                    }
                  },



                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                    ),
                    child: const Text(
                        "Join as a Driver",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize:20,
                      ),

                    )

                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
