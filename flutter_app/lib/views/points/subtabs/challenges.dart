// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Challenges extends StatefulWidget {
  final TabController tabController;

  const Challenges({super.key, required this.tabController});

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
                  var challenge = challenges[index];

                  return FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('users-challenges')
                        .doc('${challenge.id}-$user')
                        .get(),
                    builder: (context, userChallengeSnapshot) {
                      if (!userChallengeSnapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }
                      var userChallengeData = userChallengeSnapshot.data!;
                      bool isCompleted = userChallengeData['completed'];

                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        icon: Icon(Icons.close),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                    if (isCompleted)
                                      Column(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF03898C),
                                            size: 100,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'You finished the challenge!',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF03898C),
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'You can claim your reward',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF858597),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                widget.tabController
                                                    .animateTo(2);
                                                Navigator.of(context).pop();
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Color(0xFFA8DADC),
                                            ),
                                            child: Text(
                                              'Claim',
                                              style: TextStyle(
                                                color: Color(0xFF49447E),
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    if (!isCompleted)
                                      Column(
                                        children: [
                                          Text(
                                            'Register visit',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF49447E),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          Text(
                                            'Validate your challenge with a photo of ' +
                                                challenge['description'],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF858597),
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          ElevatedButton(
                                            onPressed: () {
                                              // TODO modelo de visual
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Color(0xFFEAEAFF),
                                            ),
                                            child: Text(
                                              'Open Camera',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          Text(
                                            'Provide the code given by the recycle point manager',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF858597),
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          TextField(
                                            decoration: InputDecoration(
                                              hintText: 'Type code',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                //TODO update validation
                                                Navigator.of(context).pop();
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Color(0xFF49447E),
                                            ),
                                            child: Text(
                                              'Register',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Card(
                          color: Colors.white,
                          elevation: 5,
                          margin:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 10),
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
                                SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      challenge['title'],
                                    ),
                                    Text(
                                      '${(userChallengeData['progress'] * 100).toInt()}% completed',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFB8B8D2)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
