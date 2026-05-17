import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'string_utils.dart';

Widget buildAvatar(String name) {
  final initials = getInitials(name);

  return CircleAvatar(
    radius: 50,
    backgroundColor: ColorsUtils.skyblue,
    child: Text(
      initials,
      style: const TextStyle(
        color: ColorsUtils.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}