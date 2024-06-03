import 'package:flutter/material.dart';
import 'package:vihanga_cabs_driver_app/widgets/profile_header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:vihanga_cabs_driver_app/widgets/nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        'customerName': 'John Doe',
        'companyName': 'ABC Corp',
        'pickUp': 'Location X',
        'stops': 'None',
        'passengers': '3',
        'estimatedKm': '15',
      },
      {
        'date': '16/06/2024',
        'time': '14:30 PM',
        'destination': 'Location B',
        'customerName': 'Jane Smith',
        'companyName': 'XYZ Ltd',
        'pickUp': 'Location Y',
        'stops': 'Stop 1, Stop 2',
        'passengers': '2',
        'estimatedKm': '20',
      },
      // Add more static rides here
    ];
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Customer Name:'),
                    Text(ride['customerName']),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Company Name:'),
                    Text(ride['companyName']),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date:'),
                    Text(ride['date']),
                    Text('Time:'),
                    Text(ride['time']),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Destination:'),
                    Text(ride['destination']),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pick up:'),
                    Text(ride['pickUp']),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Stops:'),
                    Text(ride['stops']),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('No. of passengers:'),
                    Text(ride['passengers']),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Estimated km:'),
                    Text(ride['estimatedKm']),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.red,
              ),
              child: const Text('Reject'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.green,
              ),
              child: const Text('Accept'),
              onPressed: () {
                Navigator.of(context).pop();
                // Handle the accept action
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentMonth = DateFormat('MMMM').format(DateTime.now()); // Get current month

    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: const Text('Requests'),
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
                  const SizedBox(height: 8), // Add padding below AppBar
                  ProfileHeader(
                    fullName: fullName,
                    imageUrl: imageUrl,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent,
                        borderRadius: const BorderRadius.all(Radius.circular(30)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            currentMonth,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'No. of Rides',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '53', // This will be replaced with the dynamic value later
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Commission',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '5000', // This will be replaced with the dynamic value later
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                                    onTap: () => _showRideDetails(context, ride),
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
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'Date: ${ride['date']}',
                                                          style: const TextStyle(
                                                            fontSize: 18,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 16),
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
                                              ],
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
