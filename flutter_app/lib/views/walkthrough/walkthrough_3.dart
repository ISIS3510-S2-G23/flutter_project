import 'package:flutter/material.dart';

class Walkthrough3 extends StatelessWidget {
  const Walkthrough3({super.key});

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
                  'assets/images/People/BG/person4.png',
                  height: 330,
                ),
                SizedBox(height: 30),
                Text(
                  'Join the community',
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
                  'Create an account or log in to start your journey toward a more sustainable world!',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Inter',
                    color: Color(0xFF7F7F7F),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 50,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Color(0xFFA8DADC),
                        ),
                        child: Text(
                          'Log in',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 40),
                    SizedBox(
                      width: 150,
                      height: 50,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Color(0xFFA8DADC),
                        ),
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 22,
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
