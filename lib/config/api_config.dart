//DIRECCIÓN DE LA API--
import 'package:flutter/foundation.dart';

class ApiConfig {
  //Direccion de la API
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000'; //<--Chrome -Consulta si esta en el navegador?
    if (defaultTargetPlatform == TargetPlatform.android) {
      //Consulta en que sistema corre la Aplicacion -_-
      return 'http://10.0.2.2:8000'; //<--Emulador en caso de ser Android uwu
    }
    return 'http://127.0.0.1:8000'; //<--Otros emuladores
  }

  //Tiempo máximo de espera antes de avisar que no hay conexion
  static const Duration timeout = Duration(
    seconds: 10,
  ); //<--Tiempo máximo 10 seg
}
