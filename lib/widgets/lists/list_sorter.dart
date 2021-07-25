import 'package:every_calendar/widgets/lists/height_injector.dart';
import 'package:flutter/material.dart';

class ListSorter extends StatefulWidget {
  const ListSorter({
    Key? key,
    required this.scrollController,
    required this.orderingFields,
    required this.onHeightCalculated,
  }) : super(key: key);

  final ScrollController scrollController;
  final List<String> orderingFields;
  final void Function(double) onHeightCalculated;

  @override
  State<StatefulWidget> createState() => _ListSorterState();
}

enum SortingType { desc, asc }

class _ListSorterState extends State<ListSorter> {
  SortingType _sortingType = SortingType.asc;
  double _offset = 0.0;
  double? _height;
  late String _selectedField;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_updateHeight);
    _selectedField = widget.orderingFields[0];
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_updateHeight);
    super.dispose();
  }

  void _updateHeight() {
    _offset = widget.scrollController.offset;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var offset = _offset / 5;
    if (_height != null && offset > _height!) {
      offset = _height!;
    }
    return Positioned.fill(
      top: -offset,
      child: Wrap(
        children: [
          HeightInjector(
            builder: (context, height) {
              if (height != null) {
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  _height = height;
                  widget.onHeightCalculated(height);
                });
              }
              return Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<String>(
                      hint: const Text('Select tenant'),
                      value: _selectedField,
                      onChanged: (v) {
                        _selectedField = v!;
                        setState(() {});
                      },
                      items: widget.orderingFields.map((field) {
                        return DropdownMenuItem<String>(
                          value: field,
                          child: Row(
                            children: <Widget>[
                              Text(
                                field,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    IconButton(
                      onPressed: () {
                        if (_sortingType == SortingType.asc) {
                          _sortingType = SortingType.desc;
                        } else {
                          _sortingType = SortingType.asc;
                        }
                        setState(() {});
                      },
                      icon: _sortingType == SortingType.asc
                          ? const Icon(
                              Icons.arrow_upward,
                              color: Colors.black45,
                            )
                          : const Icon(
                              Icons.arrow_downward,
                              color: Colors.black45,
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
