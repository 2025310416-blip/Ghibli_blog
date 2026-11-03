import 'package:flutter/material.dart';

import 'Temas/app_temas.dart'; //<--- Colores y tipografías
import '../config/api_config.dart'; //<--- Dirección de la API
import '../services/api_service.dart'; //<--- Servicio para pedir datos a la API

import 'comentarios_seccion.dart'; //<--- Sección de comentarios reutilizable
import 'perfil_screen.dart'; //<--- Pantalla de Perfil

class PeliculaDetalleScreen extends StatefulWidget {
  final int blogId; //<-- id de la publicación (id_blog) que se tocó en la lista

  const PeliculaDetalleScreen({super.key, required this.blogId});

  @override
  State<PeliculaDetalleScreen> createState() => _PeliculaDetalleScreenState();
}

class _PeliculaDetalleScreenState extends State<PeliculaDetalleScreen> {
  //----------------VARIABLES-------------------------//
  Map<String, dynamic>? _post; //<-- Datos de la película + comentarios
  bool _cargando = true; //<-- Primera carga
  String? _error; //<-- Mensaje si falla la carga

  @override
  void initState() {
    super.initState();
    _cargarPost(); //<-- Pide la película al abrir la pantalla
  }

  //----------------CARGA DE DATOS-------------------------//
  Future<void> _cargarPost({bool mostrarCargando = false}) async {
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
        _post = datos;
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

  //----------------PORTADA-------------------------//
  // Imagen grande arriba con el botón de regresar encima
  Widget _portada(String? img) {
    return SizedBox(
      height: 260,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          (img == null || img.isEmpty)
              ? _imagenVacia()
              : Image.network(
                  '${ApiConfig.baseUrl}/imagenes/$img',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imagenVacia(),
                ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: Material(
              color: Colors.black38,
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagenVacia() {
    return const ColoredBox(
      color: AppColors.borde,
      child: Center(child: Icon(Icons.movie_outlined, size: 48)),
    );
  }

  //----------------DATOS DE LA PELÍCULA-------------------------//
  // Título, fecha, tiempo de lectura y texto
  Widget _datosPelicula(Map<String, dynamic> post) {
    final tiempo = post['tiempo_lectura'];
    final contenido = (post['contenido'] as String?)?.trim() ?? '';
    // Si no hay "contenido" completo, usa la descripción breve
    final texto = contenido.isNotEmpty
        ? contenido
        : ((post['desc'] as String?) ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post['titulo'] ?? '',
          style: AppTextStyles.titulo.copyWith(fontSize: 26),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: AppColors.textoSuave,
            ),
            const SizedBox(width: 6),
            Text(
              _formatearFecha(post['fecha_publicacion']),
              style: AppTextStyles.pequeno,
            ),
          ],
        ),
        if (tiempo != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.schedule, size: 14, color: AppColors.textoSuave),
              const SizedBox(width: 6),
              Text('$tiempo min de lectura', style: AppTextStyles.pequeno),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Text(
          texto,
          style: AppTextStyles.descripcion.copyWith(
            color: AppColors.texto,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // Convierte "2026-10-30" o "2026-10-30T10:15:00" en "30/10/2026"
  String _formatearFecha(String? iso) {
    if (iso == null || iso.length < 10) return '';
    final partes = iso.substring(0, 10).split('-'); // [año, mes, día]
    if (partes.length != 3) return iso;
    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }

  //----------------CUERPO (cargando / error / datos)-------------------------//
  Widget _cuerpo() {
    // 1) Todavía está cargando
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2) Hubo un error y no hay datos
    if (_post == null) {
      return SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error ?? 'No se pudo cargar la película',
                style: AppTextStyles.pequeno,
              ),
              TextButton(
                onPressed: () => _cargarPost(mostrarCargando: true),
                child: const Text('Reintentar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    // 3) Llegaron los datos
    final post = _post!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _portada(post['img'] as String?),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _datosPelicula(post),
                const SizedBox(height: 20),
                const Divider(color: AppColors.borde),
                const SizedBox(height: 20),

                // Comentarios del blog (listar, publicar, editar y eliminar)
                ComentariosSeccion(blogId: widget.blogId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //----------------ESTRUCTURA DE LA PANTALLA-------------------------//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cuerpo(),

      //--- Barra inferior (Películas = índice 1) ---
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (i) {
          if (i == 0) {
            // Inicio: regresa hasta la primera pantalla (Home)
            Navigator.of(context).popUntil((ruta) => ruta.isFirst);
          } else if (i == 1) {
            Navigator.of(context).pop(); //<-- Regresa a la lista de películas
          } else if (i == 3) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PerfilScreen()),
            ); //<-- Abre el perfil
          } else {
            _mostrarMensaje('Próximamente');
          }
        },
        backgroundColor: AppColors.cremaClaro,
        indicatorColor: const Color(0xFFD5E3DC),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie),
            label: 'Películas',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Personajes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
