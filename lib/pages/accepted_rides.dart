import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vihanga_cabs_driver_app/pages/ongoing_rides.dart';
import 'package:vihanga_cabs_driver_app/widgets/nav_bar.dart';
import 'package:vihanga_cabs_driver_app/widgets/profile_header.dart';

class AcceptedRides extends StatefulWidget {
  final String driverId;
  const AcceptedRides({super.key, required this.driverId});

  @override
  State<AcceptedRides> createState() => _AcceptedRequestState();
}

class _AcceptedRequestState extends State<AcceptedRides> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Future<Map<String, dynamic>> _userData;
  late Stream<QuerySnapshot> _acceptedRidesStream;

  @override
  void initState() {
    super.initState();
    _userData = _fetchUserData();
    _acceptedRidesStream = _fetchAcceptedRidesStream();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(user.uid)
          .get();
      if (userSnapshot.exists) {
        final data = userSnapshot.data() as Map<String, dynamic>;
        return {
          'firstName': data['firstName'] ?? '',
          'lastName': data['lastName'] ?? '',
          'imageUrl': data['selfPic'] ?? '',
        };
      } else {
        print('No user data found for the provided UID.');
      }
    } else {
      print('User is not logged in.');
    }
    return {};
  }

  Stream<QuerySnapshot> _fetchAcceptedRidesStream() {
    final User? user = _auth.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('ride_requests')
          .where('assignedDriver', isEqualTo: user.uid)
          .where('acceptedByDriver', isEqualTo: 'yes')
          .where('rideStarted', isNotEqualTo: 'yes')
          .snapshots();
    } else {
      print('User is not logged in.');
      return const Stream.empty();
    }
  }

  Future<Map<String, dynamic>> _fetchRideDetails(DocumentSnapshot rideRequest) async {
    var data = rideRequest.data() as Map<String, dynamic>;

    // Fetch company data
    var companyData = await _fetchCompanyData(data['companyUserId']);

    // Fetch user data
    var userData = await _fetchCompanyUserData(data['userId']);

    return {
      'companyName': companyData['companyName'],
      'customerName': userData['name'],
      'customerContact': userData['telephone'],
      'pickupLocation': data['pickupLocation'],
      'destination': data['destination'],
      'date': data['date'],
      'time': data['time'],
      'passengers': data['passengers'],
      'stop1': data['stop1'],
      'stop2': data['stop2'],
    };
  }

  Future<Map<String, dynamic>> _fetchCompanyData(String companyUserId) async {
    DocumentSnapshot companySnapshot = await FirebaseFirestore.instance.collection('companies').doc(companyUserId).get();
    return companySnapshot.data() as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _fetchCompanyUserData(String userId) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('company_users').doc(userId).get();
    return userSnapshot.data() as Map<String, dynamic>;
  }

  void _showAcceptedRideDetails(BuildContext context, DocumentSnapshot rideRequest) async {
    var rideDetails = await _fetchRideDetails(rideRequest);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text('Customer Name:'),
                    Text(rideDetails['customerName']),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Customer Contact:'),
                    Text(rideDetails['customerContact']),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Company Name:'),
                    Text(rideDetails['companyName']),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Date:'),
                    Text(rideDetails['date']),
                    Text('Time:'),
                    Text(rideDetails['time']),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Destination:'),
                    Text(rideDetails['destination']),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Pick up:'),
                    Text(rideDetails['pickupLocation']),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Stops:'),
                    Text(rideDetails['stop1'].isNotEmpty ? 'Stop 1: ${rideDetails['stop1']}, Stop 2: ${rideDetails['stop2']}' : 'None'),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _startRide(DocumentSnapshot rideRequest) async {
    try {
      await FirebaseFirestore.instance.collection('ride_requests').doc(rideRequest.id).update({'rideStarted': 'yes'});
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>  OngoingRides(driverId: widget.driverId,)),);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ride started successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start ride: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(driverId: widget.driverId),
      appBar: AppBar(
        title: const Text('Accepted Requests'),
        backgroundColor: Colors.amber,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              FutureBuilder<Map<String, dynamic>>(
                future: _userData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error fetching user data: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No user data available'));
                  } else {
                    final Map<String, dynamic> userData = snapshot.data!;
                    final String fullName = '${userData['firstName']} ${userData['lastName']}';
                    final String imageUrl = userData['imageUrl'];

                    return ProfileHeader(
                      fullName: fullName,
                      imageUrl: imageUrl,
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _acceptedRidesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      var rideRequests = snapshot.data!.docs;

                      if (rideRequests.isEmpty) {
                        return const Center(
                          child: Text('No accepted ride requests available.'),
                        );
                      }

                      return ListView.builder(
                        itemCount: rideRequests.length,
                        itemBuilder: (context, index) {
                          var rideRequest = rideRequests[index];

                          return FutureBuilder<Map<String, dynamic>>(
                            future: _fetchRideDetails(rideRequest),
                            builder: (context, rideDetailsSnapshot) {
                              if (rideDetailsSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (rideDetailsSnapshot.hasError) {
                                return Center(child: Text('Error: ${rideDetailsSnapshot.error}'));
                              } else if (!rideDetailsSnapshot.hasData) {
                                return const Center(child: Text('No ride details available.'));
                              } else {
                                var rideDetails = rideDetailsSnapshot.data!;

                                return GestureDetector(
                                  onTap: () => _showAcceptedRideDetails(context, rideRequest),
                                  child: Card(
                                    margin: const EdgeInsets.all(10),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Customer Name: ${rideDetails['customerName']}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          const SizedBox(height: 5),
                                          Text('Customer Contact: ${rideDetails['customerContact']}'),
                                          const SizedBox(height: 5),
                                          Text('Destination: ${rideDetails['destination']}'),
                                          const SizedBox(height: 5),
                                          Text('Pick up: ${rideDetails['pickupLocation']}'),
                                          const SizedBox(height: 5),
                                          Text('Date: ${rideDetails['date']}'),
                                          const SizedBox(height: 5),
                                          Text('Time: ${rideDetails['time']}'),
                                          const SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: () => _startRide(rideRequest),
                                            child: const Text('Start Ride'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
