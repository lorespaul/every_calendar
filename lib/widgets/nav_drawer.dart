import 'package:every_calendar/core/google/login_service.dart';
import 'package:every_calendar/widgets/dev_generator.dart';
import 'package:every_calendar/widgets/tenants/tenants.dart';
import 'package:every_calendar/widgets/user_avatar.dart';
import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  NavDrawer({
    Key? key,
    required this.title,
    required this.onLogout,
    required this.onSync,
  }) : super(key: key);

  static const double _avatarSize = 75;
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
                const Spacer(),
                SizedBox(
                  height: _avatarSize,
                  width: _avatarSize,
                  child: UserAvatar(
                    identity: _loginService.loggedUser,
                    placeholderPhotoUrl: 'assets/user_placeholder.png',
                    fontSize: 20,
                  ),
                ),
                const Spacer(),
                Text(
                  _loginService.loggedUser.displayName ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 25),
                ),
                const Spacer(),
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
            leading: const Icon(Icons.games_outlined),
            title: const Text('Dev Generator'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return DevGenerator();
              }));
            },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Tenant'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Tenants(
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
