import 'package:every_calendar/constants/all_constants.dart';
import 'package:every_calendar/core/db/abstract_entity.dart';
import 'package:every_calendar/core/db/abstract_repository.dart';
import 'package:every_calendar/core/db/pagination.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

typedef BaseListItemBuilder<T extends AbstractEntity> = Widget Function(
  BuildContext context,
  T item,
  int index,
  int lenght,
  Function() onDelete,
);

class BaseList<T extends AbstractEntity> extends StatefulWidget {
  const BaseList({
    Key? key,
    required this.buildItem,
    required this.repository,
    required this.onSync,
    required this.entityInstance,
    this.limit = 100,
    this.scrollController,
    this.getItems,
    this.expand = true,
  }) : super(key: key);

  final BaseListItemBuilder<T> buildItem;
  final AbstractRepository<T> repository;
  final Future Function(String, List<AbstractEntity>) onSync;
  final T entityInstance;
  final int limit;
  final ScrollController? scrollController;
  final Future<Pagination<T>> Function(int, int)? getItems;
  final bool expand;

  @override
  State<StatefulWidget> createState() => _BaseListState<T>();
}

class _BaseListState<T extends AbstractEntity> extends State<BaseList<T>> {
  bool _hasNext = false;
  late int _length;
  final PagingController<int, T> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetch(pageKey);
    });
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var list = RefreshIndicator(
      onRefresh: _onRefresh,
      backgroundColor: Colors.green,
      color: Colors.white,
      child: PagedListView<int, T>(
        // padding: const EdgeInsets.all(5.0),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        pagingController: _pagingController,
        scrollController: widget.scrollController,
        builderDelegate: PagedChildBuilderDelegate<T>(
          itemBuilder: (ctx, c, index) {
            return widget.buildItem(
              ctx,
              c,
              index,
              _length,
              () => _onDelete(c, index),
            );
          },
        ),
      ),
    );
    if (widget.expand) {
      return Expanded(
        child: list,
      );
    }
    return list;
  }

  Future<void> _fetch(int offset) async {
    try {
      var pagination = widget.getItems != null
          ? await widget.getItems!.call(widget.limit, offset)
          : await widget.repository.getAllPaginated(
              widget.limit,
              offset,
            );
      _length = pagination.count;
      _hasNext = pagination.hasNext;
      if (!pagination.hasNext) {
        _pagingController.appendLastPage(pagination.result);
      } else {
        _pagingController.appendPage(
          pagination.result,
          offset + widget.limit,
        );
      }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  Future _onRefresh() {
    return widget
        .onSync(AllConstants.currentContext, [widget.entityInstance])
        .timeout(const Duration(seconds: 3))
        .then((val) => _pagingController.refresh());
  }

  Future _onDelete(T entity, int index) async {
    List<T> itemList = List.from(_pagingController.itemList!);
    itemList.removeAt(index);
    _pagingController.value = PagingState<int, T>(
      itemList: itemList,
      error: null,
      nextPageKey: _hasNext ? itemList.length : null,
    );
  }
}
