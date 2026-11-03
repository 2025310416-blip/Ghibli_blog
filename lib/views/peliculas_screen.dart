import 'package:flutter/material.dart';

import 'Temas/app_temas.dart'; //<--- Colores y tipografías
import '../config/api_config.dart'; //<--- Dirección de la API
import '../services/api_service.dart'; //<--- Servicio para pedir datos a la API
import 'pelicula_detalle_screen.dart'; //<--- Detalle de la película
import 'perfil_screen.dart'; //<--- Importa el Perfil

class PeliculasScreen extends StatefulWidget {
  const PeliculasScreen({super.key});

  @override
  State<PeliculasScreen> createState() => _PeliculasScreenState();
}

class _PeliculasScreenState extends State<PeliculasScreen> {
  //----------------VARIABLES-------------------------//
  late Future<List<dynamic>> _peliculasFuture; //<-- Películas que manda la API
  String _temaSeleccionado = 'Todas'; //<-- Chip activo

  //----------------CARGA DE DATOS-------------------------//
  void _cargarDatos() {
    _peliculasFuture = ApiService.obtenerPeliculas();
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos(); //<-- Pide las películas al abrir la pantalla
  }

  //----------------CHIPS DE TEMA-------------------------//
  // Los chips salen de los distintos "tema" que existan en las películas
  Widget _chipsTema(List<String> temas) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: temas.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final tema = temas[i];
          final activo = tema == _temaSeleccionado;
          return ChoiceChip(
            label: Text(
              tema,
              style: AppTextStyles.pequeno.copyWith(
                fontSize: 13,
                color: activo ? Colors.white : AppColors.verdeOscuro,
              ),
            ),
            selected: activo,
            showCheckmark: false,
            selectedColor: AppColors.verde,
            backgroundColor: const Color(0xFFD5E3DC),
            side: BorderSide.none,
            shape: const StadiumBorder(),
            onSelected: (_) => setState(() => _temaSeleccionado = tema),
          );
        },
      ),
    );
  }

  //----------------TARJETA DE PELÍCULA-------------------------//
  // Imagen a la izquierda | Título, fecha, tema y tags | Flecha
  Widget _tarjetaPelicula(Map<String, dynamic> peli) {
    final img = peli['img'] as String?;
    final tema = (peli['tema'] as String?) ?? '';
    final tags = _formatearTags(peli['tags']);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PeliculaDetalleScreen(blogId: peli['id_blog']),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.cremaClaro,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borde),
        ),
        child: Row(
          children: [
            // Imagen (viene de la carpeta /imagenes de la API)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 84,
                height: 96,
                child: (img == null || img.isEmpty)
                    ? _imagenVacia()
                    : Image.network(
                        '${ApiConfig.baseUrl}/imagenes/$img',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagenVacia(),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Nombre, fecha, tema y tags
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    peli['titulo'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.campo.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatearFecha(peli['fecha']),
                    style: AppTextStyles.pequeno.copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  // Descripción breve
                  Text(
                    peli['desc'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.pequeno,
                  ),
                  const SizedBox(height: 4),
                  // "Fantasía · #magia  #bosque"
                  if (tema.isNotEmpty || tags.isNotEmpty)
                    Text.rich(
                      TextSpan(
                        style: AppTextStyles.pequeno,
                        children: [
                          if (tema.isNotEmpty)
                            TextSpan(
                              text: tema,
                              style: AppTextStyles.pequeno.copyWith(
                                color: AppColors.verdeOscuro,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (tema.isNotEmpty && tags.isNotEmpty)
                            const TextSpan(text: ' · '),
                          if (tags.isNotEmpty) TextSpan(text: tags),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Flecha a la derecha
            const Icon(Icons.chevron_right, color: AppColors.textoSuave),
          ],
        ),
      ),
    );
  }

  // Cuadro gris cuando la película no tiene imagen
  Widget _imagenVacia() {
    return const ColoredBox(
      color: AppColors.borde,
      child: Center(child: Icon(Icons.movie_outlined)),
    );
  }

  // Convierte "fantasía, aventura" en "#fantasía  #aventura"
  String _formatearTags(String? tags) {
    if (tags == null || tags.trim().isEmpty) return '';
    return tags
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .map((t) => '#$t')
        .join('  ');
  }

  // Convierte "2026-10-30" en "30/10/2026"
  String _formatearFecha(String? iso) {
    if (iso == null) return '';
    final partes = iso.split('-'); // [año, mes, día]
    if (partes.length != 3) return iso;
    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }

  //----------------CONTENIDO (cargando / error / datos)-------------------------//
  Widget _contenido() {
    return FutureBuilder<List<dynamic>>(
      future: _peliculasFuture,
      builder: (context, snapshot) {
        // 1) Todavía está cargando
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2) Hubo un error
        if (snapshot.hasError) {
          final error = snapshot.error;
          final mensaje = error is ApiException
              ? error.mensaje
              : 'Ocurrió un error inesperado';
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(mensaje, style: AppTextStyles.pequeno),
                TextButton(
                  onPressed: () => setState(_cargarDatos), //<-- Vuelve a pedir
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        // 3) Llegaron los datos
        final todas = snapshot.data ?? [];
        if (todas.isEmpty) {
          return Center(
            child: Text('Aún no hay películas.', style: AppTextStyles.pequeno),
          );
        }

        // Temas distintos que existen en las películas
        final temas = <String>['Todas'];
        for (final p in todas) {
          final t = p['tema'] as String?;
          if (t != null && t.isNotEmpty && !temas.contains(t)) temas.add(t);
        }

        // Filtra según el chip seleccionado
        final visibles = _temaSeleccionado == 'Todas'
            ? todas
            : todas.where((p) => p['tema'] == _temaSeleccionado).toList();

        return Column(
          children: [
            const SizedBox(height: 4),
            _chipsTema(temas),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(_cargarDatos);
                  try {
                    await _peliculasFuture;
                  } catch (_) {} //<-- El error ya se muestra en pantalla
                },
                child: visibles.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 48),
                          Center(
                            child: Text(
                              'No hay películas con este tema.',
                              style: AppTextStyles.pequeno,
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                        itemCount: visibles.length,
                        itemBuilder: (_, i) => _tarjetaPelicula(
                          visibles[i] as Map<String, dynamic>,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  //----------------ESTRUCTURA DE LA PANTALLA-------------------------//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //--- Barra superior: hoja + título | buscar ---
      appBar: AppBar(
        centerTitle: false,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco_outlined, color: AppColors.verde),
            SizedBox(width: 8),
            Text('Películas'),
          ],
        ),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),

      //--- Contenido ---
      body: _contenido(),

      //--- Barra inferior (Películas = índice 1) ---
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (i) {
          if (i == 0) {
            Navigator.of(context).pop(); //<-- Regresa a Inicio
          } else if (i == 3) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PerfilScreen()),
            ); //<-- Abre el perfil
          } else if (i == 2) {
            // Personajes: aún no existe esa pantalla
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Próximamente')));
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
