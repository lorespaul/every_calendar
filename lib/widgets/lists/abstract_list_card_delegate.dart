import 'package:every_calendar/core/db/abstract_entity.dart';
import 'package:flutter/cupertino.dart';

abstract class AbstractListCardDelegate<T extends AbstractEntity> {
  Widget build(
    BuildContext context,
    T entity,
    int index,
    void Function(void Function()) setState,
    Future Function() onDelete,
  );
}
