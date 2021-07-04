import 'package:every_calendar/widgets/menu/tenant_manger.dart';
import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({
    Key? key,
    required this.title,
    required this.onLogout,
    required this.onSync,
  }) : super(key: key);

  final String title;
  final Function() onLogout;
  final Function(String) onSync;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            child: Text(
              'Side menu',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
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
                return TenantManager(
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
