// Styling constants for the Markdown Table Editor app

import 'package:flutter/material.dart';

Color whiteColor = Colors.white;
Color blackColor = Colors.black;
Color blueColor = Colors.blue;
Color lightGrayColor = Colors.grey;
Color mediumGrayColor = Colors.grey.shade600;
Color darkGrayColor = Colors.grey.shade900;

// Action Chip
const double actionChipFontSize = 12.0;

// App Bar
const Color appBarBackgroundColor = Color(0xFF171717); // dark background
Color appBarTextColor = Colors.blue; // white
Color appBarIconColor = Colors.blue; // white
const double appBarIconSize = 29.0;
Color appBarSurfaceTintColor = blueColor;// default blue
const double appTitleFontSize = 20.0;
const LinearGradient appTitleGradient = LinearGradient(
  colors: [
    // Colors.purple,
    Colors.indigo,
    Colors.blue,
    // Colors.green,
    // Colors.yellow,
    // Colors.orange,
    // Colors.red,
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);
// Background
Color backgroundColor = blackColor; // dark dark

// Buttons
Color buttonBackgroundColor = darkGrayColor; // dark gray
Color buttonBorderColor = lightGrayColor; // light gray
const double buttonBorderRadius = 4.0;
Color buttonTextColor = whiteColor; // light gray

// Cards
const Color cardBackgroundColor = Color(0xFF171717); // dark background
const Color cardBorderColor = Color(0xFF2E2E2E); // light gray
const double cardPadding = 20.0;
const double cardTitleFontSize = 18.0;
const double cardTitleIconSize = 20.0;
const Color cardTitleTextColor = Color(0xFFF6F6F6); // white
Color cardSubtitleTextColor = lightGrayColor;// light gray
const double cardSubtitleFontSize = 11.0;
const double cardTitleSubtitleSpacing = 5.0;
final LinearGradient cardTitleGradient = LinearGradient(
  colors: [
    Colors.indigo,
    Colors.blue,
  ],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);
// Dividers
const Color dividerColor = Color(0xFF2E2E2E); // light gray

// Export Card
const double exportFormatFontSize = 12.0;

// Footer
Color footerBackgroundColor = backgroundColor; // dark background
Color footerTextColor = cardSubtitleTextColor; // light gray

// Headers
const Color headerBackgroundColor = Color(0xFF1F1F1F); // dark gray
const Color headerTextColor = Color(0xFFFAFAFA); // white

// Onboarding
Color onboardingFontColor = const Color(0xFF1976D2); // light gray
const double onboardingFontSize = 20.0;
const double onboardingFirstMessageFontSize = 25.0;
const double onboardingOpacity = 0.8;
final LinearGradient onboardingGradient = LinearGradient(
  colors: [
    // Colors.red,
    // Colors.orange,
    // Colors.yellow,
    // Colors.purple,
    Colors.indigo,
    Colors.blue,
    // Colors.green,
  ],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

const double cardWidth = double.infinity; // Width for cards to take full available space

// Tables
Color tableControlsButtonBorderColor = mediumGrayColor;
Color tableControlsButtonTextColor = lightGrayColor; // white
Color tableControlsButtonBackgroundColor = cardBackgroundColor; // dark background
const Color tableControlsSwitchActiveColor = Color(0xFF171717); // dark background
const Color tableControlsSwitchActiveTrackColor = Color(0xFF2E2E2E); // light gray
const Color tableControlsSwitchInactiveThumbColor = Color(0xFFA1A1A1); // light gray
const Color tableControlsSwitchInactiveTrackColor = Color(0xFF2E2E2E); // light gray
const double tableControlsSwitchFontSize = 12.0;
const double tableControlsSwitchScale = 0.7; // hacky but no way to directly set switch height
Color tableControlsSwitchUnderlineColor = mediumGrayColor; // light gray
Color tableControlsSwitchTextColor = mediumGrayColor; // white
const Color tableBorderColor = Color(0xFF2E2E2E); // light gray
const double tableBorderRadius = 4.0;
const double tableCellFontSize = 14.0;
const double tableCellHeight = 25.0;
const double tableCellPadding = 0.0;
const double tableCellWidth = 80.0;
const Color tableDataRowColor = Color(0xFF2E2E2E); // light gray
const double tableHeadingRowHeight = 40.0;
const double tableDataRowMaxHeight = tableHeadingRowHeight;
const double tableDataRowMinHeight = tableHeadingRowHeight;
const Color tableHeaderCellBackgroundColor = Color(0xFF1F1F1F); // dark gray
const Color tableHeaderTextColor = Color(0xFFFAFAFA); // white
const Color tableHeadingBackgroundColor = Color(0xFF1F1F1F); // dark gray
const int tableNumRows = 3;
const double tableHeight = tableDataRowMaxHeight * tableNumRows * 1.1;
const double tableIconSize = 35.0;
const Color tableNormalCellBackgroundColor = Color(0xFF171717); // dark background
const Color tableTextColor = Color(0xFFF9F9F9); // light gray

// Text Fields
const Color placeholderTextColor = Color(0xFFA1A1A1); // light gray
Color textFieldBackgroundColor = cardBackgroundColor; // dark gray
Color textFieldBorderBackgroundColor = lightGrayColor; // dark gray
const String textFieldFontFamily = 'monospace';
const double textFieldFontSize = 13.0;
const int textFieldMaxLines = 3;
const double textFieldSpacing = 10.0;
Color textFieldTextColor = whiteColor;

// Snackbar
const int snackbarDurationSeconds = 2;


// Sync Icon
const Color syncIconColor = Color(0xFFA1A1A1); 
const double syncIconSize = 40.0;


// Theme Data
ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
  useMaterial3: true,
  scaffoldBackgroundColor: backgroundColor,
  cardColor: cardBackgroundColor,
  dividerColor: dividerColor,
  textTheme: Typography().englishLike,
  inputDecorationTheme: InputDecorationTheme(
    fillColor: textFieldBackgroundColor,
    border: OutlineInputBorder(borderSide: BorderSide(color: textFieldBorderBackgroundColor)),
    hintStyle: const TextStyle(color: placeholderTextColor),
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
