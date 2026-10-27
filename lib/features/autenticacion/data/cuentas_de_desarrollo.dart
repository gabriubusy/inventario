import 'package:inventario/features/autenticacion/data/repositorio_autenticacion_en_memoria.dart';
import 'package:inventario/features/autenticacion/domain/pin.dart';
import 'package:inventario/features/autenticacion/domain/usuario.dart';

// The single user, and the PIN that opens the app until it is changed.
final CuentaEnMemoria cuentaDeDesarrollo = (
  usuario: const Usuario(id: '1', nombre: 'Administrador'),
  pin: Pin.tryParse('1234')!,
);
