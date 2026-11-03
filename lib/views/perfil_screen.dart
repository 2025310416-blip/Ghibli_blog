import 'package:flutter/material.dart';

import 'Temas/app_temas.dart'; //<--- Colores y tipografías
import '../services/api_service.dart'; //<--- Servicio para pedir datos a la API
import '../services/sesion.dart'; //<--- Quién inició sesión

import 'login_screen.dart'; //<--- Para volver al inicio de sesión
import 'peliculas_screen.dart'; //<--- Pantalla de Peliculas

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  //----------------CONSTANTES (cambia aquí tus imágenes)-------------------------//
  static const String _imgBanner =
      'assets/images/fondo1.png'; //<-- Banner superior
  static const String _imgAvatar =
      'assets/images/perfil/avatar.png'; //<-- Foto de perfil
  static const Color _verdeClaro = Color(
    0xFFD5E3DC,
  ); //<-- Mismo verde de tus chips
  static const Color _rosa = Color(0xFFC99A9A); //<-- Botón "Cerrar sesión"

  //----------------VARIABLES-------------------------//
  late Future<Map<String, dynamic>> _usuarioFuture; //<-- Datos del usuario

  //----------------CARGA DE DATOS-------------------------//
  void _cargarDatos() {
    final id = Sesion.idUsr;
    if (id == null) {
      // No hay sesión: genera un error con mensaje claro
      _usuarioFuture = Future.error(ApiException('No hay una sesión activa'));
    } else {
      _usuarioFuture = ApiService.obtenerUsuario(id);
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos(); //<-- Pide los datos al abrir la pantalla
  }

  //----------------CERRAR SESIÓN-------------------------//
  Future<void> _confirmarCerrarSesion() async {
    // Muestra el panel inferior y espera: true = cerrar, false/null = cancelar
    final confirmar = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.crema,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _panelCerrarSesion(),
    );

    if (confirmar != true || !mounted) return;

    Sesion.cerrar(); //<-- Borra los datos de la sesión
    // Va al login y elimina todas las pantallas anteriores
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Widget _panelCerrarSesion() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min, //<-- Solo ocupa lo necesario
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _verdeClaro,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.logout, color: AppColors.verdeOscuro),
            ),
            const SizedBox(height: 12),
            Text(
              '¿Cerrar sesión?',
              style: AppTextStyles.titulo.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text('Vas a salir de tu cuenta.', style: AppTextStyles.pequeno),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Cerrar sesión'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: const StadiumBorder(),
                foregroundColor: AppColors.verde,
                side: const BorderSide(color: AppColors.verde),
                textStyle: AppTextStyles.boton,
              ),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  //----------------ENCABEZADO (banner + foto)-------------------------//
  Widget _encabezado() {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none, //<-- Deja que la foto sobresalga del banner
      children: [
        // Banner
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 130,
            width: double.infinity,
            child: Image.asset(
              _imgBanner,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: _verdeClaro),
            ),
          ),
        ),
        // Foto de perfil (mitad sobre el banner, mitad abajo)
        Positioned(
          bottom: -48,
          child: Container(
            width: 96,
            height: 96,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _verdeClaro,
              border: Border.all(color: AppColors.crema, width: 4),
            ),
            child: Image.asset(
              _imgAvatar,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.person, size: 48, color: AppColors.verde),
            ),
          ),
        ),
      ],
    );
  }

  //----------------DATOS DEL USUARIO-------------------------//
  Widget _contenido(Map<String, dynamic> usuario) {
    final nomUsr = (usuario['nom_usr'] ?? '') as String;
    final nomCompleto = (usuario['nom_completo'] as String?)?.trim();
    // Si no tiene nombre completo, muestra su usuario
    final nombre = (nomCompleto == null || nomCompleto.isEmpty)
        ? nomUsr
        : nomCompleto;

    return Column(
      children: [
        _encabezado(),
        const SizedBox(height: 60), //<-- Espacio para la mitad de la foto
        Text(
          nombre,
          textAlign: TextAlign.center,
          style: AppTextStyles.titulo.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 2),
        Text('@$nomUsr', style: AppTextStyles.descripcion),
        const SizedBox(height: 24),

        // Tarjeta con los datos
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.cremaClaro,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borde),
          ),
          child: Column(
            children: [
              _filaDato(Icons.person_outline, 'Nombre', nombre),
              const Divider(height: 1, color: AppColors.borde),
              _filaDato(Icons.alternate_email, 'Usuario', '@$nomUsr'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Botón cerrar sesión
        FilledButton.icon(
          onPressed: _confirmarCerrarSesion,
          style: FilledButton.styleFrom(backgroundColor: _rosa),
          icon: const Icon(Icons.logout, size: 20),
          label: const Text('Cerrar sesión'),
        ),
      ],
    );
  }

  // Una fila de la tarjeta: ícono + etiqueta pequeña + valor
  Widget _filaDato(IconData icono, String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icono, color: AppColors.textoSuave),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(etiqueta, style: AppTextStyles.pequeno),
                Text(
                  valor,
                  style: AppTextStyles.campo.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
      //--- Barra superior: hoja + "Perfil" ---
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.eco, color: AppColors.verde),
            const SizedBox(width: 8),
            Text('Perfil', style: AppTextStyles.marca.copyWith(fontSize: 24)),
          ],
        ),
      ),

      //--- Contenido ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _usuarioFuture,
          builder: (context, snapshot) {
            // 1) Todavía está cargando
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            // 2) Hubo un error
            if (snapshot.hasError) {
              final error = snapshot.error;
              final mensaje = error is ApiException
                  ? error.mensaje
                  : 'Ocurrió un error inesperado';
              return Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Column(
                  children: [
                    Text(mensaje, style: AppTextStyles.descripcion),
                    TextButton(
                      onPressed: () =>
                          setState(_cargarDatos), //<-- Vuelve a pedir
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            // 3) Llegaron los datos
            return _contenido(snapshot.data!);
          },
        ),
      ),

      //--- Barra inferior (Perfil activo) ---
      bottomNavigationBar: NavigationBar(
        selectedIndex: 3,
        onDestinationSelected: (i) {
          final nav = Navigator.of(context);
          if (i == 0) {
            nav.popUntil((ruta) => ruta.isFirst); //<-- Regresa al Inicio
          } else if (i == 1) {
            // Vuelve al Inicio y desde ahí abre Películas (sin apilar de más)
            nav.popUntil((ruta) => ruta.isFirst);
            nav.push(
              MaterialPageRoute(builder: (_) => const PeliculasScreen()),
            );
          } else if (i == 2) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Próximamente')));
          }
        },
        backgroundColor: AppColors.cremaClaro,
        indicatorColor: _verdeClaro,
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
