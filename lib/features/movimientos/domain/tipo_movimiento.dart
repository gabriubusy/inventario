/// Which kardex filter a movement falls under.
enum GrupoMovimiento { ventas, entradas, perdidas }

/// What moved the stock, whether it came in or went out, and its group.
enum TipoMovimiento {
  venta('Venta', -1, GrupoMovimiento.ventas),
  entrada('Entrada', 1, GrupoMovimiento.entradas),
  devolucionCliente('Devolución', 1, GrupoMovimiento.entradas),
  merma('Merma', -1, GrupoMovimiento.perdidas),
  robo('Robo', -1, GrupoMovimiento.perdidas),
  // A physical count found less, or more, than the system said.
  conteoFalta('Conteo', -1, GrupoMovimiento.perdidas),
  conteoSobra('Conteo', 1, GrupoMovimiento.entradas),
  // Goods taken out over a supplier incident.
  incidencia('Incidencia', -1, GrupoMovimiento.perdidas);

  const TipoMovimiento(this.etiqueta, this.signo, this.grupo);

  final String etiqueta;

  /// +1 when the goods come in, -1 when they go out.
  final int signo;
  final GrupoMovimiento grupo;
}
