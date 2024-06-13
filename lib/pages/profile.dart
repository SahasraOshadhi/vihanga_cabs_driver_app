import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vihanga_cabs_driver_app/widgets/nav_bar.dart';

class ProfilePage extends StatefulWidget {
  final String driverId;
  const ProfilePage({super.key, required this.driverId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child('drivers');

  late Future<Map<String, dynamic>> _userData;

  @override
  void initState() {
    super.initState();
    _userData = _fetchUserData();
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
        final String email = user.email ?? '';
        final String imageUrl = data['selfPic'] ?? '';

        return {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(driverId: widget.driverId,),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
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
            final String email = userData['email'];
            final String imageUrl = userData['imageUrl'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Image.network(
                        imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      fullName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      email,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => EditPasswordPage()),);
                      },
                      child: const Text('Edit Password'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => EditPersonalDetailsPage()),);

                      },
                      child: const Text('Edit Personal Details'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => EditVehicleDetailsPage()));
                      },
                      child: const Text('Edit Vehicle Details'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
