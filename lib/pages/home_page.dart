import 'package:flutter/material.dart';
import 'package:vihanga_cabs_driver_app/widgets/nav_bar.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text('Requests'),
      ),
      body: Center(
        child: Text(
          "Home Page",
          style: TextStyle(fontSize: 20, color: Colors.black87),

        ),
      ),
    );
  }
}
