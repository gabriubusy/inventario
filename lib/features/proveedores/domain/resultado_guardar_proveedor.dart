import 'package:inventario/features/proveedores/domain/proveedor.dart';

sealed class ResultadoGuardarProveedor {
  const ResultadoGuardarProveedor();
}

class ProveedorGuardado extends ResultadoGuardarProveedor {
  const ProveedorGuardado(this.proveedor);

  final Proveedor proveedor;
}

/// Another supplier already uses that name (ignoring case and accents).
class NombreProveedorRepetido extends ResultadoGuardarProveedor {
  const NombreProveedorRepetido();
}
