import 'package:flutter/material.dart';
import 'package:reminderapp/views/reminder_screen.dart';
import 'package:reminderapp/views/upload_screen.dart';
import 'package:reminderapp/views/logout.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _pageIndex = 0;

  List<Widget> _pages = [

    UploadScreen(),

    ReminderScreen(),

    Logout()
  ];





  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _pageIndex,
          onTap: (value) {
            setState(() {
              _pageIndex = value;
            });
          },
          unselectedItemColor: Colors.black,
          selectedItemColor: Colors.pink,
          items: const [


            BottomNavigationBarItem(icon: Icon(Icons.upload), label: 'Upload'),

            BottomNavigationBarItem(icon: Icon(Icons.alarm_sharp), label: 'Reminders'),

            BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Log out'),
          ],
        ),
        body: _pages[_pageIndex],
      ),
    );
  }
}
