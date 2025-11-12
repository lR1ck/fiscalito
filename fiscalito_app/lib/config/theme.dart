import 'package:flutter/material.dart';

/// Configuración de tema para Fiscalito
///
/// Implementa Material Design 3 con dark theme inspirado en Spotify.
/// Diseñado para maximizar puntuación en rúbrica UI (15pts) y UX (10pts).
///
/// Filosofía visual:
/// - Profesional pero accesible
/// - Tecnológico sin intimidar
/// - Información clara en fondo oscuro con acentos vibrantes estratégicos
class AppTheme {
  // =========================================================================
  // PALETA DE COLORES BASE (Dark Theme Spotify-inspired)
  // =========================================================================

  /// Backgrounds
  static const Color backgroundPrimary = Color(0xFF121212); // Negro Spotify
  static const Color surfaceCard = Color(0xFF1E1E1E); // Cards oscuras
  static const Color surfaceElevated = Color(0xFF2A2A2A); // Cards hover/activo

  /// Textos
  static const Color textPrimary = Color(0xFFFFFFFF); // Blanco puro
  static const Color textSecondary = Color(0xFFB3B3B3); // Gris Spotify
  static const Color textDisabled = Color(0xFF535353); // Gris muy oscuro

  // =========================================================================
  // COLORES DE ACCIONES Y ESTADOS
  // =========================================================================

  /// Color hero - Acciones principales (CTAs, botones importantes)
  static const Color primaryMagenta = Color(0xFFFF0051); // Rosa/Magenta vibrante

  /// Confirmaciones y éxito
  static const Color successGreen = Color(0xFF1DB954); // Verde Spotify

  /// Alertas fiscales (SAT)
  static const Color warningOrange = Color(0xFFFFA726); // Naranja alertas

  /// Errores críticos
  static const Color errorRed = Color(0xFFEF5350); // Rojo suave

  /// Información general
  static const Color infoBlue = Color(0xFF42A5F5); // Azul info

  // =========================================================================
  // CONSTANTES DE DIMENSIONES
  // =========================================================================

  /// Padding estándar
  static const double kPaddingScreen = 20.0;
  static const double kPaddingCard = 16.0;
  static const double kPaddingElement = 12.0;
  static const double kPaddingButtonHorizontal = 16.0;
  static const double kPaddingButtonVertical = 14.0;

  /// Border radius
  static const double kBorderRadiusCard = 16.0;
  static const double kBorderRadiusButton = 12.0;
  static const double kBorderRadiusBadge = 20.0;
  static const double kBorderRadiusInput = 12.0;
  static const double kBorderRadiusChatBubble = 20.0;

  /// Elevación (sombras)
  static const double kElevationCard = 4.0;
  static const double kElevationFAB = 6.0;
  static const double kElevationDialog = 8.0;
  static const double kElevationBottomSheet = 16.0;

  /// Tamaños de iconos
  static const double kIconSizeStandard = 24.0;
  static const double kIconSizeButton = 20.0;

  // =========================================================================
  // THEME DATA PRINCIPAL
  // =========================================================================

  /// Retorna el ThemeData principal de la aplicación
  ///
  /// Implementa Material Design 3 con todas las personalizaciones
  /// necesarias para mantener consistencia visual en toda la app.
  static ThemeData get darkTheme {
    return ThemeData(
      // =====================================================================
      // CONFIGURACIÓN GENERAL
      // =====================================================================
      useMaterial3: true,
      brightness: Brightness.dark,

      // =====================================================================
      // COLOR SCHEME
      // =====================================================================
      colorScheme: const ColorScheme.dark(
        // Colores primarios
        primary: primaryMagenta,
        onPrimary: textPrimary,
        primaryContainer: Color(0xFF4A001D), // Versión más oscura del magenta
        onPrimaryContainer: Color(0xFFFFD9E2),

        // Colores secundarios
        secondary: successGreen,
        onSecondary: textPrimary,
        secondaryContainer: Color(0xFF004D1F),
        onSecondaryContainer: Color(0xFFB7FFDB),

        // Colores terciarios (info blue)
        tertiary: infoBlue,
        onTertiary: textPrimary,
        tertiaryContainer: Color(0xFF001D35),
        onTertiaryContainer: Color(0xFFD3E3FF),

        // Errores
        error: errorRed,
        onError: textPrimary,
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),

        // Backgrounds y surfaces
        surface: backgroundPrimary,
        onSurface: textPrimary,
        surfaceContainerHighest: surfaceCard,
        onSurfaceVariant: textSecondary,

        // Outlines y dividers
        outline: textDisabled,
        outlineVariant: Color(0xFF404040),
      ),

      // =====================================================================
      // SCAFFOLD
      // =====================================================================
      scaffoldBackgroundColor: backgroundPrimary,

      // =====================================================================
      // APP BAR
      // =====================================================================
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundPrimary,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        iconTheme: IconThemeData(
          color: textPrimary,
          size: kIconSizeStandard,
        ),
      ),

      // =====================================================================
      // BOTTOM NAVIGATION BAR
      // =====================================================================
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceElevated,
        selectedItemColor: primaryMagenta,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // =====================================================================
      // CARDS
      // =====================================================================
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: kElevationCard,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusCard),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: kPaddingCard,
          vertical: kPaddingElement / 2,
        ),
      ),

      // =====================================================================
      // BOTONES
      // =====================================================================

      // Elevated Button (Primary - Magenta)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryMagenta,
          foregroundColor: textPrimary,
          elevation: 2,
          shadowColor: primaryMagenta.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(
            horizontal: kPaddingButtonHorizontal,
            vertical: kPaddingButtonVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusButton),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryMagenta,
          side: const BorderSide(
            color: primaryMagenta,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: kPaddingButtonHorizontal,
            vertical: kPaddingButtonVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusButton),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryMagenta,
          padding: const EdgeInsets.symmetric(
            horizontal: kPaddingButtonHorizontal,
            vertical: kPaddingButtonVertical,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryMagenta,
        foregroundColor: textPrimary,
        elevation: kElevationFAB,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // =====================================================================
      // INPUT FIELDS (TextField, TextFormField)
      // =====================================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        // Border por defecto
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusInput),
          borderSide: const BorderSide(
            color: textDisabled,
            width: 1,
          ),
        ),

        // Border cuando está enfocado
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusInput),
          borderSide: const BorderSide(
            color: primaryMagenta,
            width: 2,
          ),
        ),

        // Border cuando está deshabilitado
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusInput),
          borderSide: const BorderSide(
            color: textDisabled,
            width: 1,
          ),
        ),

        // Border con error
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusInput),
          borderSide: const BorderSide(
            color: errorRed,
            width: 1,
          ),
        ),

        // Border con error enfocado
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusInput),
          borderSide: const BorderSide(
            color: errorRed,
            width: 2,
          ),
        ),

        // Estilos de texto
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 16,
        ),
        hintStyle: const TextStyle(
          color: textSecondary,
          fontSize: 16,
        ),
        errorStyle: const TextStyle(
          color: errorRed,
          fontSize: 12,
        ),

        // Iconos
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
      ),

      // =====================================================================
      // PROGRESS INDICATORS
      // =====================================================================
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryMagenta,
        circularTrackColor: textDisabled,
        linearTrackColor: surfaceElevated,
      ),

      // =====================================================================
      // DIALOGS
      // =====================================================================
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceCard,
        elevation: kElevationDialog,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusCard),
        ),
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 16,
        ),
      ),

      // =====================================================================
      // BOTTOM SHEETS
      // =====================================================================
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceCard,
        elevation: kElevationBottomSheet,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(kBorderRadiusCard),
          ),
        ),
      ),

      // =====================================================================
      // CHIPS
      // =====================================================================
      chipTheme: ChipThemeData(
        backgroundColor: surfaceElevated,
        selectedColor: primaryMagenta.withOpacity(0.2),
        disabledColor: textDisabled.withOpacity(0.3),
        labelStyle: const TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusBadge),
        ),
        side: const BorderSide(
          color: textDisabled,
          width: 1,
        ),
      ),

      // =====================================================================
      // DIVIDERS
      // =====================================================================
      dividerTheme: const DividerThemeData(
        color: textDisabled,
        thickness: 1,
        space: 1,
      ),

      // =====================================================================
      // SNACKBARS
      // =====================================================================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevated,
        contentTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusButton),
        ),
      ),

      // =====================================================================
      // SWITCH
      // =====================================================================
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return textPrimary;
            }
            return textSecondary;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return primaryMagenta;
            }
            return textDisabled;
          },
        ),
      ),

      // =====================================================================
      // CHECKBOX
      // =====================================================================
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return primaryMagenta;
            }
            return Colors.transparent;
          },
        ),
        checkColor: const WidgetStatePropertyAll<Color>(textPrimary),
        side: const BorderSide(
          color: textDisabled,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // =====================================================================
      // RADIO
      // =====================================================================
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return primaryMagenta;
            }
            return textDisabled;
          },
        ),
      ),

      // =====================================================================
      // TYPOGRAFÍA
      // =====================================================================
      textTheme: const TextTheme(
        // Headers (títulos de pantalla)
        displayLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 0,
        ),
        displaySmall: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 0,
        ),

        // Headlines (títulos de secciones)
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        headlineSmall: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),

        // Titles (títulos de cards)
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),

        // Body (texto principal)
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),

        // Labels (botones, hints)
        labelLarge: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          color: textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),

      // =====================================================================
      // ICON THEME
      // =====================================================================
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: kIconSizeStandard,
      ),
    );
  }

  // =========================================================================
  // MÉTODOS HELPER PARA WIDGETS PERSONALIZADOS
  // =========================================================================

  /// Retorna BoxDecoration para cards estándar
  ///
  /// Usar en Container para crear cards con el estilo consistente de la app.
  static BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: surfaceCard,
      borderRadius: BorderRadius.circular(kBorderRadiusCard),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Retorna BoxDecoration para cards con estado hover/presionado
  static BoxDecoration cardElevatedDecoration() {
    return BoxDecoration(
      color: surfaceElevated,
      borderRadius: BorderRadius.circular(kBorderRadiusCard),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  /// Retorna BoxDecoration para badges de estado
  ///
  /// [color] - Color principal del badge (success, warning, error)
  /// [showBorder] - Si mostrar borde alrededor del badge
  static BoxDecoration badgeDecoration({
    required Color color,
    bool showBorder = true,
  }) {
    return BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(kBorderRadiusBadge),
      border: showBorder
          ? Border.all(color: color, width: 1)
          : null,
    );
  }

  /// Retorna TextStyle para badges de estado
  ///
  /// [color] - Color del texto (debe coincidir con el color del badge)
  static TextStyle badgeTextStyle({required Color color}) {
    return TextStyle(
      color: color,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );
  }

  /// Retorna BoxDecoration para burbujas de chat del usuario
  static BoxDecoration chatUserBubbleDecoration() {
    return BoxDecoration(
      color: primaryMagenta,
      borderRadius: BorderRadius.circular(kBorderRadiusChatBubble),
    );
  }

  /// Retorna BoxDecoration para burbujas de chat de la AI
  static BoxDecoration chatAiBubbleDecoration() {
    return BoxDecoration(
      color: surfaceCard,
      borderRadius: BorderRadius.circular(kBorderRadiusChatBubble),
    );
  }
}
