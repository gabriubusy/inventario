import 'package:inventario/features/devoluciones_proveedor/domain/devolucion_proveedor.dart';

sealed class ResultadoDevolucionProveedor {
  const ResultadoDevolucionProveedor();
}

class DevolucionRegistrada extends ResultadoDevolucionProveedor {
  const DevolucionRegistrada(this.devolucion);

  final DevolucionProveedor devolucion;
}

/// The lot holds less than what goes back, or it is gone.
class DevolucionNoAlcanza extends ResultadoDevolucionProveedor {
  const DevolucionNoAlcanza(this.producto);

  final String producto;
}

/// A discount bigger than what is owed on that invoice.
class DevolucionExcedeDeuda extends ResultadoDevolucionProveedor {
  const DevolucionExcedeDeuda({required this.debe});

  /// Dollar hundredths still owed on it.
  final int debe;
}

/// A discount needs an invoice on credit that is still owed.
class DevolucionSinFactura extends ResultadoDevolucionProveedor {
  const DevolucionSinFactura();
}

/// Money back in bolívares needs today's rate.
class DevolucionSinTasa extends ResultadoDevolucionProveedor {
  const DevolucionSinTasa();
}
