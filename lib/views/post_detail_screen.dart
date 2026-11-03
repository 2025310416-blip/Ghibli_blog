import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';


class PostDetailScreen extends StatefulWidget {
  final int blogId; //<--1. Recibe el id del blog "blog_id" - ej:blogId=3
  final String baseUrl;

  const PostDetailScreen({
    super.key,
    required this.blogId,
    required this.baseUrl,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  // Simulación del usuario autenticado actual (Ejemplo: Usuario con ID 1)
  final int currentUserId = 1;

  Map<String, dynamic>? _postDetail;
  bool _isLoading = true;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPostDetail(); //<--1. Consulta el post mediante "_fetchPostDetail"
  }

  Future<void> _fetchPostDetail() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/posts/${widget.blogId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _postDetail = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        _showSnackBar('Error al obtener detalle del post');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnackBar('Error de conexión: $e');
      setState(() => _isLoading = false);
    }
  }

  //<-- 3. Agregar comentarios -->
  Future<void> _addComment() async {  //<--- 3.agrega comentarios - realiza http.post(...)
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/comentarios'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'comentario': text,
          'usr_id': currentUserId,
          'blog_id': widget.blogId,
        }),
      );

      if (response.statusCode == 201) {
        _commentController.clear();
        _showSnackBar('Comentario publicado');
        _fetchPostDetail(); // Actualiza los comentarios en pantalla
      } else {
        _showSnackBar('No se pudo publicar el comentario');
      }
    } catch (e) {
      _showSnackBar('Error de envío: $e');
    }
  }

  //<---4. Elimina comentarios --->
  Future<void> _deleteComment(int commentId) async {  //<--4. elimina comentarios - realiza http.delete(...) 
    try {
      final response = await http.delete(
        Uri.parse(
          '${widget.baseUrl}/comentarios/$commentId?usr_id=$currentUserId',
        ),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Comentario eliminado');
        _fetchPostDetail(); // Refrescar lista de comentarios
      } else {
        _showSnackBar('No se pudo eliminar el comentario');
      }
    } catch (e) {
      _showSnackBar('Error al eliminar: $e');
    }
  }

  //<---5. Mostrar Mensajes --->
  void _showSnackBar(String message) {  //<--5. Muestra el comentario publicado o comentario eliminado 
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_postDetail != null ? _postDetail!['titulo'] : 'Detalle'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _postDetail == null
          ? const Center(child: Text('No se pudo cargar la información'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contenido del Post
                  Text(
                    _postDetail!['titulo'] ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _postDetail!['desc'] ?? 'Sin descripción',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Divider(height: 32, thickness: 1),

                  // Sección de Comentarios
                  const Text(
                    'Comentarios',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: _postDetail!['comentarios'].isEmpty
                        ? const Center(child: Text('Aún no hay comentarios.'))
                        : ListView.builder(
                            itemCount: _postDetail!['comentarios'].length,
                            itemBuilder: (context, index) {
                              final item = _postDetail!['comentarios'][index];
                              final bool isMine =
                                  item['usr_id'] == currentUserId;

                              return Card(
                                elevation: 1,
                                child: ListTile(
                                  title: Text(
                                    item['nom_usr'] ?? 'Anónimo',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(item['comentario'] ?? ''),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['fecha'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: isMine
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () =>
                                              _deleteComment(item['id_com']),
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                  ),

                  // Formulario para comentar
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: 'Escribe un comentario...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send),
                          color: Theme.of(context).primaryColor,
                          onPressed: _addComment,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
