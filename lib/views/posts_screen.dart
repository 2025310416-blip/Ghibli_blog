import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import 'post_detail_screen.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  // Ajusta esta URL según tu entorno (10.0.2.2 para emulador Android, 127.0.0.1 para Web)
  final String baseUrl =
      "http://127.0.0.1:8000"; //<--- Define la dirección de la API (Web owo)

  List<dynamic> _posts = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override //<--- Carga los posts
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts'),
      ); //<--- Consume los POSTS (Se guarda en "_posts")

      //<-- Mensajes de POSTS uwo -->
      if (response.statusCode == 200) {
        //<---Cargo bien uwu!!
        setState(() {
          _posts = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Error al cargar posts (${response.statusCode})'; //<---Error carga de posts :(
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión. Revisa CORS/URL base: $e'; //<---Error de conexion URL :(
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts del Blog'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchPosts),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _fetchPosts,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              //<--- Muestra los POSTS ---> Flutter crea un lista visual uwo
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${post['id_blog']}')),
                    title: Text(
                      post['titulo'] ?? 'Sin título',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      post['desc'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        //<--- Cuando el usuario toca un POST --->
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailScreen(
                            blogId: post['id_blog'], //<-- envía blogId al siguiente archivo
                            baseUrl: baseUrl,
                          ),
                        ),
                      ).then((_) => _fetchPosts()); // Recargar al volver
                    },
                  ),
                );
              },
            ),
    );
  }
}
