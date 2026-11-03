//GUARDA QUIÉN INICIÓ SESIÓN (en memoria mientras la app está abierta)

class Sesion {
  static int? idUsr; //<-- id del usuario (viene del /login de la API)
  static String? nomUsr; //<-- nombre de usuario (viene del /login de la API)

  // ¿Hay alguien con la sesión iniciada?
  static bool get activa => idUsr != null;

  // Se llama justo después de un login correcto
  // "datos" es lo que regresa ApiService.login: {mensaje, id_usr, nombre}
  static void iniciar(Map<String, dynamic> datos) {
    idUsr = datos['id_usr'] as int?;
    nomUsr = datos['nombre'] as String?;
  }

  // Se llama al cerrar sesión
  static void cerrar() {
    idUsr = null;
    nomUsr = null;
  }
}
