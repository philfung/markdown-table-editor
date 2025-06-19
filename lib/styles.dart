// Styling constants for the Markdown Table Editor app

import 'package:flutter/material.dart';

// Action Chip
const double actionChipFontSize = 12.0;

// App Bar
const Color appBarBackgroundColor = Color(0xFF171717); // dark background
const Color appBarIconColor = Color(0xFFFAFAFA); // white
const double appBarIconSize = 32.0;
const Color appBarSurfaceTintColor = Colors.blue; // default blue
const Color appBarTextColor = Color(0xFFFAFAFA); // white
const double appTitleFontSize = 22.0;

// Background
const Color backgroundColor = Color(0xFF0A0A0A); // dark dark

// Buttons
const Color buttonBackgroundColor = Color(0xFF212121); // dark gray
const Color buttonBorderColor = Color(0xFF3A3A3A); // light gray
const double buttonBorderRadius = 4.0;
const Color buttonHighlightedBackgroundColor = Color(0xFFE5E5E5); // very light gray
const Color buttonHighlightedBorderColor = Color(0xFF717171); // light gray
const Color buttonTextColor = Color(0xFFF0F0F0); // light gray

// Cards
const Color cardBackgroundColor = Color(0xFF171717); // dark background
const Color cardBorderColor = Color(0xFF2E2E2E); // light gray
const double cardPadding = 20.0;
const double cardTitleFontSize = 18.0;
const double cardTitleIconSize = 20.0;
const Color cardTitleTextColor = Color(0xFFF6F6F6); // white

// Dividers
const Color dividerColor = Color(0xFF2E2E2E); // light gray

// Dropdowns
const Color dropdownBackgroundColor = Color(0xFF212121); // dark gray
const Color dropdownBorderColor = Color(0xFF434343); // dark gray
const Color dropdownTextColor = Color(0xFFFAFAFA); // white
const Color dropdownLabelTextColor = Color(0xFFFAFAFA);

// Headers
const Color headerBackgroundColor = Color(0xFF1F1F1F); // dark gray
const Color headerTextColor = Color(0xFFFAFAFA); // white

// Onboarding
Color onboardingFontColor = Colors.blue.shade700; // light gray
const double onboardingFontSize = 20.0;
const double onboardingOpacity = 0.8;

// Text Fields
const Color placeholderTextColor = Color(0xFFA1A1A1); // light gray
const Color textFieldBackgroundColor = Color(0xFF212121); // dark gray
const Color textFieldBorderBackgroundColor = Color(0xFF212121); // dark gray
const String textFieldFontFamily = 'monospace';
const double textFieldFontSize = 12.0;
const int textFieldMaxLines = 3;
const double textFieldSpacing = 10.0;
const Color textFieldTextColor = Color(0xFFA1A1A1); // light gray

// Snackbar
const int snackbarDurationSeconds = 2;

// Switches
const double switchFontSize = 12.0;
const Color switchTextColor = Color(0xFFFAFAFA); // white

// Sync Icon
const Color syncIconColor = Color(0xFFA1A1A1); 
const double syncIconSize = 40.0;

// Tables
const Color tableBorderColor = Color(0xFF2E2E2E); // light gray
const double tableBorderRadius = 0.0;
const double tableCellFontSize = 12.0;
const double tableCellHeight = 20.0;
const double tableCellPadding = 0.0;
const double tableCellWidth = 100.0;
const Color tableDataRowColor = Color(0xFF2E2E2E); // light gray
const double tableHeadingRowHeight = 30.0;
const double tableDataRowMaxHeight = tableHeadingRowHeight;
const double tableDataRowMinHeight = tableHeadingRowHeight;
const Color tableHeaderCellBackgroundColor = Color(0xFF1F1F1F); // dark gray
const Color tableHeaderTextColor = Color(0xFFFAFAFA); // white
const Color tableHeadingBackgroundColor = Color(0xFF1F1F1F); // dark gray
const double tableHeight = 120.0;
const double tableIconSize = 35.0;
const Color tableNormalCellBackgroundColor = Color(0xFF171717); // dark background
const Color tableTextColor = Color(0xFFF9F9F9); // light gray

// Theme Data
ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
  useMaterial3: true,
  scaffoldBackgroundColor: backgroundColor,
  cardColor: cardBackgroundColor,
  dividerColor: dividerColor,
  textTheme: Typography().englishLike,
  inputDecorationTheme: const InputDecorationTheme(
    fillColor: textFieldBackgroundColor,
    border: OutlineInputBorder(borderSide: BorderSide(color: textFieldBorderBackgroundColor)),
    hintStyle: TextStyle(color: placeholderTextColor),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: buttonBackgroundColor,
      foregroundColor: tableTextColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(buttonBorderRadius),
        side: BorderSide(color: buttonBorderColor),
      ),
    ),
  ),
  dataTableTheme: DataTableThemeData(
    headingRowColor: WidgetStateProperty.all(tableHeaderCellBackgroundColor),
    dataRowColor: WidgetStateProperty.all(tableNormalCellBackgroundColor),
    headingTextStyle: TextStyle(color: tableHeaderTextColor),
    dataTextStyle: TextStyle(color: tableTextColor),
    dividerThickness: 1.0,
    decoration: BoxDecoration(border: Border.all(color: tableDataRowColor)),
  ),
);
