import 'package:every_calendar/constants/dimensions.dart';
import 'package:every_calendar/core/db/abstract_entity.dart';
import 'package:every_calendar/model/collaborator.dart';
import 'package:every_calendar/repositories/collaborators_repository.dart';
import 'package:every_calendar/widgets/collaborators/add_edit_collaborator.dart';
import 'package:every_calendar/widgets/collaborators/collaborator_card.dart';
import 'package:every_calendar/widgets/lists/base_list.dart';
import 'package:every_calendar/widgets/nav_drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainTabs extends StatefulWidget {
  const MainTabs({
    Key? key,
    required this.title,
    required this.onLogout,
    required this.onSync,
  }) : super(key: key);

  final String title;
  final Function() onLogout;
  final Function(String, AbstractEntity?) onSync;

  @override
  State<StatefulWidget> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _currentIndex = 0;
  GlobalKey _page2Key = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  List<WidgetWrapper> createTabWidgets(
    Function(String, AbstractEntity?) onSync,
  ) {
    return [
      WidgetWrapper(
        const Text("Page 1"),
      ),
      WidgetWrapper(
        BaseList<Collaborator>(
          key: _page2Key,
          card: CollaboratorCard(),
          repository: CollaboratorsRepository(),
          onSync: onSync,
        ),
        title: 'Collaborators',
        actionsWrapper: [
          ActionWrapper(
            () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const AddEditCollaborator(
                  title: 'Add Collaborator',
                );
              })).then(
                (value) => setState(() {
                  _page2Key = GlobalKey();
                }),
              );
            },
            const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      WidgetWrapper(
        const Text("Page 3"),
      ),
      WidgetWrapper(
        const Text("Page 4"),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    int i = 0;

    List<WidgetWrapper> children = createTabWidgets(widget.onSync);
    String title = children[_currentIndex].title ?? widget.title;
    List<ActionWrapper>? actionsWrapper =
        children[_currentIndex].actionsWrapper;

    return Scaffold(
      drawer: NavDrawer(
        title: widget.title,
        onLogout: widget.onLogout,
        onSync: (c) => widget.onSync(c, null),
      ),
      appBar: AppBar(
        toolbarHeight: Dimensions.appBarHeight,
        title: Text(title),
        actions: actionsWrapper
            ?.map(
              (a) => Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: a.onTap,
                  child: a.icon,
                ),
              ),
            )
            .toList(),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [children[_currentIndex].widget],
        ),
      ),
      bottomNavigationBar: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: Dimensions.bottomNavigationBarHeight,
        child: BottomNavigationBar(
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
      ),
    );
  }
}

class WidgetWrapper {
  Widget widget;
  String? title;
  List<ActionWrapper>? actionsWrapper;

  WidgetWrapper(
    this.widget, {
    this.title,
    this.actionsWrapper,
  });
}

class ActionWrapper {
  Function() onTap;
  Icon icon;

  ActionWrapper(
    this.onTap,
    this.icon,
  );
}
