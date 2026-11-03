//Material y Paletas de Colores
import 'package:flutter/material.dart'; //<-- Importa herrmaienta del Material Design de Flutter
import 'package:google_fonts/google_fonts.dart'; //<-- Importa fuentes de Google uwu - flutter pub add google_fonts

/*
Guia de colores
verde        --> Botones y bordes
verde oscuro --> Titulos y texto de la barra sup.
crema        --> Fondo de pantalla
crema claro  --> Fondo de los campos de texto
borde        --> Borde de los campos
texto        --> Lo que escribe el usuario
texto suave  --> Descripciones y textos
*/

// Colores de la Aplicacion
class AppColors {
  static const Color verde = Color(0xFF2F6F5E);
  static const Color verdeOscuro = Color(0xFF1F4F42);
  static const Color crema = Color(0xFFF7F2E4);
  static const Color cremaClaro = Color(0xFFFBF8EE);
  static const Color borde = Color(0xFFDDD6C3);
  static const Color texto = Color(0xFF2B3A35);
  static const Color textoSuave = Color(0xFF6B7A74);
}

// Estilos de textos
class AppTextStyles {
  // Nombre de la app: Baloo 2 SemiBold, 28
  static TextStyle get marca => GoogleFonts.baloo2(
    fontSize: 28, //Tamaño
    fontWeight: FontWeight.w600, //SemiBold
    color: AppColors.verdeOscuro, //Color verde oscuro
  );

  // Título del formulario: Poppins SemiBold, 27
  static TextStyle get titulo => GoogleFonts.poppins(
    fontSize: 27,
    fontWeight: FontWeight.w600, //SemiBold
    color: AppColors.verdeOscuro,
  );

  // Descripción: Poppins Regular, 15
  static TextStyle get descripcion => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w400, //Regular - subtitulos
    color: AppColors.textoSuave,
  );

  // Campos de texto: Poppins Regular, 14
  static TextStyle get campo => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400, //Regular - subtitulos
    color: AppColors.texto,
  );

  // Botones: Poppins SemiBold, 15
  static TextStyle get boton =>
      GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600);

  // Enlaces: Poppins Medium, 13
  static TextStyle get enlace => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.verde,
  );

  // Texto pequeño: Poppins Regular, 12
  static TextStyle get pequeno => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textoSuave,
  );
}

//Tema General de la Aplicación
class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.verde)
          .copyWith(primary: AppColors.verde, surface: AppColors.crema),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.crema,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.crema,
        foregroundColor: AppColors.verdeOscuro,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.marca,
      ),

      // Estilo de todos los campos de texto
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cremaClaro,
        hintStyle: AppTextStyles.campo.copyWith(color: AppColors.textoSuave),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.verde, width: 2),
        ),
      ),

      // Estilo de los botones principales
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.verde,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.boton,
        ),
      ),
    );
  }
}
