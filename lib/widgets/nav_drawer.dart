import 'package:every_calendar/core/google/login_service.dart';
import 'package:every_calendar/widgets/tenants/tenants.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in/widgets.dart';

class NavDrawer extends StatelessWidget {
  NavDrawer({
    Key? key,
    required this.title,
    required this.onLogout,
    required this.onSync,
  }) : super(key: key);

  final String title;
  final Function() onLogout;
  final Function(String) onSync;
  final LoginService _loginService = LoginService();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
              children: [
                GoogleUserCircleAvatar(
                  identity: _loginService.loggedUser,
                ),
                const Spacer(),
                const Text(
                  'Side menu',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ],
            ),
            decoration: const BoxDecoration(
              color: Colors.green,
              // image: DecorationImage(
              //   fit: BoxFit.fill,
              //   image: AssetImage('assets/images/cover.jpg'),
              // ),
            ),
          ),
          // ListTile(
          //   leading: const Icon(Icons.input),
          //   title: const Text('Welcome'),
          //   onTap: () => {},
          // ),
          // ListTile(
          //   leading: const Icon(Icons.verified_user),
          //   title: const Text('Profile'),
          //   onTap: () => {Navigator.of(context).pop()},
          // ),
          // ListTile(
          //   leading: const Icon(Icons.settings),
          //   title: const Text('Settings'),
          //   onTap: () => {Navigator.of(context).pop()},
          // ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Tenant'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Tenants(
                  title: title,
                  onSync: onSync,
                );
              }));
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              onLogout();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
