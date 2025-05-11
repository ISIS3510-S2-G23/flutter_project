import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecosphere/services/databasehelper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Rewards extends StatefulWidget {
  final TabController tabController;

  const Rewards({super.key, required this.tabController});

  @override
  _RewardsState createState() => _RewardsState();
}

class _RewardsState extends State<Rewards> {
  String? user;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _checkConnectivity();
  }

  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user = prefs.getString('username');
    });
  }

  void _checkConnectivity() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    });
  }

  Future<void> _saveChallengesToLocal(
      List<QueryDocumentSnapshot> challenges) async {
    for (var challenge in challenges) {
      await DatabaseHelper().insertOrUpdateChallenge({
        'id': challenge.id,
        'title': challenge['title'],
        'description': challenge['description'],
        'reward': challenge['reward'],
      });
    }
  }

  Future<void> _saveUserChallengeToLocal(
      String challengeId, String user, bool completed) async {
    await DatabaseHelper().insertOrUpdateUserChallenge({
      'id': '$challengeId-$user',
      'challenge_id': challengeId,
      'user': user,
      'completed': completed ? 1 : 0,
      'progress': completed ? 1 : 0,
    });
  }

  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: _isConnected
              ? StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('challenges')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var challenges = snapshot.data!.docs;
                    // Guardar en local
                    _saveChallengesToLocal(challenges);
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
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            var userChallengeData = userChallengeSnapshot.data!;
                            bool isCompleted = userChallengeData.exists
                                ? userChallengeData['completed']
                                : false;
                            // Guardar en local
                            _saveUserChallengeToLocal(
                                challenge.id, user!, isCompleted);

                            return _rewardCard(
                                challenge['title'],
                                challenge['description'],
                                challenge['reward'],
                                isCompleted);
                          },
                        );
                      },
                    );
                  },
                )
              // si no hay internet
              : FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseHelper().getChallenges(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var challenges = snapshot.data!;
                    if (challenges.isEmpty) {
                      return const Center(
                          child: Text('No challenges found locally.'));
                    }
                    return ListView.builder(
                      itemCount: challenges.length,
                      itemBuilder: (context, index) {
                        var challenge = challenges[index];
                        return FutureBuilder<Map<String, dynamic>?>(
                          future: DatabaseHelper()
                              .getUserChallenge(challenge['id'], user!),
                          builder: (context, userChallengeSnapshot) {
                            if (!userChallengeSnapshot.hasData) {
                              return const Center(
                                  child: Text('No available in offline mode'));
                            }
                            var userChallengeData = userChallengeSnapshot.data;
                            bool isCompleted = userChallengeData != null
                                ? userChallengeData['completed'] == 1
                                : false;

                            return _rewardCard(
                                challenge['title'],
                                challenge['description'],
                                challenge['reward'],
                                isCompleted);
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

  Widget _rewardCard(
      String title, String description, String reward, bool isCompleted) {
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
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  if (isCompleted)
                    Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF03898C),
                          size: 100,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'You finished the challenge!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF03898C),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'You can claim your reward',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF49447E),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF49447E),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            if (_isConnected) {
                              _launchURL(reward);
                              Navigator.of(context).pop();
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('No Internet Connection'),
                                    content: const Text(
                                        'Please connect to the internet to claim your reward.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA8DADC),
                          ),
                          child: _isConnected
                              ? const Text(
                                  'Claim',
                                  style: TextStyle(
                                    color: Color(0xFF49447E),
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              : const Text(
                                  'Claim (Offline)',
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
                        const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Icon(
                            Icons.donut_large,
                            color: Color(0xFF49447E),
                            size: 100,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'You haven’t completed this challenge',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF49447E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Go to challenges in points and complete this challenge to claim your reward',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF858597),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            widget.tabController.animateTo(1);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF49447E),
                          ),
                          child: const Text(
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
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: ListTile(
          leading: Container(
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFFD3ECED)
                  : const Color(0xFFEAEAFF),
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
                    ? const Color(0xFF03898C)
                    : const Color(0xFF49447E),
              ),
            ),
          ),
          title: Text(title),
          subtitle: isCompleted
              ? Text('Reward: $description')
              : const Text('Incomplete challenge'),
          trailing: Icon(
            isCompleted ? Icons.check_circle : Icons.hourglass_empty,
            color:
                isCompleted ? const Color(0xFF03898C) : const Color(0xFF49447E),
          ),
        ),
      ),
    );
  }
}
