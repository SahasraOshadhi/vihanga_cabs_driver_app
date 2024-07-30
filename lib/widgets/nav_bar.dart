import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vihanga_cabs_driver_app/authentication/Login/login_screen.dart';
import 'package:vihanga_cabs_driver_app/pages/completed_rides.dart';
import 'package:vihanga_cabs_driver_app/pages/home_page.dart';
import 'package:vihanga_cabs_driver_app/pages/accepted_rides.dart';
import 'package:vihanga_cabs_driver_app/pages/ongoing_rides.dart';
import 'package:vihanga_cabs_driver_app/pages/profile.dart';

class NavBar extends StatelessWidget {
  final String driverId;

  const NavBar({super.key, required this.driverId});

  void _logOut(BuildContext context) {
    // Perform any necessary clean-up tasks here (e.g., clear user data, tokens, etc.)

    // Navigate to the login screen
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LogInScreen()),
    );
  }

  void _goToHomePage(BuildContext context) {
    // Navigate to the home page
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>  HomePage(driverId: driverId,)),
    );
  }

  void _goToAcceptedRequestPage(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>  AcceptedRides(driverId: driverId,)),
    );
  }

  void _goToOngoingRidesPage(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>  OngoingRides(driverId: driverId,)),);
  }

  void _goToCompletedRidesPage(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>  CompletedRides(driverId: driverId,)),
    );
  }

  void _goToProfilePage(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>  ProfilePage(driverId: driverId,)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.only(top: 5),
        children: [
          Container(
            height: 360,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/startup.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('ride_requests')
                .where('assignedDriver', isEqualTo: driverId)
                .where('acceptedByDriver', isEqualTo: 'notyet')
                .snapshots(),
            builder: (context, snapshot) {
              int requestCount = 0;
              if (snapshot.hasData) {
                requestCount = snapshot.data!.docs.length;
              }
              return ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Requests'),
                onTap: () => _goToHomePage(context),
                trailing: ClipOval(
                  child: Container(
                    color: Colors.red,
                    width: 20,
                    height: 20,
                    child: Center(
                      child: Text(
                        requestCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('ride_requests')
                .where('assignedDriver', isEqualTo: driverId)
                .where('acceptedByDriver', isEqualTo: 'yes')
                .where('rideStarted', isEqualTo: 'no')
                .snapshots(),
            builder: (context, snapshot) {
              int acceptedCount = 0;
              if (snapshot.hasData) {
                acceptedCount = snapshot.data!.docs.length;
              }
              return ListTile(
                leading: Icon(Icons.car_rental),
                title: Text('Accepted'),
                onTap: () => _goToAcceptedRequestPage(context),
                trailing: ClipOval(
                  child: Container(
                    color: Colors.green,
                    width: 20,
                    height: 20,
                    child: Center(
                      child: Text(
                        acceptedCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),


          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('ride_requests')
                .where('assignedDriver', isEqualTo: driverId)
                .where('rideStarted', isEqualTo: 'yes')
                .where('rideCompletedByDriver' , isEqualTo: 'no')
                .snapshots(),
            builder: (context, snapshot) {
              int requestCount = 0;
              if (snapshot.hasData) {
                requestCount = snapshot.data!.docs.length;
              }
              return ListTile(
                leading: Icon(Icons.play_arrow),
                title: Text('Ongoing Rides'),
                onTap: () => _goToOngoingRidesPage(context),
                trailing: ClipOval(
                  child: Container(
                    color: Colors.amber,
                    width: 20,
                    height: 20,
                    child: Center(
                      child: Text(
                        requestCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.add_task),
            title: Text('Completed'),
            onTap: () => _goToCompletedRidesPage(context),
          ),

          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Profile'),
            onTap: () => _goToProfilePage(context),
          ),

          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Log Out'),
            onTap: () => _logOut(context),
          ),
        ],
      ),
    );
  }
}
