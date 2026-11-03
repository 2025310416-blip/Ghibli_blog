import 'package:flutter/material.dart'; //<-- Importar el Material de flutter

import 'Temas/app_temas.dart'; //<-- Importar la clase de colores 7w7
import '../services/api_service.dart'; //<-- Importar la Conexión con la API

class RegistroScreen extends StatefulWidget {
  //-- Define la pantalla de Registro de usuarios --
  const RegistroScreen({super.key}); //<-- Constructor

  //La pantalla utilizara la clase "_RegistroScreenState" para manejar los datos
  @override
  State<RegistroScreen> createState() => _RegistroScreenState(); //Actualiza la pantalla cuando algo cambia
}

class _RegistroScreenState extends State<RegistroScreen> {
  //----------------VARIABLES DEL FORMULARIO-------------------------//
  final _formKey = GlobalKey<FormState>(); //<-- Valida y controla el formulario

  // Guarda y controla el Texto que escribe el usuario ...
  final _nombreCompletoCtrl = TextEditingController(); //"Nombre Completo"
  final _correoCtrl = TextEditingController(); //"Correo electronico"
  final _usuarioCtrl = TextEditingController(); //"Usuario"
  final _passCtrl = TextEditingController(); //"Contraseña"
  final _confirmarCtrl = TextEditingController(); //"Confirmar contraseña"

  bool _ocultarPass =
      true; //<-- Guarda si la 'Contraseña' esta oculta o visible uwu
  bool _ocultarConfirmar =
      true; //<-- Guarda si la 'Confirmar Contraseña' esta oculta o visible uwu
  bool _aceptaTerminos =
      false; //<-- Inicializa si el usuario 'acepto los terminos' en false
  bool _cargando = false; //<-- Indica si se está enviando el registro a la API

  //LIBERAR ESPACIO DE MEMORIA
  @override
  void dispose() {
    //<-- Libera la memoria cuando la pantalla se cierra O_o
    _nombreCompletoCtrl.dispose(); //<-- Ejecuta el proceso de limpieza
    _correoCtrl.dispose();
    _usuarioCtrl.dispose();
    _passCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
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

  //----------------CREAR CUENTA-------------------------//

  //BOTON 'CREAR CUENTA'
  void _crearCuenta() async {
    //Si algun campo del form es incorrecto, detiene el proceso -_-
    if (!_formKey.currentState!.validate()) return;

    //Verifica si el usuario acepto los 'Terminos y condiciones' owo
    if (!_aceptaTerminos) {
      _mostrarMensaje(
        'Debes aceptar los términos y condiciones',
        esError: true,
      );
      return;
    }

    setState(() => _cargando = true); //<-- Muestra "cargando"

    try {
      //---------------ENVIA LOS DATOS A LA API----------------------//
      final mensaje = await ApiService.registrarUsuario(
        nomCompleto: _nombreCompletoCtrl.text.trim(),
        nomUsr: _usuarioCtrl.text.trim(),
        mail: _correoCtrl.text.trim(),
        pass: _passCtrl.text,
        confirmarPass: _confirmarCtrl.text,
      );

      _mostrarMensaje(mensaje); //<-- Éxito (verde)
    } on ApiException catch (e) {
      _mostrarMensaje(e.mensaje, esError: true); //<-- Error (rojo)
    } finally {
      if (mounted) setState(() => _cargando = false); //<-- Quita "cargando"
    }
  }

  //---------------ENCABAEZADO----------------------//
  //Crea la parte superior de la pantalla
  Widget _encabezado() {
    return Column(
      //<--organiza vertical
      children: [
        //----------------IMAGEN SUPERIOR-----------------//
        Image.asset(
          'assets/images/fondo1.png', //<--Fondo de pantalla superior
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

  //-----------ESTRUCTURA DE LA PANTALLA--------------//
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
                //<-- Agrupa los campos del Formulario
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Crear cuenta', style: AppTextStyles.titulo),
                    const SizedBox(height: 4),
                    Text(
                      'Únete a la comunidad y comparte tu pasión por Studio Ghibli.',
                      style: AppTextStyles.descripcion,
                    ),
                    const SizedBox(height: 24),

                    //----------------CAMPOS DE TEXTO-------------------//

                    // Nombre completo
                    TextFormField(
                      controller: _nombreCompletoCtrl,
                      style: AppTextStyles.campo,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'Nombre completo',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Escribe tu nombre completo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

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
                        final texto = value?.trim() ?? '';
                        if (texto.isEmpty) return 'Escribe tu correo';
                        final valido = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(texto);
                        if (!valido) return 'Escribe un correo válido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Nombre de usuario
                    TextFormField(
                      controller: _usuarioCtrl,
                      style: AppTextStyles.campo,
                      decoration: const InputDecoration(
                        hintText: 'Nombre de usuario',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        final texto = value?.trim() ?? '';
                        if (texto.isEmpty) {
                          return 'Escribe un nombre de usuario';
                        }
                        if (texto.length < 3) return 'Mínimo 3 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    //----------------CONTRASEÑAS----------------------//

                    // Contraseña
                    TextFormField(
                      controller: _passCtrl,
                      style: AppTextStyles.campo,
                      obscureText: _ocultarPass, //<--Ocultar los caracteres de la contraseña
                      decoration: InputDecoration(
                        hintText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        //Permite mostrar u ocultar la contraseña
                        suffixIcon: IconButton(
                          icon: Icon(
                            _ocultarPass
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () =>
                              //--Actualiza la pantalla cuando cambia el estado--
                              setState(() => _ocultarPass = !_ocultarPass),
                        ),
                      ),
                      validator: (value) {
                        //--Revisa que no esté vacía--
                        if (value == null || value.isEmpty) {
                          return 'Escribe una contraseña';
                        }
                        //--Exige mínimo 6 caracteres--
                        if (value.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Confirmar contraseña
                    TextFormField(
                      controller: _confirmarCtrl,
                      style: AppTextStyles.campo,
                      obscureText: _ocultarConfirmar,
                      decoration: InputDecoration(
                        hintText: 'Confirmar contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _ocultarConfirmar
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(
                            () => _ocultarConfirmar = !_ocultarConfirmar,
                          ),
                        ),
                      ),
                      validator: (value) {
                        //--Comprueba que ambas contraseñas sean iguales--
                        if (value != _passCtrl.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    //----------------TERMINOS Y CONDICIONES-------------------------//

                    // Términos y condiciones
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          //<-- Permite aceptar o rechazar terminos
                          value: _aceptaTerminos,
                          onChanged: (valor) => setState(
                            () => _aceptaTerminos = valor ?? false,
                          ), //Guarda el valor seleccionado por el usuario
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text.rich(
                              //<--Permite combinar varios estilos
                              TextSpan(
                                style: AppTextStyles.pequeno,
                                children: [
                                  const TextSpan(text: 'Acepto los '),
                                  TextSpan(
                                    text: 'Términos y condiciones',
                                    style: AppTextStyles.enlace.copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                                  const TextSpan(text: ' y la '),
                                  TextSpan(
                                    text: 'Política de privacidad',
                                    style: AppTextStyles.enlace.copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                                  const TextSpan(text: '.'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    //----------------BOTON Y ENLACE-------------------------//

                    // Botón
                    FilledButton(
                      onPressed: _cargando ? null : _crearCuenta,
                      child: _cargando
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Crear cuenta'),
                    ),
                    const SizedBox(height: 16),

                    // Enlace al login
                    Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '¿Ya tienes cuenta? ',
                            style: AppTextStyles.pequeno,
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).maybePop(),
                            child: Text(
                              'Inicia sesión',
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
