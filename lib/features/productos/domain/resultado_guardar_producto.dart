import 'package:inventario/features/productos/domain/producto.dart';

sealed class ResultadoGuardarProducto {
  const ResultadoGuardarProducto();
}

class ProductoGuardado extends ResultadoGuardarProducto {
  const ProductoGuardado(this.producto);

  final Producto producto;
}

/// Another product already uses that name (ignoring case and accents).
class NombreRepetido extends ResultadoGuardarProducto {
  const NombreRepetido();
}
