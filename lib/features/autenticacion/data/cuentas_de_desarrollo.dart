import 'package:inventario/features/autenticacion/data/repositorio_autenticacion_en_memoria.dart';
import 'package:inventario/features/autenticacion/domain/pin.dart';
import 'package:inventario/features/autenticacion/domain/usuario.dart';

// Development-only account; remove once the PIN is stored in the database.
final CuentaEnMemoria cuentaDeDesarrollo = (
  usuario: const Usuario(id: '1', nombre: 'Administrador'),
  pin: Pin.tryParse('1234')!,
);
