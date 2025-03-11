import 'package:ecosphere/views/points/subtabs/challenges.dart';
import 'package:ecosphere/views/points/subtabs/near_me.dart';
import 'package:ecosphere/views/points/subtabs/rewards.dart';
import 'package:flutter/material.dart';

class Points extends StatefulWidget {
  const Points({super.key});

  @override
  _PointsState createState() => _PointsState();
}

class _PointsState extends State<Points> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            toolbarHeight: 110,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Recycle points in Bogotá',
                          style: TextStyle(
                            color: Color(0xFF49447E),
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Image.asset(
                          'assets/images/People/WBG/person8.png',
                          width: 65,
                          height: 65,
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Choice your preference',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            bottom: const TabBar(
              labelColor: Color(0xFF49447E),
              unselectedLabelColor: Color(0xFF7D84B2),
              indicatorColor: Color(0xFF49447E),
              tabs: [
                Tab(
                  child: Text(
                    "Near me",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "Challenges",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "Rewards",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    NearMe(),
                    Challenges(),
                    Rewards(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
