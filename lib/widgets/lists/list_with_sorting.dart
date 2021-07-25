import 'dart:ui';

import 'package:every_calendar/constants/dimensions.dart';
import 'package:every_calendar/core/db/abstract_entity.dart';
import 'package:every_calendar/core/db/abstract_repository.dart';
import 'package:every_calendar/widgets/lists/list_sorter.dart';
import 'package:flutter/cupertino.dart';

import 'base_list.dart';

typedef ListWithSortingItemBuilder<T extends AbstractEntity> = Widget Function(
  BuildContext context,
  T item,
  int index,
  int lenght,
  Function() onDelete,
  double? paddingTop,
);

class ListWithSorting<T extends AbstractEntity> extends StatefulWidget {
  const ListWithSorting({
    Key? key,
    required this.buildItem,
    required this.onSync,
    required this.repository,
    this.limit = 100,
  }) : super(key: key);

  final ListWithSortingItemBuilder<T> buildItem;
  final Future Function(String, AbstractEntity?) onSync;
  final AbstractRepository<T> repository;
  final int limit;

  @override
  State<StatefulWidget> createState() => _ListWithSortingState<T>();
}

class _ListWithSortingState<T extends AbstractEntity>
    extends State<ListWithSorting<T>> {
  final ScrollController _scrollController = ScrollController();
  double? _height;

  @override
  Widget build(BuildContext context) {
    var paddingTop = MediaQueryData.fromWindow(window).padding.top;
    var innerHeight = MediaQuery.of(context).size.height -
        (paddingTop + Dimensions.scaffoldTopAndBottomBarHeight);
    return SizedBox(
      height: innerHeight,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          BaseList<T>(
            onSync: widget.onSync,
            repository: widget.repository,
            limit: widget.limit,
            scrollController: _scrollController,
            buildItem: (ctx, entity, index, length, onDelete) {
              return widget.buildItem(
                  ctx, entity, index, length, onDelete, _height);
            },
          ),
          ListSorter(
            scrollController: _scrollController,
            orderingFields: const ['name', 'email'],
            onHeightCalculated: (height) {
              _height = height;
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
