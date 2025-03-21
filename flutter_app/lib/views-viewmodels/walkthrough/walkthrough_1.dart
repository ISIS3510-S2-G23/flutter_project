import 'package:flutter/material.dart';

class Walkthrough1 extends StatelessWidget {
  const Walkthrough1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/People/BG/person1.png',
                  height: 300,
                ),
                SizedBox(height: 30),
                Text(
                  'Welcome to EcoSphere!',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600, // Semibold
                    fontSize: 24,
                    color: Color(0xFF7D84B2),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                Text(
                  'Discover a new way to recycle, share, and learn about sustainability in your community.',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Inter',
                    color: Color(0xFF7F7F7F),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                IconButton(
                  icon: Icon(Icons.arrow_circle_right_outlined),
                  color: Color(0xFF7D84B2),
                  iconSize: 70,
                  onPressed: () {
                    Navigator.pushNamed(context, '/walkthrough2');
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
