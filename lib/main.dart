import 'package:flutter/material.dart'; //importa herramientras de flutter

import 'views/posts_screen.dart'; //importa la clase Postscreen
import 'views/login_screen.dart'; //importa la clase de inicio de sesion
import 'views/Temas/app_temas.dart'; //importa la clase de Temas de Colroes 7w7
import 'views/registro_screen.dart';

void main() {
  //<-- Flutter comienza aqui uwu
  runApp(const MyApp()); //<--Inicia la app
}

class MyApp extends StatelessWidget {
  //<-- Configura la app
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ghibli Nook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      //home: const PostsScreen(), //<--- Indica cuál el objeto de la clase  postscreen.dart
      home: const LoginScreen(), //<---Importar el objeto de la clase  "inicio_screen.dart"
    );
  }
}
