//REALIZA LA PETICION AL SERVIDOR
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart'; //Importa la clase Config.dart

// Error con un mensaje listo para mostrarle al usuario
class ApiException implements Exception {
  final String mensaje;
  ApiException(this.mensaje);
}

class ApiService {
  //---------------- 1. REGISTRO DE USUARIO -------------------------//
  static Future<String> registrarUsuario({
    required String nomCompleto,
    required String nomUsr,
    required String mail,
    required String pass,
    required String confirmarPass,
  }) async {
    try {
      final respuesta = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/RegistroUsuario'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'nom_completo': nomCompleto,
              'nom_usr': nomUsr,
              'mail': mail,
              'pass_': pass,
              'confirmar_pass': confirmarPass,
            }),
          )
          .timeout(ApiConfig.timeout);

      final cuerpo = json.decode(utf8.decode(respuesta.bodyBytes));

      // 200 = registro correcto
      if (respuesta.statusCode == 200) {
        return cuerpo['mensaje'] ?? 'Usuario registrado';
      }

      // Cualquier otro código: la API manda el motivo en "detail"
      final detalle = cuerpo['detail'];
      throw ApiException(
        detalle is String ? detalle : 'Revisa los datos ingresados',
      );
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('El servidor tardó demasiado en responder');
    } catch (_) {
      throw ApiException('No se pudo conectar con el servidor');
    }
  }

  //---------------- 2. INICIAR SESIÓN -------------------------//
  static Future<Map<String, dynamic>> login({
    required String mail,
    required String pass,
  }) async {
    try {
      final respuesta = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'mail': mail, 'pass_': pass}),
          )
          .timeout(ApiConfig.timeout);

      final cuerpo = jsonDecode(utf8.decode(respuesta.bodyBytes));

      if (respuesta.statusCode == 200) {
        return cuerpo; // {mensaje, id_usr, nombre}
      }
      throw ApiException(cuerpo['detail'].toString());
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('El servidor tardó demasiado en responder');
    } catch (_) {
      throw ApiException('No se pudo conectar con el servidor');
    }
  }

  // ---------------- 3. GET GENÉRICO ----------------
  // Método privado (por el _) que usan los demás para pedir datos
  static Future<dynamic> _get(String ruta) async {
    try {
      final respuesta = await http
          .get(Uri.parse('${ApiConfig.baseUrl}$ruta'))
          .timeout(ApiConfig.timeout);

      if (respuesta.statusCode == 200) {
        return jsonDecode(utf8.decode(respuesta.bodyBytes));
      }
      throw ApiException('Error del servidor (${respuesta.statusCode})');
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('El servidor tardó demasiado en responder');
    } catch (_) {
      throw ApiException('No se pudo conectar con el servidor');
    }
  }

  // ---------------- 3.1 CATEGORÍAS ----------------
  static Future<List<dynamic>> obtenerCategorias() async {
    return await _get('/categorias') as List<dynamic>;
  }

  // ---------------- 3.2 PUBLICACIONES RECIENTES ----------------
  static Future<List<dynamic>> obtenerPostsRecientes() async {
    return await _get('/posts/recientes') as List<dynamic>;
  }

  // ---------------- 3.3 PELÍCULAS ----------------
  static Future<List<dynamic>> obtenerPeliculas() async {
    return await _get('/peliculas') as List<dynamic>;
  }

  // ---------------- 3.4 DETALLE DE UNA PUBLICACIÓN ----------------
  static Future<Map<String, dynamic>> obtenerPost(int id) async {
    return await _get('/posts/$id') as Map<String, dynamic>;
  }

  // ---------------- 3.5 DATOS DE UN USUARIO ----------------
  static Future<Map<String, dynamic>> obtenerUsuario(int id) async {
    return await _get('/usuarios/$id') as Map<String, dynamic>;
  }

  // ---------------- 4. PUBLICAR COMENTARIO ----------------
  static Future<void> publicarComentario({
    required int usrId,
    required int blogId,
    required String comentario,
  }) async {
    try {
      final respuesta = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/comentarios'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'comentario': comentario,
              'usr_id': usrId,
              'blog_id': blogId,
            }),
          )
          .timeout(ApiConfig.timeout);

      if (respuesta.statusCode == 201) return; //<-- 201 = creado

      final cuerpo = jsonDecode(utf8.decode(respuesta.bodyBytes));
      final detalle = cuerpo['detail'];
      throw ApiException(
        detalle is String ? detalle : 'No se pudo publicar el comentario',
      );
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('El servidor tardó demasiado en responder');
    } catch (_) {
      throw ApiException('No se pudo conectar con el servidor');
    }
  }

  // ---------------- 5. ELIMINAR COMENTARIO ----------------
  static Future<void> eliminarComentario({
    required int idComentario,
    required int usrId,
  }) async {
    try {
      final respuesta = await http
          .delete(
            Uri.parse(
              '${ApiConfig.baseUrl}/comentarios/$idComentario?usr_id=$usrId',
            ),
          )
          .timeout(ApiConfig.timeout);

      if (respuesta.statusCode == 200) return;

      final cuerpo = jsonDecode(utf8.decode(respuesta.bodyBytes));
      final detalle = cuerpo['detail'];
      throw ApiException(
        detalle is String ? detalle : 'No se pudo eliminar el comentario',
      );
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('El servidor tardó demasiado en responder');
    } catch (_) {
      throw ApiException('No se pudo conectar con el servidor');
    }
  }

  // ---------------- 6. EDITAR COMENTARIO ----------------
  static Future<void> editarComentario({
    required int idComentario,
    required int usrId,
    required String comentario,
  }) async {
    try {
      final respuesta = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/comentarios/$idComentario'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'comentario': comentario, 'usr_id': usrId}),
          )
          .timeout(ApiConfig.timeout);

      if (respuesta.statusCode == 200) return;

      final cuerpo = jsonDecode(utf8.decode(respuesta.bodyBytes));
      final detalle = cuerpo['detail'];
      throw ApiException(
        detalle is String ? detalle : 'No se pudo editar el comentario',
      );
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('El servidor tardó demasiado en responder');
    } catch (_) {
      throw ApiException('No se pudo conectar con el servidor');
    }
  }
}
