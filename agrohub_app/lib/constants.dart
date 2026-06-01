import 'package:flutter/material.dart';
String api = "https://agrohub.discloud.app";

const Color componentPrimaryColor = Color(0xFF24961F);
const Color componentAccentColor = Color(0xFF135890);
const Color componentHighlightColor = Color(0xFFFFFF00);
const Color componentSurfaceColor = Colors.white;
const Color componentTextColor = Colors.black;
const Color componentBorderColor = Color(0xFF7A7A7A);
const Color componentShadowColor = Color(0x26000000);

const double componentAppBarHeight = 70;
const double componentButtonHeight = 48;
const double componentInputHeight = 50;
const double componentBorderRadius = 20;
const double componentTitleFontSize = 18;
const double componentLabelFontSize = 18;
const double componentFieldFontSize = 16;
const double componentButtonFontSize = 18;

class DefaultResult {
  final int status;
  final String message;
  final dynamic data;

  DefaultResult({
    required this.status,
    required this.message,
    this.data,
  });
}