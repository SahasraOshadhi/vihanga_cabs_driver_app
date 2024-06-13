import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vihanga_cabs_driver_app/widgets/nav_bar.dart';

class OngoingRides extends StatefulWidget {
  final String driverId;
  const OngoingRides({super.key, required this.driverId});

  @override
  State<OngoingRides> createState() => _OngoingRidesState();
}

class _OngoingRidesState extends State<OngoingRides> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Stream<QuerySnapshot> _ongoingRidesStream;
  late Future<Map<String, dynamic>> _userData;

  @override
  void initState() {
    super.initState();

    _userData = _fetchUserData();
    _ongoingRidesStream = _fetchOngoingRidesStream();
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
          'commissionRate': data['commissionRate'] ?? 0,
        };
      } else {
        print('No user data found for the provided UID.');
      }
    } else {
      print('User is not logged in.');
    }
    return {};
  }


  Stream<QuerySnapshot> _fetchOngoingRidesStream() {
    final User? user = _auth.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('ride_requests')
          .where('assignedDriver', isEqualTo: user.uid)
          .where('rideStarted', isEqualTo: 'yes')
          .where('rideCompletedByDriver', isEqualTo: 'no')
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

  Future<Map<String, dynamic>> _fetchRatesData() async {
    DocumentSnapshot ratesSnapshot = await FirebaseFirestore.instance.collection('rates').doc('KtlKvXsKVOOLTuAZIJG5').get();
    return ratesSnapshot.data() as Map<String, dynamic>;
  }

  Future<void> _updateRideDetails(
      String rideId,
      String companyUserId,
      String cUserId,
      String driverId,
      int startingKm,
      int endingKm,
      int waitingHours,
      int waitingMinutes
      ) async {
    try {
      final ratesData = await _fetchRatesData();
      final costPerKm = double.parse(ratesData['costPerKm'].toString());
      final waitingRatePerMin = double.parse(ratesData['waitingRatePerMin']);

      final userData = await _userData;
      final commissionRate = double.parse(userData['commissionRate'].toString());

      final distance = endingKm - startingKm;
      final rideFare = distance * costPerKm;
      final waitingFare = (waitingHours * 60 * waitingRatePerMin) + (waitingMinutes * waitingRatePerMin);
      final totalRideFare = rideFare + waitingFare;
      final driverCommission = rideFare * (commissionRate / 100);

      await FirebaseFirestore.instance.collection('rides').add({
        'rideRequestId': rideId,
        'startingKm': startingKm,
        'endingKm': endingKm,
        'waitingHours': waitingHours,
        'waitingMinutes': waitingMinutes,
        'distance': distance,
        'rideFare': rideFare,
        'waitingFare' : waitingFare,
        'totalRideFare' : totalRideFare,
        'driverCommission': driverCommission,
        'driverId': driverId,
        'companyId': companyUserId,
        'cUserId': cUserId,
        'createdAt': Timestamp.now(),
      });

      // Update the ride request to mark it as completed by the driver
      await FirebaseFirestore.instance.collection('ride_requests').doc(rideId).update({
        'rideCompletedByDriver': 'yes',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ride details updated successfully.')),
      );

      setState(() {
        _ongoingRidesStream = _fetchOngoingRidesStream(); // Refresh the ongoing rides stream
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update ride details: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(driverId: widget.driverId),
      appBar: AppBar(
        title: const Text('Ongoing Rides'),
        backgroundColor: Colors.amber,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _ongoingRidesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      var ongoingRides = snapshot.data!.docs;

                      if (ongoingRides.isEmpty) {
                        return const Center(
                          child: Text('No ongoing rides available.'),
                        );
                      }

                      return ListView.builder(
                        itemCount: ongoingRides.length,
                        itemBuilder: (context, index) {
                          var ride = ongoingRides[index];

                          return FutureBuilder<Map<String, dynamic>>(
                            future: _fetchRideDetails(ride),
                            builder: (context, rideDetailsSnapshot) {
                              if (rideDetailsSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (rideDetailsSnapshot.hasError) {
                                return Center(child: Text('Error: ${rideDetailsSnapshot.error}'));
                              } else if (!rideDetailsSnapshot.hasData) {
                                return const Center(child: Text('No ride details available.'));
                              } else {
                                var rideDetails = rideDetailsSnapshot.data!;

                                return Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
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
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Card(
                                      margin: const EdgeInsets.all(10),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Update Ride Details',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            const SizedBox(height: 10),
                                            RideDetailsForm(
                                              rideId: ride.id,
                                              companyUserId: ride['companyUserId'], // Pass the companyUserId
                                              cUserId: ride['userId'], // Pass the cUserId
                                              driverId: widget.driverId, // Pass the driverId
                                              onSubmit: _updateRideDetails,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
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

class RideDetailsForm extends StatefulWidget {
  final String rideId;
  final String companyUserId;
  final String cUserId;
  final String driverId;
  final Function(String, String, String, String, int, int, int, int) onSubmit;

  const RideDetailsForm({
    Key? key,
    required this.rideId,
    required this.companyUserId,
    required this.cUserId,
    required this.driverId,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _RideDetailsFormState createState() => _RideDetailsFormState();
}

class _RideDetailsFormState extends State<RideDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _startingKmController = TextEditingController();
  final TextEditingController _endingKmController = TextEditingController();

  int _selectedHours = 0;
  int _selectedMinutes = 0;

  List<int> hours = List<int>.generate(25, (index) => index);
  List<int> minutes = List<int>.generate(60, (index) => index);

  @override
  void dispose() {
    _startingKmController.dispose();
    _endingKmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _startingKmController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Starting Km'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the starting km';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _endingKmController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Ending Km'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the ending km';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Waiting Hours'),
                    DropdownButton<int>(
                      value: _selectedHours,
                      isExpanded: true,
                      items: hours.map((hour) {
                        return DropdownMenuItem<int>(
                          value: hour,
                          child: Text(hour.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedHours = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20), // Space between the two dropdowns
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Waiting Minutes'),
                    DropdownButton<int>(
                      value: _selectedMinutes,
                      isExpanded: true,
                      items: minutes.map((minute) {
                        return DropdownMenuItem<int>(
                          value: minute,
                          child: Text(minute.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMinutes = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSubmit(
                  widget.rideId,
                  widget.companyUserId,
                  widget.cUserId,
                  widget.driverId,
                  int.parse(_startingKmController.text),
                  int.parse(_endingKmController.text),
                  _selectedHours,
                  _selectedMinutes,
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

