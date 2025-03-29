import 'package:flutter/material.dart';

extension ColorSchemeExtension on ColorScheme {
  Color get black =>
      brightness == Brightness.light ? const Color(0xFF000000) : const Color(0xFF000000);

  Color get grey1 =>
      brightness == Brightness.light ? const Color(0xFF111111) : const Color(0xFF111111);

  Color get grey2 =>
      brightness == Brightness.light ? const Color(0xFF222222) : const Color(0xFF222222);

  Color get grey3 =>
      brightness == Brightness.light ? const Color(0xFF333333) : const Color(0xFF333333);

  Color get grey4 =>
      brightness == Brightness.light ? const Color(0xFF444444) : const Color(0xFF444444);

  Color get grey5 =>
      brightness == Brightness.light ? const Color(0xFF555555) : const Color(0xFF555555);

  Color get grey6 =>
      brightness == Brightness.light ? const Color(0xFF666666) : const Color(0xFF666666);

  Color get grey7 =>
      brightness == Brightness.light ? const Color(0xFF777777) : const Color(0xFF777777);

  Color get grey8 =>
      brightness == Brightness.light ? const Color(0xFF888888) : const Color(0xFF888888);

  Color get grey9 =>
      brightness == Brightness.light ? const Color(0xFF999999) : const Color(0xFF999999);

  Color get greyA =>
      brightness == Brightness.light ? const Color(0xFFAAAAAA) : const Color(0xFFAAAAAA);

  Color get greyB =>
      brightness == Brightness.light ? const Color(0xFFBBBBBB) : const Color(0xFFBBBBBB);

  Color get greyC =>
      brightness == Brightness.light ? const Color(0xFFCCCCCC) : const Color(0xFFCCCCCC);

  Color get greyD =>
      brightness == Brightness.light ? const Color(0xFFDDDDDD) : const Color(0xFFDDDDDD);

  Color get greyE =>
      brightness == Brightness.light ? const Color(0xFFEEEEEE) : const Color(0xFFEEEEEE);

  Color get white =>
      brightness == Brightness.light ? const Color(0xFFFFFFFF) : const Color(0xFFFFFFFF);

  Color get statusGreen =>
      brightness == Brightness.light ? const Color(0xFF4CAF50) : const Color(0xFF81C784);

  Color get statusTeal =>
      brightness == Brightness.light ? const Color(0xff06debe) : const Color(0xff06debe);

  Color get statusOrange =>
      brightness == Brightness.light ? const Color(0xFFe98e36) : const Color(0xFFe98e36);

  Color get statusRed =>
      brightness == Brightness.light ? const Color(0xFFD32F2F) : const Color(0xFFEF5350);



  Color get statusPreparation =>
      brightness == Brightness.light ? const Color(0xFF3434CC) : const Color(0xFF3434CC);

  Color get statusParticipation =>
      brightness == Brightness.light ? const Color(0xFFe98e36) : const Color(0xFFe98e36);

  Color get statusVoting =>
      brightness == Brightness.light ? const Color(0xff06debe) : const Color(0xff06debe);

  Color get statusTerminated =>
      brightness == Brightness.light ? const Color(0xff505050) : const Color(0xff505050);

  Color get statusDeleted =>
      brightness == Brightness.light ? const Color(0xFFD32F2F) : const Color(0xFFEF5350);
}
