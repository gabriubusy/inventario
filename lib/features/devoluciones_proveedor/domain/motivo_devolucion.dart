/// Why goods go back to the supplier.
enum MotivoDevolucion {
  danado('Vino dañado'),
  vencido('Vencido'),
  noPedido('No era lo pedido'),
  otro('Otro');

  const MotivoDevolucion(this.etiqueta);

  final String etiqueta;
}
