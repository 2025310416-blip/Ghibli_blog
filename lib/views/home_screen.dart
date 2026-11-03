import 'package:flutter/material.dart';

import 'Temas/app_temas.dart'; //<--- Colores y tipografías
import '../config/api_config.dart'; //<--- Dirección de la API
import '../services/api_service.dart'; //<--- Servicio para pedir datos a la API

import 'peliculas_screen.dart'; //<--- Pantalla de Peliculas
import 'perfil_screen.dart'; //<--- Pantalla deperfil

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //----------------VARIABLES-------------------------//
  int _indiceInferior = 0; //<-- Qué botón de la barra inferior está activo

  late Future<List<dynamic>> _categoriasFuture; //<-- Categorías de la API
  late Future<List<dynamic>> _recientesFuture; //<-- Publicaciones recientes

  // Opciones del menú lateral (las mismas de tu wireframe)
  static const List<_OpcionMenu> _opcionesMenu = [
    _OpcionMenu('Inicio', Icons.home_outlined),
    _OpcionMenu('Películas', Icons.movie_outlined),
    _OpcionMenu('Personajes', Icons.people_outline),
    _OpcionMenu('Música', Icons.music_note_outlined),
    _OpcionMenu('Arte y animación', Icons.brush_outlined),
    _OpcionMenu('Perfil', Icons.person_outline),
  ];

  //----------------CARGA DE DATOS-------------------------//
  void _cargarDatos() {
    _categoriasFuture = ApiService.obtenerCategorias();
    _recientesFuture = ApiService.obtenerPostsRecientes();
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos(); //<-- Pide los datos al abrir la pantalla
  }

  //----------------NAVEGACIÓN-------------------------//
  void _abrirPeliculas() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const PeliculasScreen()));
  }

  //-------------------- PERFIL -------------------------//
  void _abrirPerfil() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const PerfilScreen()));
  }

  //----------------MENÚ LATERAL-------------------------//
  Widget _menuLateral() {
    return Drawer(
      backgroundColor: AppColors.crema,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Logo provisional (luego puedes cambiarlo por tu imagen)
            const Icon(Icons.forest_outlined, size: 64, color: AppColors.verde),
            const SizedBox(height: 12),
            Text(
              'Bienvenido a\nThe Ghibli Nook',
              textAlign: TextAlign.center,
              style: AppTextStyles.marca.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 16),
            const Divider(indent: 24, endIndent: 24, color: AppColors.borde),
            const SizedBox(height: 8),

            // Crea una fila por cada opción de la lista
            for (final opcion in _opcionesMenu)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                child: ListTile(
                  leading: Icon(opcion.icono),
                  title: Text(opcion.nombre, style: AppTextStyles.campo),
                  iconColor: AppColors.verdeOscuro,
                  selected: opcion.nombre == 'Inicio', //<-- Opción activa
                  selectedColor: AppColors.verdeOscuro,
                  selectedTileColor: const Color(0xFFD5E3DC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(); //<-- Cierra el menú
                    if (opcion.nombre == 'Películas') {
                      _abrirPeliculas(); //<-- Abre la pantalla de películas
                    } else if (opcion.nombre == 'Perfil') {
                      _abrirPerfil();
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  //----------------BIENVENIDA-------------------------//
  Widget _bienvenida() {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/fondo1.png', fit: BoxFit.cover),
          // Capa oscura encima de la imagen para que el texto se lea
          const ColoredBox(color: Color(0x59000000)),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenido a\nThe Ghibli Nook',
                  style: AppTextStyles.titulo.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Descubre un mundo de historias, personajes y arte que inspiran.',
                  style: AppTextStyles.pequeno.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //----------------CARGADOR DE SECCIONES-------------------------//
  // Muestra "cargando", el error o los datos, según lo que pase con el Future
  Widget _cargarSeccion(
    Future<List<dynamic>> futuro,
    Widget Function(List<dynamic> datos) construir,
  ) {
    return FutureBuilder<List<dynamic>>(
      future: futuro,
      builder: (context, snapshot) {
        // 1) Todavía está cargando
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        // 2) Hubo un error
        if (snapshot.hasError) {
          final error = snapshot.error;
          final mensaje = error is ApiException
              ? error.mensaje
              : 'Ocurrió un error inesperado';
          return Column(
            children: [
              Text(mensaje, style: AppTextStyles.pequeno),
              TextButton(
                onPressed: () => setState(_cargarDatos), //<-- Vuelve a pedir
                child: const Text('Reintentar'),
              ),
            ],
          );
        }
        // 3) Llegaron los datos
        final datos = snapshot.data ?? [];
        if (datos.isEmpty) {
          return Text('Aún no hay contenido.', style: AppTextStyles.pequeno);
        }
        return construir(datos);
      },
    );
  }

  //----------------CATEGORÍAS-------------------------//
  Widget _categorias() {
    return _cargarSeccion(
      _categoriasFuture,
      (datos) => GridView.builder(
        shrinkWrap: true, //<-- Ocupa solo el espacio que necesita
        physics: const NeverScrollableScrollPhysics(), //<-- Scroll lo maneja la pantalla
        itemCount: datos.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, //<-- 2 columnas
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemBuilder: (_, i) =>
            _tarjetaCategoria(datos[i] as Map<String, dynamic>),
      ),
    );
  }

  Widget _tarjetaCategoria(Map<String, dynamic> cat) {
    final nombre = cat['nombre'] as String;
    return GestureDetector(
      onTap: () {
        if (nombre.toLowerCase().startsWith('pel')) _abrirPeliculas();
      },
      child: Container(
        clipBehavior: Clip.antiAlias, //<-- Recorta la imagen con las esquinas
        decoration: BoxDecoration(
          color: AppColors.cremaClaro,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borde),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.asset(
                // Arma la ruta con el nombre: "Peliculas" -> peliculas.png
                'assets/images/categorias/peliculas.png',
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: AppColors.borde,
                  child: Center(child: Icon(Icons.image_outlined)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                nombre,
                style: AppTextStyles.campo.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //----------------PUBLICACIONES RECIENTES-------------------------//
  Widget _recientes() {
    return _cargarSeccion(
      _recientesFuture,
      (datos) => Column(
        children: [
          for (final post in datos) _tarjetaPost(post as Map<String, dynamic>),
        ],
      ),
    );
  }

  Widget _tarjetaPost(Map<String, dynamic> post) {
    final img = post['img'] as String?;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.cremaClaro,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borde),
      ),
      child: Row(
        children: [
          // Imagen a la izquierda (viene de la carpeta /imagenes de la API)
          SizedBox(
            width: 110,
            height: 110,
            child: (img == null || img.isEmpty)
                ? _imagenVacia()
                : Image.network(
                    '${ApiConfig.baseUrl}/imagenes/$img',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagenVacia(),
                  ),
          ),
          // Texto a la derecha
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Etiqueta de categoría
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD5E3DC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          post['categoria'] ?? '',
                          style: AppTextStyles.pequeno.copyWith(
                            fontSize: 11,
                            color: AppColors.verdeOscuro,
                          ),
                        ),
                      ),
                      Text(
                        _formatearFecha(post['fecha']),
                        style: AppTextStyles.pequeno.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    post['titulo'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.campo.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    post['desc'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.pequeno,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Cuadro gris cuando la publicación no tiene imagen
  Widget _imagenVacia() {
    return const ColoredBox(
      color: AppColors.borde,
      child: Center(child: Icon(Icons.image_outlined)),
    );
  }

  // Convierte "2026-10-30" en "30/10/2026"
  String _formatearFecha(String? iso) {
    if (iso == null) return '';
    final partes = iso.split('-'); // [año, mes, día]
    if (partes.length != 3) return iso;
    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }

  //----------------ESTRUCTURA DE LA PANTALLA-------------------------//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //--- Barra superior (el ícono de hamburguesa aparece solo por el drawer) ---
      appBar: AppBar(
        title: const Text('The Ghibli Nook'),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),

      //--- Menú lateral ---
      drawer: _menuLateral(),

      //--- Contenido ---
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bienvenida(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explora por categorías',
                    style: AppTextStyles.titulo.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  _categorias(), //<-- Cuadrícula de categorías

                  const SizedBox(height: 24),
                  Text(
                    'Publicaciones recientes',
                    style: AppTextStyles.titulo.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  _recientes(), //<-- Lista de publicaciones
                ],
              ),
            ),
          ],
        ),
      ),

      //--- Barra inferior ---
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceInferior,
        onDestinationSelected: (i) {
          if (i == 1) {
            _abrirPeliculas(); //<--Botón Peliculas
          } else if (i == 3) {
            _abrirPerfil();
          } else {
            setState(() => _indiceInferior = i);
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

// Guarda el nombre y el ícono de cada opción del menú
class _OpcionMenu {
  final String nombre;
  final IconData icono;
  const _OpcionMenu(this.nombre, this.icono);
}
