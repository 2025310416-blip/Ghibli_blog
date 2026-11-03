import 'package:flutter/material.dart';

import 'Temas/app_temas.dart'; //<--Importa la clase de colores
import '../services/api_service.dart'; //<--Importa la clase Services de API
import 'registro_screen.dart'; //<--Importa la clase de Registro
import 'home_screen.dart'; //<--Importa la pantalla principal
import '../services/sesion.dart'; //<-- Importa la clase sesion (guarda quién inicio sesión)

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //---------------VARIABLES DEL FORMULARIO-------------------//
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _ocultarPass = true;
  bool _cargando = false;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  //-----------------------MENSAJES-------------------------//
  void _mostrarMensaje(String texto, {bool esError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: esError ? Colors.red.shade700 : AppColors.verde,
      ),
    );
  }

  //----------------INICIO DE SESION-------------------------//
  void _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      final datos = await ApiService.login(
        mail: _correoCtrl.text.trim(),
        pass: _passCtrl.text,
      );

      Sesion.iniciar(
        datos,
      ); //<--Guarda el id_usr y nombre para usarlos en el perfil
      _mostrarMensaje('¡Bienvenido, ${datos['nombre']}!');

      if (!mounted) return; //<-- Verifica que la pantalla siga abierta
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      ); //<---Navega a la pantalla home_screen.dart
    } on ApiException catch (e) {
      _mostrarMensaje(e.mensaje, esError: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  //----------------------ENCABEZADO-------------------------//
  Widget _encabezado() {
    return Column(
      children: [
        Image.asset(
          'assets/images/fondo2.png',
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
        const SizedBox(height: 16),
        Text('Mundo Ghibli', style: AppTextStyles.marca),
        const SizedBox(height: 4),
        Text(
          'Historias, arte y magia en un solo lugar',
          style: AppTextStyles.pequeno,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _encabezado(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Iniciar sesión', style: AppTextStyles.titulo),
                    const SizedBox(height: 4),
                    Text(
                      'Bienvenido de nuevo, ¡qué bueno verte por aquí!',
                      style: AppTextStyles.descripcion,
                    ),
                    const SizedBox(height: 24),

                    //----------------CAMPOS-------------------------//

                    // Correo
                    TextFormField(
                      controller: _correoCtrl,
                      style: AppTextStyles.campo,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Escribe tu correo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Contraseña
                    TextFormField(
                      controller: _passCtrl,
                      style: AppTextStyles.campo,
                      obscureText: _ocultarPass,
                      decoration: InputDecoration(
                        hintText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _ocultarPass
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () =>
                              setState(() => _ocultarPass = !_ocultarPass),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Escribe tu contraseña';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    //----------------BOTÓN Y ENLACE-------------------------//
                    FilledButton(
                      onPressed: _cargando ? null : _iniciarSesion,
                      child: _cargando
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Iniciar sesión'),
                    ),
                    const SizedBox(height: 16),

                    Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '¿No tienes cuenta? ',
                            style: AppTextStyles.pequeno,
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RegistroScreen(), //<---ENLACE A LA CLASE registro_screen.dart
                              ),
                            ),
                            child: Text(
                              'Regístrate',
                              style: AppTextStyles.enlace,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
