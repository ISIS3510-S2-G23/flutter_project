import 'package:flutter/material.dart';

class SignupSuccess extends StatelessWidget {
  const SignupSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0x7EA8DADC),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Color(0xFF49447E),
                size: 120,
              ),
              Text(
                'Success',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF49447E),
                    fontFamily: 'Inter'),
              ),
              SizedBox(height: 30),
              Text(
                'Congratulations, you have completed your registration!',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF858597),
                    fontFamily: 'Inter'),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // FIXME: Navigate to preferences
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF49447E),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Okay',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Roboto',
                        fontSize: 22)),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
