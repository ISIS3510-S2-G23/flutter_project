import 'package:ecosphere/views-viewmodels/account/account.dart';
import 'package:ecosphere/views-viewmodels/add_post/add_post.dart';
import 'package:ecosphere/views-viewmodels/home/home.dart';
import 'package:ecosphere/views-viewmodels/notifications/notifications.dart';
import 'package:ecosphere/views-viewmodels/points/index_points.dart';
import 'package:flutter/material.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  _IndexScreenState createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Home(),
    Points(),
    Home(),
    Notifications(),
    Account(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddPost()),
        );
      } else {
        _selectedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
              color:
                  _selectedIndex == 0 ? Color(0xFF49447E) : Color(0xFF7D84B2),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 1
                  ? Icons.location_on
                  : Icons.location_on_outlined,
              color:
                  _selectedIndex == 1 ? Color(0xFF49447E) : Color(0xFF7D84B2),
            ),
            label: 'Points',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFEAEAFF),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.add, color: Color(0xFF49447E)),
              ),
            ),
            label: 'Add post',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 3
                  ? Icons.notifications
                  : Icons.notifications_outlined,
              color:
                  _selectedIndex == 3 ? Color(0xFF49447E) : Color(0xFF7D84B2),
            ),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 4
                  ? Icons.account_circle
                  : Icons.account_circle_outlined,
              color:
                  _selectedIndex == 4 ? Color(0xFF49447E) : Color(0xFF7D84B2),
            ),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
