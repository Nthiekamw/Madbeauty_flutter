import 'package:flutter/material.dart';

Widget shellNavBadgeIcon({
  required IconData outlined,
  required IconData filled,
  required bool selected,
  int badgeCount = 0,
}) {
  final icon = Icon(selected ? filled : outlined);
  if (badgeCount <= 0) return icon;

  final label = badgeCount > 99 ? '99+' : '$badgeCount';
  return Badge(label: Text(label), child: icon);
}
