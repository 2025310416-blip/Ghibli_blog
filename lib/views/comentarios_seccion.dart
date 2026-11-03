import 'package:flutter/material.dart';

import 'Temas/app_temas.dart'; //<--- Colores y tipografías
import '../services/api_service.dart'; //<--- Servicio para pedir datos a la API
import '../services/sesion.dart'; //<--- Quién inició sesión

// SECCIÓN DE COMENTARIOS REUTILIZABLE
// Se coloca en cualquier detalle de publicación con una sola línea:
//   ComentariosSeccion(blogId: 3)
// Ella sola lista, publica, edita y elimina los comentarios de ese blog.
class ComentariosSeccion extends StatefulWidget {
  final int blogId; //<-- id de la publicación (id_blog)

  const ComentariosSeccion({super.key, required this.blogId});

  @override
  State<ComentariosSeccion> createState() => _ComentariosSeccionState();
}

class _ComentariosSeccionState extends State<ComentariosSeccion> {
  //----------------VARIABLES-------------------------//
  List<dynamic> _comentarios = []; //<-- Comentarios del blog
  bool _cargando = true; //<-- Primera carga
  String? _error; //<-- Mensaje si falla la carga
  bool _publicando = false; //<-- Enviando un comentario

  final _comentarioCtrl = TextEditingController();

  // Id del usuario que inició sesión (lo guarda Sesion.iniciar en el login)
  int get _usuarioActualId => Sesion.idUsr ?? -1;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  //----------------CARGA DE DATOS-------------------------//
  Future<void> _cargar({bool mostrarCargando = false}) async {
    if (mostrarCargando) {
      setState(() {
        _cargando = true;
        _error = null;
      });
    }
    try {
      final datos = await ApiService.obtenerPost(widget.blogId);
      if (!mounted) return;
      setState(() {
        _comentarios = (datos['comentarios'] as List<dynamic>?) ?? [];
        _cargando = false;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.mensaje;
        _cargando = false;
      });
    }
  }

  //----------------MENSAJES-------------------------//
  void _mostrarMensaje(String texto, {bool esError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: esError ? Colors.red.shade700 : AppColors.verde,
      ),
    );
  }

  //----------------CRUD DE COMENTARIOS-------------------------//
  // CREAR
  Future<void> _publicar() async {
    final texto = _comentarioCtrl.text.trim();
    if (texto.isEmpty) {
      _mostrarMensaje('Escribe un comentario', esError: true);
      return;
    }

    setState(() => _publicando = true);
    try {
      await ApiService.publicarComentario(
        usrId: _usuarioActualId,
        blogId: widget.blogId,
        comentario: texto,
      );
      _comentarioCtrl.clear();
      _mostrarMensaje('Comentario publicado');
      await _cargar(); //<-- Actualiza la lista de opiniones
    } on ApiException catch (e) {
      _mostrarMensaje(e.mensaje, esError: true);
    } finally {
      if (mounted) setState(() => _publicando = false);
    }
  }

  // ACTUALIZAR
  Future<void> _editar(int idComentario, String textoActual) async {
    // Ventana con el texto actual para modificarlo
    final nuevo = await showDialog<String>(
      context: context,
      builder: (_) => _DialogoEditar(textoActual: textoActual),
    );

    // Canceló o no cambió nada: no hace nada
    if (nuevo == null || nuevo == textoActual) return;

    if (nuevo.isEmpty) {
      _mostrarMensaje('El comentario no puede estar vacío', esError: true);
      return;
    }

    try {
      await ApiService.editarComentario(
        idComentario: idComentario,
        usrId: _usuarioActualId,
        comentario: nuevo,
      );
      _mostrarMensaje('Comentario actualizado');
      await _cargar();
    } on ApiException catch (e) {
      _mostrarMensaje(e.mensaje, esError: true);
    }
  }

  // ELIMINAR
  Future<void> _eliminar(int idComentario) async {
    try {
      await ApiService.eliminarComentario(
        idComentario: idComentario,
        usrId: _usuarioActualId,
      );
      _mostrarMensaje('Comentario eliminado');
      await _cargar();
    } on ApiException catch (e) {
      _mostrarMensaje(e.mensaje, esError: true);
    }
  }

  //----------------ENCABEZADO Y FORMULARIO-------------------------//
  Widget _encabezado() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFD5E3DC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.chat_bubble_outline, color: AppColors.verde),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Comentarios',
                style: AppTextStyles.titulo.copyWith(fontSize: 20),
              ),
              Text(
                'Comparte tu opinión sobre esta publicación',
                style: AppTextStyles.pequeno,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _formulario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: _comentarioCtrl,
          style: AppTextStyles.campo,
          minLines: 1,
          maxLines: 4,
          maxLength: 500, //<-- Igual que el límite de la columna en la BD
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Escribe un comentario...',
            counterText: '', //<-- Oculta el contador de caracteres
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(130, 44)),
          onPressed: _publicando ? null : _publicar,
          child: _publicando
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Publicar'),
        ),
      ],
    );
  }

  //----------------LISTA (LEER)-------------------------//
  Widget _lista() {
    // 1) Todavía está cargando
    if (_cargando) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // 2) Hubo un error y no hay datos
    if (_error != null && _comentarios.isEmpty) {
      return Column(
        children: [
          Text(_error!, style: AppTextStyles.pequeno),
          TextButton(
            onPressed: () => _cargar(mostrarCargando: true),
            child: const Text('Reintentar'),
          ),
        ],
      );
    }

    // 3) No hay comentarios
    if (_comentarios.isEmpty) {
      return Text(
        'Aún no hay opiniones. ¡Sé el primero en comentar!',
        style: AppTextStyles.pequeno,
      );
    }

    // 4) Lista de comentarios
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.cremaClaro,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borde),
      ),
      child: Column(
        children: [
          for (var i = 0; i < _comentarios.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.borde),
            _tarjetaComentario(_comentarios[i] as Map<String, dynamic>),
          ],
        ],
      ),
    );
  }

  // Avatar | Usuario, correo y fecha, comentario | Editar y eliminar (solo si es tuyo)
  Widget _tarjetaComentario(Map<String, dynamic> c) {
    final nombre = (c['nom_usr'] as String?) ?? 'Usuario';
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
    final mail = (c['mail'] as String?) ?? '';
    final esMio = c['usr_id'] == _usuarioActualId;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFD5E3DC),
            child: Text(
              inicial,
              style: AppTextStyles.campo.copyWith(
                color: AppColors.verdeOscuro,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: AppTextStyles.campo.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: 10,
                  children: [
                    if (mail.isNotEmpty)
                      Text(
                        mail,
                        style: AppTextStyles.pequeno.copyWith(fontSize: 11),
                      ),
                    Text(
                      _formatearFecha(c['fecha']),
                      style: AppTextStyles.pequeno.copyWith(fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(c['comentario'] ?? '', style: AppTextStyles.campo),
              ],
            ),
          ),
          if (esMio)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.edit_outlined, color: AppColors.verde),
                  onPressed: () => _editar(c['id_com'], c['comentario'] ?? ''),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                  onPressed: () => _eliminar(c['id_com']),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Convierte "2026-10-30" o "2026-10-30T10:15:00" en "30/10/2026"
  String _formatearFecha(String? iso) {
    if (iso == null || iso.length < 10) return '';
    final partes = iso.substring(0, 10).split('-'); // [año, mes, día]
    if (partes.length != 3) return iso;
    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }

  //----------------ESTRUCTURA-------------------------//
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _encabezado(),
        const SizedBox(height: 16),
        _formulario(),
        const SizedBox(height: 24),
        Text(
          'Opiniones de la comunidad',
          style: AppTextStyles.campo.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _lista(),
      ],
    );
  }
}

// Ventana para editar: tiene su propio controlador para liberarlo bien
class _DialogoEditar extends StatefulWidget {
  final String textoActual;
  const _DialogoEditar({required this.textoActual});

  @override
  State<_DialogoEditar> createState() => _DialogoEditarState();
}

class _DialogoEditarState extends State<_DialogoEditar> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.textoActual);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.crema,
      title: Text(
        'Editar comentario',
        style: AppTextStyles.titulo.copyWith(fontSize: 18),
      ),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        style: AppTextStyles.campo,
        minLines: 1,
        maxLines: 4,
        maxLength: 500,
        textCapitalization: TextCapitalization.sentences,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(110, 44)),
          onPressed: () => Navigator.of(context).pop(_ctrl.text.trim()),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
