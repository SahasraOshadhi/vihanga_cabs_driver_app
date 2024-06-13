import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vihanga_cabs_driver_app/widgets/nav_bar.dart';
import 'package:vihanga_cabs_driver_app/widgets/profile_header.dart';

class CompletedRides extends StatefulWidget {
  final String driverId;
  const CompletedRides({super.key, required this.driverId});

  @override
  State<CompletedRides> createState() => _CompletedRidesState();
}

class _CompletedRidesState extends State<CompletedRides> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Future<Map<String, dynamic>> _userData;
  late Stream<QuerySnapshot> _completedRidesStream;

  @override
  void initState() {
    super.initState();
    _userData = _fetchUserData();
    _completedRidesStream = _fetchCompletedRidesStream();
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

  Stream<QuerySnapshot> _fetchCompletedRidesStream() {
    final User? user = _auth.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('ride_requests')
          .where('assignedDriver', isEqualTo: user.uid)
          .where('completedByDriver', isEqualTo: 'yes')
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

  void _showRideDetails(BuildContext context, Map<String, dynamic> ride) {
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
                    Spacer(),
                    Text(ride['customerName']),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Company Name:'),
                    Spacer(),
                    Text(ride['companyName']),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Date:'),
                    Spacer(),
                    Text(ride['date']),
                  ],
                ),

                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Time:'),
                    Spacer(),
                    Text(ride['time']),
                  ],
                ),

                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Destination:'),
                    Spacer(),
                    Text(ride['destination']),
                  ],
                ),

                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Pick up:'),
                    Spacer(),
                    Text(ride['pickUp']),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Stops:'),
                    Spacer(),
                    Text(ride['stop1'] ?? 'None'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('No. of passengers:'),
                    Spacer(),
                    Text(ride['passengers'].toString()),
                  ],
                ),
                const SizedBox(height: 10),
                // Add more ride details here if needed
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(driverId: widget.driverId),
      appBar: AppBar(
        title: const Text('Completed Rides'),
        backgroundColor: Colors.amber,
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
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

              return Column(
                children: [
                  ProfileHeader(
                    fullName: fullName,
                    imageUrl: imageUrl,
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _completedRidesStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error fetching completed rides: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No completed rides found'));
                        } else {
                          return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var rideRequest = snapshot.data!.docs[index];
                              return FutureBuilder<Map<String, dynamic>>(
                                future: _fetchRideDetails(rideRequest),
                                builder: (context, rideSnapshot) {
                                  if (rideSnapshot.connectionState == ConnectionState.waiting) {
                                    return const ListTile(
                                      title: Text('Loading...'),
                                    );
                                  } else if (rideSnapshot.hasError) {
                                    return ListTile(
                                      title: Text('Error loading ride details: ${rideSnapshot.error}'),
                                    );
                                  } else if (!rideSnapshot.hasData || rideSnapshot.data!.isEmpty) {
                                    return const ListTile(
                                      title: Text('No ride details available'),
                                    );
                                  } else {
                                    var ride = rideSnapshot.data!;
                                    return Card(
                                      child: ListTile(
                                        title: Text(ride['companyName'] ?? 'Unknown Company'),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Customer: ${ride['customerName'] ?? 'Unknown Customer'}'),
                                            Text('Pickup Location: ${ride['pickupLocation']}'),
                                            Text('Destination: ${ride['destination']}'),
                                            Text('Date: ${ride['date']}'),
                                            Text('Time: ${ride['time']}'),
                                            Text('Passengers: ${ride['passengers']}'),
                                            Text('Stop 1: ${ride['stop1']}'),
                                            Text('Stop 2: ${ride['stop2']}'),
                                          ],
                                        ),
                                        onTap: () => _showRideDetails(context, ride),
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
              );
            }
          },
        ),
      ),
    );
  }
}
