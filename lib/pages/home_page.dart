import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:vihanga_cabs_driver_app/widgets/nav_bar.dart';
import 'package:vihanga_cabs_driver_app/widgets/profile_header.dart';

class HomePage extends StatefulWidget {

  final String driverId;

  const HomePage({super.key, required this.driverId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Future<Map<String, dynamic>> _userData;
  late Stream<QuerySnapshot> _ridesStream;
  List<DocumentSnapshot> _rides = [];

  @override
  void initState() {
    super.initState();
    _userData = _fetchUserData();
    _ridesStream = _fetchRidesStream();
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

  Stream<QuerySnapshot> _fetchRidesStream() {
    final User? user = _auth.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('ride_requests')
          .where('assignedDriver', isEqualTo: user.uid)
          .where('acceptedByDriver', isEqualTo: 'no')
          .snapshots();
    } else {
      print('User is not logged in.');
      return const Stream.empty();
    }
  }

  Future<Map<String, dynamic>> _fetchRideDetails(DocumentSnapshot rideRequest) async {
    var data = rideRequest.data() as Map<String, dynamic>;

    // Fetch company data
    var companyData = await FirebaseFirestore.instance
        .collection('companies')
        .doc(data['companyUserId'])
        .get();

    // Fetch user data
    var userData = await FirebaseFirestore.instance
        .collection('company_users')
        .doc(data['userId'])
        .get();

    return {
      'companyName': companyData['companyName'],
      'customerName': userData['name'],
      'pickupLocation': data['pickupLocation'],
      'destination': data['destination'],
      'date': data['date'],
      'time': data['time'],
      'passengers': data['passengers'],
      'stop1': data['stop1'],
      'stop2': data['stop2'],
    };
  }

  void _rejectRideRequest(BuildContext context, DocumentSnapshot rideRequest) async {
    var data = rideRequest.data() as Map<String, dynamic>;

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference rideRef = FirebaseFirestore.instance.collection('ride_requests').doc(rideRequest.id);
      transaction.update(rideRef, {
        'acceptedByDriver': 'no',
        'assignedDriver': FieldValue.delete(),
        'assigned': 'no',
      });
    });

    Navigator.of(context).pop(); // Close the dialog
    setState(() {
      _rides.remove(rideRequest); // Remove the rejected ride from the local list
    });
  }

  void _acceptRideRequest(BuildContext context, DocumentSnapshot rideRequest) async {
    var data = rideRequest.data() as Map<String, dynamic>;

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference rideRef = FirebaseFirestore.instance.collection('ride_requests').doc(rideRequest.id);
      transaction.update(rideRef, {
        'acceptedByDriver': 'yes',
      });
    });

    Navigator.of(context).pop(); // Close the dialog
    setState(() {
      _rides.remove(rideRequest); // Remove the accepted ride from the local list
    });
  }

  void _showRideDetails(BuildContext context, DocumentSnapshot rideRequest) async {
    var data = rideRequest.data() as Map<String, dynamic>;

    // Fetch company data
    var companyData = await FirebaseFirestore.instance
        .collection('companies')
        .doc(data['companyUserId'])
        .get();

    // Fetch user data
    var userData = await FirebaseFirestore.instance
        .collection('company_users')
        .doc(data['userId'])
        .get();

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
                    Text(userData['name']),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Company Name:'),
                    Text(companyData['companyName']),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date:'),
                    Text(data['date']),
                    Text('Time:'),
                    Text(data['time']),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Destination:'),
                    Text(data['destination']),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pick up:'),
                    Text(data['pickupLocation']),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Stops:'),
                    Text(data['stop1'].isNotEmpty ? 'Stop 1: ${data['stop1']}, Stop 2: ${data['stop2']}' : 'None'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('No. of passengers:'),
                    Text(data['passengers'].toString()),
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
                _rejectRideRequest(context, rideRequest);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.green,
              ),
              child: const Text('Accept'),
              onPressed: () {
                _acceptRideRequest(context, rideRequest);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentMonth = DateFormat('MMMM').format(DateTime.now());

    return Scaffold(
      drawer: NavBar(driverId: widget.driverId,),
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
                  const SizedBox(height: 8),
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
                                '53', // Replace with dynamic value
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
                                'LKR 12750', // Replace with dynamic value
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
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _ridesStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error fetching rides: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No ride requests found'));
                        } else {
                          final List<DocumentSnapshot> rides = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: rides.length,
                            itemBuilder: (context, index) {
                              final DocumentSnapshot rideRequest = rides[index];

                              return GestureDetector(
                                onTap: () => _showRideDetails(context, rideRequest),
                                child: Card(
                                  margin: const EdgeInsets.all(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Pickup Location: ${rideRequest['pickupLocation']}',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Destination: ${rideRequest['destination']}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Date: ${rideRequest['date']}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Time: ${rideRequest['time']}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
