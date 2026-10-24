import 'package:inventario/features/productos/domain/producto.dart';

sealed class EstadoExistencias {
  const EstadoExistencias();
}

class CargandoExistencias extends EstadoExistencias {
  const CargandoExistencias();
}

class ExistenciasCargadas extends EstadoExistencias {
  const ExistenciasCargadas(this.productos);

  final List<Producto> productos;
}
