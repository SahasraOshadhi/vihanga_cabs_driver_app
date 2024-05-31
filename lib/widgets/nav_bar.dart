import 'package:flutter/material.dart';
import 'package:vihanga_cabs_driver_app/authentication/Login/login_screen.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  void _logOut(BuildContext context) {
    // Perform any necessary clean-up tasks here (e.g., clear user data, tokens, etc.)

    // Navigate to the login screen
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LogInScreen()),
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

          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Requests'),
            onTap: () => null,
            trailing: ClipOval(
              child: Container(
                color: Colors.red,
                width: 20,
                height: 20,
                child: Center(
                  child: Text(
                    '8',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),

          ListTile(
            leading: Icon(Icons.car_rental),
            title: Text('Accepted'),
            onTap: () => null,
            trailing: ClipOval(
              child: Container(
                color: Colors.green,
                width: 20,
                height: 20,
                child: Center(
                  child: Text(
                    '8',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),

          ListTile(
            leading: Icon(Icons.add_task),
            title: Text('Completed'),
            onTap: () => null,
          ),

          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Profile'),
            onTap: () => null,
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
