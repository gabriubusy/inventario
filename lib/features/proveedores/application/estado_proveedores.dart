import 'package:inventario/features/proveedores/domain/proveedor.dart';

sealed class EstadoProveedores {
  const EstadoProveedores();
}

class CargandoProveedores extends EstadoProveedores {
  const CargandoProveedores();
}

class ProveedoresCargados extends EstadoProveedores {
  const ProveedoresCargados(this.proveedores);

  final List<Proveedor> proveedores;
}
