import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final TextTheme poppinsTheme = TextTheme(
    headline1: GoogleFonts.poppins(
        fontSize: 93, fontWeight: FontWeight.w300, letterSpacing: -1.5),
    headline2: GoogleFonts.poppins(
        fontSize: 58, fontWeight: FontWeight.w300, letterSpacing: -0.5),
    headline3: GoogleFonts.poppins(fontSize: 46, fontWeight: FontWeight.w400),
    headline4: GoogleFonts.poppins(
        fontSize: 33, fontWeight: FontWeight.w400, letterSpacing: 0.25),
    headline5: GoogleFonts.poppins(fontSize: 23, fontWeight: FontWeight.w400),
    headline6: GoogleFonts.poppins(
        fontSize: 19, fontWeight: FontWeight.w500, letterSpacing: 0.15),
    // subtitle1: GoogleFonts.poppins(
    //     fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: 0.15),
    // subtitle2: GoogleFonts.poppins(
    //     fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    // bodyText1: GoogleFonts.poppins(
    //     fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: 0.5),
    // bodyText2: GoogleFonts.poppins(
    //     fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: 0.25),
    // button: GoogleFonts.poppins(
    //     fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 1.25),
    // caption: GoogleFonts.poppins(
    //     fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.4),
    // overline: GoogleFonts.poppins(
    //     fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.5),
  );

  static ThemeData dark() {
    ColorScheme initialScheme = ColorScheme.dark();
    ColorScheme finalScheme = initialScheme.copyWith(
        onSurface: initialScheme.onSurface.withOpacity(.87),
        onBackground: initialScheme.onBackground.withOpacity(.87));
    ThemeData initialData = ThemeData.from(colorScheme: finalScheme);
    ThemeData finalData = initialData.copyWith(
        applyElevationOverlayColor: true,
        textTheme: initialData.textTheme.copyWith(
            headline1: GoogleFonts.poppins(
                fontSize: 93, fontWeight: FontWeight.w300, letterSpacing: -1.5),
            headline2: GoogleFonts.poppins(
                fontSize: 58, fontWeight: FontWeight.w300, letterSpacing: -0.5),
            headline3:
                GoogleFonts.poppins(fontSize: 46, fontWeight: FontWeight.w400),
            headline4: GoogleFonts.poppins(
                fontSize: 33, fontWeight: FontWeight.w400, letterSpacing: 0.25),
            headline5: GoogleFonts.poppins(
                color: finalScheme.onSurface,
                fontSize: 23,
                fontWeight: FontWeight.w400),
            headline6: GoogleFonts.poppins(
                color: finalScheme.onSurface,
                fontSize: 19,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.15),
            caption: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
                color: initialScheme.onSurface.withOpacity(.6))),
        iconTheme: initialData.iconTheme.copyWith(
            color: initialScheme.onSurface.withOpacity(0.87)), // dark theme
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(primary: finalScheme.secondary)),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedLabelStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4)));
    return finalData;
  }

  static ThemeData light() {
    ColorScheme initialScheme = ColorScheme.light();
    ColorScheme finalScheme = initialScheme.copyWith(
        background: Color.alphaBlend(
            initialScheme.primaryVariant.withOpacity(0.05),
            Colors.white), //light theme
        onSurface: initialScheme.onSurface.withOpacity(.87),
        onBackground: initialScheme.onBackground.withOpacity(.87));
    ThemeData initialData = ThemeData.from(colorScheme: finalScheme);
    ThemeData finalData = initialData.copyWith(
        applyElevationOverlayColor: true,
        textTheme: initialData.textTheme.copyWith(
            headline1: GoogleFonts.poppins(
                fontSize: 93, fontWeight: FontWeight.w300, letterSpacing: -1.5),
            headline2: GoogleFonts.poppins(
                fontSize: 58, fontWeight: FontWeight.w300, letterSpacing: -0.5),
            headline3:
                GoogleFonts.poppins(fontSize: 46, fontWeight: FontWeight.w400),
            headline4: GoogleFonts.poppins(
                fontSize: 33, fontWeight: FontWeight.w400, letterSpacing: 0.25),
            headline5: GoogleFonts.poppins(
                color: finalScheme.onSurface,
                fontSize: 23,
                fontWeight: FontWeight.w400),
            headline6: GoogleFonts.poppins(
                color: finalScheme.onSurface,
                fontSize: 19,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.15),
            caption: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
                color: initialScheme.onSurface.withOpacity(.6))),
        iconTheme: initialData.iconTheme.copyWith(
            color: initialScheme.onSurface.withOpacity(0.60)), // light theme
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(primary: finalScheme.secondary)),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedLabelStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4)));
    return finalData;
  }
}

final ColorScheme oldColorScheme = ColorScheme.light(
  primary: Colors.cyan[600],
  secondary: Colors.red[200],
  primaryVariant: Color(0xFF007c91),
  secondaryVariant: Colors.red[100],
  surface: Colors.white,
  background: Colors.white,
  error: Colors.deepOrangeAccent[400],
  onPrimary: Colors.white,
  onSecondary: Colors.white,
  onSurface: Colors.black54,
  onError: Colors.black,
  onBackground: Colors.black54,
  brightness: Brightness.light,
);

// final ThemeData themeData = ThemeData(
//     colorScheme: colorSchemeDark,
//     primaryColor: colorSchemeDark.primary,
//     accentColor: colorSchemeDark.secondary,
//     backgroundColor: colorSchemeDark.background,
//     textButtonTheme: TextButtonThemeData(
//         style: TextButton.styleFrom(primary: colorSchemeDark.secondary)),
//     buttonTheme: ButtonThemeData(
//       textTheme: ButtonTextTheme.accent,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//     ),
//     floatingActionButtonTheme: FloatingActionButtonThemeData(
//       foregroundColor: colorSchemeDark.onSecondary,
//       backgroundColor: colorSchemeDark.secondary,
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
//     ),
//     cardTheme: CardTheme(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//     ),
//     bottomSheetTheme: BottomSheetThemeData(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(16),
//           topRight: Radius.circular(16),
//         ),
//       ),
//     ),
//     // textTheme: textTheme,
//     // primaryTextTheme: textTheme,
//     // accentTextTheme: textTheme,
//     iconTheme: IconThemeData(
//       color: Colors.black54,
//       opacity: 1,
//     ),
//     disabledColor: Colors.black26)
