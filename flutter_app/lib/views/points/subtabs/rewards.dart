import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Rewards extends StatefulWidget {
  final TabController tabController;

  const Rewards({super.key, required this.tabController});

  @override
  _RewardsState createState() => _RewardsState();
}

class _RewardsState extends State<Rewards> {
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
                return Center(child: CircularProgressIndicator());
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
                      bool isCompleted = userChallengeData.exists
                          ? userChallengeData['completed']
                          : false;

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
                                    if (isCompleted &&
                                        challenge['description'] ==
                                            'Completed challenge!')
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
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            challenge['reward'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF858597),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Color(0xFFA8DADC),
                                            ),
                                            child: Text(
                                              'Claim',
                                              style: TextStyle(
                                                color: Color(0xFF49447E),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    if (!isCompleted)
                                      Column(
                                        children: [
                                          Icon(
                                            Icons.refresh,
                                            color: Color(0xFF49447E),
                                            size: 100,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'You haven’t completed this challenge',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF49447E),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: () {
                                              widget.tabController.animateTo(1);
                                              Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Color(0xFF49447E),
                                            ),
                                            child: Text(
                                              'Go to challenge',
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
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            title: Text(challenge['title']),
                            subtitle: isCompleted
                                ? Text('Reward: ${challenge['reward']}')
                                : Text('Incomplete challenge'),
                            trailing: Icon(
                              isCompleted
                                  ? Icons.check_circle
                                  : Icons.hourglass_empty,
                              color: isCompleted
                                  ? Color(0xFF03898C)
                                  : Color(0xFF49447E),
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
