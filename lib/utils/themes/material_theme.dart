import 'package:flutter/material.dart';

class MaterialTheme {
  final TextTheme textTheme;

  MaterialTheme({required this.textTheme});

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff415f91),
      surfaceTint: Color(0xff415f91),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffd6e3ff),
      onPrimaryContainer: Color(0xff284777),
      secondary: Color(0xff565f71),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffdae2f9),
      onSecondaryContainer: Color(0xff3e4759),
      tertiary: Color(0xff705575),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xfffad8fd),
      onTertiaryContainer: Color(0xff573e5c),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff191c20),
      onSurfaceVariant: Color(0xff44474e),
      outline: Color(0xff74777f),
      outlineVariant: Color(0xffc4c6d0),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e3036),
      inversePrimary: Color(0xffaac7ff),
      primaryFixed: Color(0xffd6e3ff),
      onPrimaryFixed: Color(0xff001b3e),
      primaryFixedDim: Color(0xffaac7ff),
      onPrimaryFixedVariant: Color(0xff284777),
      secondaryFixed: Color(0xffdae2f9),
      onSecondaryFixed: Color(0xff131c2b),
      secondaryFixedDim: Color(0xffbec6dc),
      onSecondaryFixedVariant: Color(0xff3e4759),
      tertiaryFixed: Color(0xfffad8fd),
      onTertiaryFixed: Color(0xff28132e),
      tertiaryFixedDim: Color(0xffddbce0),
      onTertiaryFixedVariant: Color(0xff573e5c),
      surfaceDim: Color(0xffd9d9e0),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f3fa),
      surfaceContainer: Color(0xffededf4),
      surfaceContainerHigh: Color(0xffe7e8ee),
      surfaceContainerHighest: Color(0xffe2e2e9),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff032b5b),
      surfaceTint: Color(0xff415f91),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff2a497a),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff232c3d),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff41495b),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff3a2440),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff59405e),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff292c33),
      outlineVariant: Color(0xff464951),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e3036),
      inversePrimary: Color(0xffaac7ff),
      primaryFixed: Color(0xff2a497a),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff0e3262),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff41495b),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff2a3344),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff59405e),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff412a47),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb8b8bf),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f0f7),
      surfaceContainer: Color(0xffe2e2e9),
      surfaceContainerHigh: Color(0xffd3d4db),
      surfaceContainerHighest: Color(0xffc5c6cd),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffaac7ff),
      surfaceTint: Color(0xffaac7ff),
      onPrimary: Color(0xff0a305f),
      primaryContainer: Color(0xff284777),
      onPrimaryContainer: Color(0xffd6e3ff),
      secondary: Color(0xffbec6dc),
      onSecondary: Color(0xff283141),
      secondaryContainer: Color(0xff3e4759),
      onSecondaryContainer: Color(0xffdae2f9),
      tertiary: Color(0xffddbce0),
      onTertiary: Color(0xff3f2844),
      tertiaryContainer: Color(0xff573e5c),
      onTertiaryContainer: Color(0xfffad8fd),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff111318),
      onSurface: Color(0xffe2e2e9),
      onSurfaceVariant: Color(0xffc4c6d0),
      outline: Color(0xff8e9099),
      outlineVariant: Color(0xff44474e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff415f91),
      primaryFixed: Color(0xffd6e3ff),
      onPrimaryFixed: Color(0xff001b3e),
      primaryFixedDim: Color(0xffaac7ff),
      onPrimaryFixedVariant: Color(0xff284777),
      secondaryFixed: Color(0xffdae2f9),
      onSecondaryFixed: Color(0xff131c2b),
      secondaryFixedDim: Color(0xffbec6dc),
      onSecondaryFixedVariant: Color(0xff3e4759),
      tertiaryFixed: Color(0xfffad8fd),
      onTertiaryFixed: Color(0xff28132e),
      tertiaryFixedDim: Color(0xffddbce0),
      onTertiaryFixedVariant: Color(0xff573e5c),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff37393e),
      surfaceContainerLowest: Color(0xff0c0e13),
      surfaceContainerLow: Color(0xff191c20),
      surfaceContainer: Color(0xff1d2024),
      surfaceContainerHigh: Color(0xff282a2f),
      surfaceContainerHighest: Color(0xff33353a),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffebf0ff),
      surfaceTint: Color(0xffaac7ff),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffa6c3fc),
      onPrimaryContainer: Color(0xff000b20),
      secondary: Color(0xffebf0ff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffbac3d8),
      onSecondaryContainer: Color(0xff030b1a),
      tertiary: Color(0xffffe9ff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffd8b8dc),
      onTertiaryContainer: Color(0xff16041d),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff111318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffeeeff9),
      outlineVariant: Color(0xffc0c2cc),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff294878),
      primaryFixed: Color(0xffd6e3ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffaac7ff),
      onPrimaryFixedVariant: Color(0xff00112b),
      secondaryFixed: Color(0xffdae2f9),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffbec6dc),
      onSecondaryFixedVariant: Color(0xff081121),
      tertiaryFixed: Color(0xfffad8fd),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffddbce0),
      onTertiaryFixedVariant: Color(0xff1d0823),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff4e5056),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1d2024),
      surfaceContainer: Color(0xff2e3036),
      surfaceContainerHigh: Color(0xff393b41),
      surfaceContainerHighest: Color(0xff45474c),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      textTheme: textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
    );
  }

// /// White
// static const white = ExtendedColor(
//   seed: Color(0xffffffff),
//   value: Color(0xffffffff),
//   light: ColorFamily(
//     color: Color(0xff006874),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xff9eeffd),
//     onColorContainer: Color(0xff004f58),
//   ),
//   lightHighContrast: ColorFamily(
//     color: Color(0xff006874),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xff9eeffd),
//     onColorContainer: Color(0xff004f58),
//   ),
//   dark: ColorFamily(
//     color: Color(0xff82d3e0),
//     onColor: Color(0xff00363d),
//     colorContainer: Color(0xff004f58),
//     onColorContainer: Color(0xff9eeffd),
//   ),
//   darkHighContrast: ColorFamily(
//     color: Color(0xff82d3e0),
//     onColor: Color(0xff00363d),
//     colorContainer: Color(0xff004f58),
//     onColorContainer: Color(0xff9eeffd),
//   ),
// );
//
// /// Silver
// static const silver = ExtendedColor(
//   seed: Color(0xffc0c0c0),
//   value: Color(0xffc0c0c0),
//   light: ColorFamily(
//     color: Color(0xff006874),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xff9eeffd),
//     onColorContainer: Color(0xff004f58),
//   ),
//   lightHighContrast: ColorFamily(
//     color: Color(0xff006874),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xff9eeffd),
//     onColorContainer: Color(0xff004f58),
//   ),
//   dark: ColorFamily(
//     color: Color(0xff82d3e0),
//     onColor: Color(0xff00363d),
//     colorContainer: Color(0xff004f58),
//     onColorContainer: Color(0xff9eeffd),
//   ),
//   darkHighContrast: ColorFamily(
//     color: Color(0xff82d3e0),
//     onColor: Color(0xff00363d),
//     colorContainer: Color(0xff004f58),
//     onColorContainer: Color(0xff9eeffd),
//   ),
// );
//
// /// Grey
// static const grey = ExtendedColor(
//   seed: Color(0xff808080),
//   value: Color(0xff808080),
//   light: ColorFamily(
//     color: Color(0xff006874),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xff9eeffd),
//     onColorContainer: Color(0xff004f58),
//   ),
//   lightHighContrast: ColorFamily(
//     color: Color(0xff006874),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xff9eeffd),
//     onColorContainer: Color(0xff004f58),
//   ),
//   dark: ColorFamily(
//     color: Color(0xff82d3e0),
//     onColor: Color(0xff00363d),
//     colorContainer: Color(0xff004f58),
//     onColorContainer: Color(0xff9eeffd),
//   ),
//   darkHighContrast: ColorFamily(
//     color: Color(0xff82d3e0),
//     onColor: Color(0xff00363d),
//     colorContainer: Color(0xff004f58),
//     onColorContainer: Color(0xff9eeffd),
//   ),
// );
//
// /// Black
// static const black = ExtendedColor(
//   seed: Color(0xff000000),
//   value: Color(0xff000000),
//   light: ColorFamily(
//     color: Color(0xff8c4a60),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffffd9e2),
//     onColorContainer: Color(0xff703348),
//   ),
//   lightHighContrast: ColorFamily(
//     color: Color(0xff8c4a60),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffffd9e2),
//     onColorContainer: Color(0xff703348),
//   ),
//   dark: ColorFamily(
//     color: Color(0xffffb1c8),
//     onColor: Color(0xff541d32),
//     colorContainer: Color(0xff703348),
//     onColorContainer: Color(0xffffd9e2),
//   ),
//   darkHighContrast: ColorFamily(
//     color: Color(0xffffb1c8),
//     onColor: Color(0xff541d32),
//     colorContainer: Color(0xff703348),
//     onColorContainer: Color(0xffffd9e2),
//   ),
// );
//
// /// Red
// static const red = ExtendedColor(
//   seed: Color(0xffff0000),
//   value: Color(0xffff0000),
//   light: ColorFamily(
//     color: Color(0xff904b40),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffffdad4),
//     onColorContainer: Color(0xff73342a),
//   ),
//   lightHighContrast: ColorFamily(
//     color: Color(0xff904b40),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffffdad4),
//     onColorContainer: Color(0xff73342a),
//   ),
//   dark: ColorFamily(
//     color: Color(0xffffb4a8),
//     onColor: Color(0xff561e16),
//     colorContainer: Color(0xff73342a),
//     onColorContainer: Color(0xffffdad4),
//   ),
//   darkHighContrast: ColorFamily(
//     color: Color(0xffffb4a8),
//     onColor: Color(0xff561e16),
//     colorContainer: Color(0xff73342a),
//     onColorContainer: Color(0xffffdad4),
//   ),
// );
//
// /// Maroon
// static const maroon = ExtendedColor(
//   seed: Color(0xff800000),
//   value: Color(0xff800000),
//   light: ColorFamily(
//     color: Color(0xff904b40),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffffdad4),
//     onColorContainer: Color(0xff73342b),
//   ),
//   lightHighContrast: ColorFamily(
//     color: Color(0xff904b40),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffffdad4),
//     onColorContainer: Color(0xff73342b),
//   ),
//   dark: ColorFamily(
//     color: Color(0xffffb4a8),
//     onColor: Color(0xff561e16),
//     colorContainer: Color(0xff73342b),
//     onColorContainer: Color(0xffffdad4),
//   ),
//   darkHighContrast: ColorFamily(
//     color: Color(0xffffb4a8),
//     onColor: Color(0xff561e16),
//     colorContainer: Color(0xff73342b),
//     onColorContainer: Color(0xffffdad4),
//   ),
// );
//
// /// Yellow
// static const yellow = ExtendedColor(
//   seed: Color(0xffffff00),
//   value: Color(0xffffff00),
//   light: ColorFamily(
//     color: Color(0xff616118),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffe8e78f),
//     onColorContainer: Color(0xff494900),
//   ),
//   lightHighContrast: ColorFamily(
//     color: Color(0xff616118),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffe8e78f),
//     onColorContainer: Color(0xff494900),
//   ),
//   dark: ColorFamily(
//     color: Color(0xffcbcb76),
//     onColor: Color(0xff323200),
//     colorContainer: Color(0xff494900),
//     onColorContainer: Color(0xffe8e78f),
//   ),
//   darkHighContrast: ColorFamily(
//     color: Color(0xffcbcb76),
//     onColor: Color(0xff323200),
//     colorContainer: Color(0xff494900),
//     onColorContainer: Color(0xffe8e78f),
//   ),
// );
//
// /// Olive
// static const olive = ExtendedColor(
//   seed: Color(0xff808000),
//   value: Color(0xff808000),
//   light: ColorFamily(
//     color: Color(0xff616118),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffe8e78f),
//     onColorContainer: Color(0xff494900),
//   ),
//   lightHighContrast: ColorFamily(
//     color: Color(0xff616118),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffe8e78f),
//     onColorContainer: Color(0xff494900),
//   ),
//   dark: ColorFamily(
//     color: Color(0xffcbcb76),
//     onColor: Color(0xff323200),
//     colorContainer: Color(0xff494900),
//     onColorContainer: Color(0xffe8e78f),
//   ),
//   darkHighContrast: ColorFamily(
//     color: Color(0xffcbcb76),
//     onColor: Color(0xff323200),
//     colorContainer: Color(0xff494900),
//     onColorContainer: Color(0xffe8e78f),
//   ),
// );
//
// /// Lime
// static const lime = ExtendedColor(
//   seed: Color(0xff00ff00),
//   value: Color(0xff00ff00),
//   light: ColorFamily(
//     color: Color(0xff406836),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffc0efb0),
//     onColorContainer: Color(0xff285020),
//   ),
//   lightHighContrast: ColorFamily(
//     color: Color(0xff406836),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffc0efb0),
//     onColorContainer: Color(0xff285020),
//   ),
//   dark: ColorFamily(
//     color: Color(0xffa5d395),
//     onColor: Color(0xff11380b),
//     colorContainer: Color(0xff285020),
//     onColorContainer: Color(0xffc0efb0),
//   ),
//   darkHighContrast: ColorFamily(
//     color: Color(0xffa5d395),
//     onColor: Color(0xff11380b),
//     colorContainer: Color(0xff285020),
//     onColorContainer: Color(0xffc0efb0),
//   ),
// );
//
// /// Green
// static const green = ExtendedColor(
//   seed: Color(0xff008000),
//   value: Color(0xff008000),
//   light: ColorFamily(
//     color: Color(0xff406836),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffc0efb0),
//     onColorContainer: Color(0xff285020),
//   ),
//   lightHighContrast: ColorFamily(
//     color: Color(0xff406836),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffc0efb0),
//     onColorContainer: Color(0xff285020),
//   ),
//   dark: ColorFamily(
//     color: Color(0xffa5d396),
//     onColor: Color(0xff11380b),
//     colorContainer: Color(0xff285020),
//     onColorContainer: Color(0xffc0efb0),
//   ),
//   darkHighContrast: ColorFamily(
//     color: Color(0xffa5d396),
//     onColor: Color(0xff11380b),
//     colorContainer: Color(0xff285020),
//     onColorContainer: Color(0xffc0efb0),
//   ),
// );
//
// /// Cyan
// static const cyan = ExtendedColor(
//   seed: Color(0xff00ffff),
//   value: Color(0xff00ffff),
//   light: ColorFamily(
//     color: Color(0xff006a6a),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xff9cf1f0),
//     onColorContainer: Color(0xff004f4f),
//   ),
//   lightHighContrast: ColorFamily(
//     color: Color(0xff006a6a),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xff9cf1f0),
//     onColorContainer: Color(0xff004f4f),
//   ),
//   dark: ColorFamily(
//     color: Color(0xff80d5d4),
//     onColor: Color(0xff003737),
//     colorContainer: Color(0xff004f4f),
//     onColorContainer: Color(0xff9cf1f0),
//   ),
//   darkHighContrast: ColorFamily(
//     color: Color(0xff80d5d4),
//     onColor: Color(0xff003737),
//     colorContainer: Color(0xff004f4f),
//     onColorContainer: Color(0xff9cf1f0),
//   ),
// );
//
// /// Teal
// static const teal = ExtendedColor(
//   seed: Color(0xff008080),
//   value: Color(0xff008080),
//   light: ColorFamily(
//     color: Color(0xff006a6a),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xff9cf1f0),
//     onColorContainer: Color(0xff004f4f),
//   ),
//   lightHighContrast: ColorFamily(
//     color: Color(0xff006a6a),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xff9cf1f0),
//     onColorContainer: Color(0xff004f4f),
//   ),
//   dark: ColorFamily(
//     color: Color(0xff80d5d4),
//     onColor: Color(0xff003737),
//     colorContainer: Color(0xff004f4f),
//     onColorContainer: Color(0xff9cf1f0),
//   ),
//   darkHighContrast: ColorFamily(
//     color: Color(0xff80d5d4),
//     onColor: Color(0xff003737),
//     colorContainer: Color(0xff004f4f),
//     onColorContainer: Color(0xff9cf1f0),
//   ),
// );
//
// /// Blue
// static const blue = ExtendedColor(
//   seed: Color(0xff0000ff),
//   value: Color(0xff0000ff),
//   light: ColorFamily(
//     color: Color(0xff555992),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffe0e0ff),
//     onColorContainer: Color(0xff3e4278),
//   ),
//   lightHighContrast: ColorFamily(
//     color: Color(0xff555992),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffe0e0ff),
//     onColorContainer: Color(0xff3e4278),
//   ),
//   dark: ColorFamily(
//     color: Color(0xffbec2ff),
//     onColor: Color(0xff272b60),
//     colorContainer: Color(0xff3e4278),
//     onColorContainer: Color(0xffe0e0ff),
//   ),
//   darkHighContrast: ColorFamily(
//     color: Color(0xffbec2ff),
//     onColor: Color(0xff272b60),
//     colorContainer: Color(0xff3e4278),
//     onColorContainer: Color(0xffe0e0ff),
//   ),
// );
//
// /// Navy
// static const navy = ExtendedColor(
//   seed: Color(0xff000080),
//   value: Color(0xff000080),
//   light: ColorFamily(
//     color: Color(0xff565992),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffe0e0ff),
//     onColorContainer: Color(0xff3e4278),
//   ),
//   lightHighContrast: ColorFamily(
//     color: Color(0xff565992),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffe0e0ff),
//     onColorContainer: Color(0xff3e4278),
//   ),
//   dark: ColorFamily(
//     color: Color(0xffbfc2ff),
//     onColor: Color(0xff272b60),
//     colorContainer: Color(0xff3e4278),
//     onColorContainer: Color(0xffe0e0ff),
//   ),
//   darkHighContrast: ColorFamily(
//     color: Color(0xffbfc2ff),
//     onColor: Color(0xff272b60),
//     colorContainer: Color(0xff3e4278),
//     onColorContainer: Color(0xffe0e0ff),
//   ),
// );
//
// /// Magenta
// static const magenta = ExtendedColor(
//   seed: Color(0xffff00ff),
//   value: Color(0xffff00ff),
//   light: ColorFamily(
//     color: Color(0xff804d7a),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffffd7f5),
//     onColorContainer: Color(0xff653661),
//   ),
//   lightHighContrast: ColorFamily(
//     color: Color(0xff804d7a),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffffd7f5),
//     onColorContainer: Color(0xff653661),
//   ),
//   dark: ColorFamily(
//     color: Color(0xfff1b3e6),
//     onColor: Color(0xff4c1f49),
//     colorContainer: Color(0xff653661),
//     onColorContainer: Color(0xffffd7f5),
//   ),
//   darkHighContrast: ColorFamily(
//     color: Color(0xfff1b3e6),
//     onColor: Color(0xff4c1f49),
//     colorContainer: Color(0xff653661),
//     onColorContainer: Color(0xffffd7f5),
//   ),
// );
//
// /// Purple
// static const purple = ExtendedColor(
//   seed: Color(0xff800080),
//   value: Color(0xff800080),
//   light: ColorFamily(
//     color: Color(0xff804d7a),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffffd7f5),
//     onColorContainer: Color(0xff653661),
//   ),
//   lightHighContrast: ColorFamily(
//     color: Color(0xff804d7a),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffffd7f5),
//     onColorContainer: Color(0xff653661),
//   ),
//   dark: ColorFamily(
//     color: Color(0xfff1b3e6),
//     onColor: Color(0xff4c1f49),
//     colorContainer: Color(0xff653661),
//     onColorContainer: Color(0xffffd7f5),
//   ),
//   darkHighContrast: ColorFamily(
//     color: Color(0xfff1b3e6),
//     onColor: Color(0xff4c1f49),
//     colorContainer: Color(0xff653661),
//     onColorContainer: Color(0xffffd7f5),
//   ),
// );
//
// /// LightBlue
// static const lightBlue = ExtendedColor(
//   seed: Color(0xffadd8e6),
//   value: Color(0xffadd8e6),
//   light: ColorFamily(
//     color: Color(0xff00687b),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffafecff),
//     onColorContainer: Color(0xff004e5d),
//   ),
//   lightHighContrast: ColorFamily(
//     color: Color(0xff00687b),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffafecff),
//     onColorContainer: Color(0xff004e5d),
//   ),
//   dark: ColorFamily(
//     color: Color(0xff85d2e8),
//     onColor: Color(0xff003641),
//     colorContainer: Color(0xff004e5d),
//     onColorContainer: Color(0xffafecff),
//   ),
//   darkHighContrast: ColorFamily(
//     color: Color(0xff85d2e8),
//     onColor: Color(0xff003641),
//     colorContainer: Color(0xff004e5d),
//     onColorContainer: Color(0xffafecff),
//   ),
// );
//
// /// Pink
// static const pink = ExtendedColor(
//   seed: Color(0xffffc0cb),
//   value: Color(0xffffc0cb),
//   light: ColorFamily(
//     color: Color(0xff8d4959),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffffd9df),
//     onColorContainer: Color(0xff713342),
//   ),
//   lightHighContrast: ColorFamily(
//     color: Color(0xff8d4959),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffffd9df),
//     onColorContainer: Color(0xff713342),
//   ),
//   dark: ColorFamily(
//     color: Color(0xffffb1c0),
//     onColor: Color(0xff551d2c),
//     colorContainer: Color(0xff713342),
//     onColorContainer: Color(0xffffd9df),
//   ),
//   darkHighContrast: ColorFamily(
//     color: Color(0xffffb1c0),
//     onColor: Color(0xff551d2c),
//     colorContainer: Color(0xff713342),
//     onColorContainer: Color(0xffffd9df),
//   ),
// );
//
// /// Orange
// static const orange = ExtendedColor(
//   seed: Color(0xffffa500),
//   value: Color(0xffffa500),
//   light: ColorFamily(
//     color: Color(0xff815512),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffffddb7),
//     onColorContainer: Color(0xff653e00),
//   ),
//   lightHighContrast: ColorFamily(
//     color: Color(0xff815512),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffffddb7),
//     onColorContainer: Color(0xff653e00),
//   ),
//   dark: ColorFamily(
//     color: Color(0xfff7bb70),
//     onColor: Color(0xff462a00),
//     colorContainer: Color(0xff653e00),
//     onColorContainer: Color(0xffffddb7),
//   ),
//   darkHighContrast: ColorFamily(
//     color: Color(0xfff7bb70),
//     onColor: Color(0xff462a00),
//     colorContainer: Color(0xff653e00),
//     onColorContainer: Color(0xffffddb7),
//   ),
// );
//
// /// Aquamarine
// static const aquamarine = ExtendedColor(
//   seed: Color(0xff7fffd4),
//   value: Color(0xff7fffd4),
//   light: ColorFamily(
//     color: Color(0xff176b53),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffa5f2d4),
//     onColorContainer: Color(0xff00513d),
//   ),
//   lightHighContrast: ColorFamily(
//     color: Color(0xff176b53),
//     onColor: Color(0xffffffff),
//     colorContainer: Color(0xffa5f2d4),
//     onColorContainer: Color(0xff00513d),
//   ),
//   dark: ColorFamily(
//     color: Color(0xff89d6b9),
//     onColor: Color(0xff003829),
//     colorContainer: Color(0xff00513d),
//     onColorContainer: Color(0xffa5f2d4),
//   ),
//   darkHighContrast: ColorFamily(
//     color: Color(0xff89d6b9),
//     onColor: Color(0xff003829),
//     colorContainer: Color(0xff00513d),
//     onColorContainer: Color(0xffa5f2d4),
//   ),
// );
//
//
// List<ExtendedColor> get extendedColors => [
//   white,
//   silver,
//   grey,
//   black,
//   red,
//   maroon,
//   yellow,
//   olive,
//   lime,
//   green,
//   cyan,
//   teal,
//   blue,
//   navy,
//   magenta,
//   purple,
//   lightBlue,
//   pink,
//   orange,
//   aquamarine,
// ];
}

// class ExtendedColor {
//   final Color seed, value;
//   final ColorFamily light;
//   final ColorFamily lightHighContrast;
//   final ColorFamily dark;
//   final ColorFamily darkHighContrast;
//
//   const ExtendedColor({
//     required this.seed,
//     required this.value,
//     required this.light,
//     required this.lightHighContrast,
//     required this.dark,
//     required this.darkHighContrast,
//   });
// }
//
// class ColorFamily {
//   const ColorFamily({
//     required this.color,
//     required this.onColor,
//     required this.colorContainer,
//     required this.onColorContainer,
//   });
//
//   final Color color;
//   final Color onColor;
//   final Color colorContainer;
//   final Color onColorContainer;
// }
