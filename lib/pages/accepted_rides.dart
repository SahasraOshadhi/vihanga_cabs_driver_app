import 'package:flutter/material.dart';
import 'package:vihanga_cabs_driver_app/widgets/nav_bar.dart';
import 'package:vihanga_cabs_driver_app/widgets/profile_header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AcceptedRides extends StatefulWidget {
  const AcceptedRides({super.key});

  @override
  State<AcceptedRides> createState() => _AcceptedRequestState();
}

class _AcceptedRequestState extends State<AcceptedRides> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child('drivers');

  late Future<Map<String, dynamic>> _userData;
  late Future<List<Map<String, dynamic>>> _ridesData;

  @override
  void initState() {
    super.initState();
    _userData = _fetchUserData();
    _ridesData = _fetchRidesData();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final DatabaseReference userRef = _databaseRef.child(user.uid);

      DataSnapshot snapshot = await userRef.get();
      if (snapshot.exists) {
        final Map<dynamic, dynamic> data = snapshot.value as Map;
        final String firstName = data['firstName'] ?? '';
        final String lastName = data['lastName'] ?? '';
        final String imageUrl = data['selfPic'] ?? ''; // Fetch the selfPic URL

        return {
          'firstName': firstName,
          'lastName': lastName,
          'imageUrl': imageUrl,
        };
      } else {
        print('No user data found for the provided UID.');
      }
    } else {
      print('User is not logged in.');
    }
    return {};
  }

  Future<List<Map<String, dynamic>>> _fetchRidesData() async {
    // This function will fetch the ride data from Firebase
    // For demonstration, we use static data here
    return [
      {
        'date': '15/06/2024',
        'time': '13:30 PM',
        'destination': 'Location A',
      },
      {
        'date': '16/06/2024',
        'time': '14:30 PM',
        'destination': 'Location B',
      },
      // Add more static rides here
    ];
  }

  void _showRideDetails(BuildContext context) {
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
                    CircleAvatar(
                      backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Placeholder profile picture URL
                      radius: 30,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Customer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    const Text('Value'), // Placeholder value
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Text('Customer Contact:'),
                    Spacer(),
                    Text('Value'), // Placeholder value
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Text('Company Name:'),
                    Spacer(),
                    Text('Value'), // Placeholder value
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Text('Date:'),
                    Spacer(),
                    Text('Value'), // Placeholder value
                    Spacer(),
                    Text('Time:'),
                    Spacer(),
                    Text('Value'), // Placeholder value
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Text('Destination:'),
                    Spacer(),
                    Text('Value'), // Placeholder value
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Text('Pick up:'),
                    Spacer(),
                    Text('Value'), // Placeholder value
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Text('Stops:'),
                    Spacer(),
                    Text('Value'), // Placeholder value
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Text('No. of passengers:'),
                    Spacer(),
                    Text('Value'), // Placeholder value
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Text('Estimated km:'),
                    Spacer(),
                    Text('Value'), // Placeholder value
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: const Text('Accepted Requests'),
        backgroundColor: Colors.amber, // Set the AppBar color
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
                  const SizedBox(height: 8), // Add padding below AppBar
                  ProfileHeader(
                    fullName: fullName,
                    imageUrl: imageUrl,
                  ),
                  const SizedBox(height: 8), // Add padding between containers
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _ridesData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error fetching ride data: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No ride data available'));
                        } else {
                          final List<Map<String, dynamic>> ridesData = snapshot.data!;

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: const BorderRadius.all(Radius.circular(30)),
                              ),
                              child: ListView.builder(
                                itemCount: ridesData.length,
                                itemBuilder: (context, index) {
                                  final ride = ridesData[index];
                                  return GestureDetector(
                                    onTap: () => _showRideDetails(context),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurpleAccent,
                                          borderRadius: const BorderRadius.all(Radius.circular(30)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Date: ${ride['date']}',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Time: ${ride['time']}',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Destination: ${ride['destination']}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
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
