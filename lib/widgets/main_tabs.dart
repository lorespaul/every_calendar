import 'package:every_calendar/widgets/nav_drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainTabs extends StatefulWidget {
  const MainTabs({Key? key, required this.title, required this.onLogout})
      : super(key: key);

  final String title;
  final Function() onLogout;

  @override
  State<StatefulWidget> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    const Text("Page 1"),
    const Text("Page 2"),
    const Text("Page 3"),
    const Text("Page 4"),
  ];

  @override
  Widget build(BuildContext context) {
    int i = 0;
    return Scaffold(
      drawer: NavDrawer(
        title: widget.title,
        onLogout: widget.onLogout,
      ),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_children[_currentIndex]],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) => setState(() {
          _currentIndex = index;
        }),
        currentIndex: _currentIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calendar_today,
              color: _currentIndex == i++ ? Colors.green : Colors.black45,
            ),
            label: "Calendar",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.hail_rounded,
              color: _currentIndex == i++ ? Colors.green : Colors.black45,
            ),
            label: "Collaborators",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: _currentIndex == i++ ? Colors.green : Colors.black45,
            ),
            label: "Contacts",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.shopping_bag,
              color: _currentIndex == i++ ? Colors.green : Colors.black45,
            ),
            label: "Activities",
          ),
        ],
      ),
    );
  }
}
