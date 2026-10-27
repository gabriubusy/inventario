import 'package:inventario/features/conteo/domain/conteo_lote.dart';
import 'package:inventario/features/incidencias/domain/sacar_de_lote.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

/// Counted minus recorded, for pieces and quantity: negative means
/// something is missing.
typedef DiferenciaConteo = ({int piezas, int cantidad});

DiferenciaConteo diferenciaConteo(LoteMarca lote, ConteoLote conteo) => (
  piezas: (conteo.piezas ?? lote.piezas) - lote.piezas,
  cantidad: conteo.cantidad - lote.cantidad,
);

bool hayDiferencia(DiferenciaConteo diferencia) =>
    diferencia.piezas != 0 || diferencia.cantidad != 0;

/// The product with that lot set to what was counted; null when the lot is
/// gone. An open piece stays open while some weight is left.
Producto? aplicarConteo(Producto producto, ConteoLote conteo) {
  final indice = indiceLote(producto, conteo.marca, conteo.proveedor);
  if (indice == -1) return null;
  return producto.copyWith(
    lotes: [
      for (final (i, lote) in producto.lotes.indexed)
        i == indice
            ? lote.copyWith(
                piezas: conteo.piezas ?? lote.piezas,
                piezaAbierta: lote.piezaAbierta && conteo.cantidad > 0,
                cantidad: conteo.cantidad,
              )
            : lote,
    ],
  );
}
