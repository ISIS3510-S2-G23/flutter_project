import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Challenges extends StatefulWidget {
  const Challenges({super.key});

  @override
  _ChallengesState createState() => _ChallengesState();
}

class _ChallengesState extends State<Challenges> {
  String? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user = prefs.getString('username');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection('challenges').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return Center(child: Text('No challenges available'));
                }
              }
              var challenges = snapshot.data!.docs;
              return ListView.builder(
                itemCount: challenges.length,
                itemBuilder: (context, index) {
                  var post = challenges[index];

                  return FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('users-challenges')
                        .doc('${post.id}-$user')
                        .get(),
                    builder: (context, userChallengeSnapshot) {
                      if (!userChallengeSnapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }
                      var userChallengeData = userChallengeSnapshot.data!;
                      bool isCompleted = userChallengeData['completed'];

                      return Card(
                        color: Colors.white,
                        elevation: 5,
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? Color(0xFFD3ECED)
                                      : Color(0xFFEAEAFF),
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Icon(
                                    isCompleted
                                        ? Icons.check_circle_outline
                                        : Icons.donut_large_outlined,
                                    color: isCompleted
                                        ? Color(0xFF03898C)
                                        : Color(0xFF49447E),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post['title'],
                                  ),
                                  Text(
                                    '${(userChallengeData['progress'] * 100).toInt()}% completed',
                                    style: TextStyle(
                                        fontSize: 12, color: Color(0xFFB8B8D2)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
