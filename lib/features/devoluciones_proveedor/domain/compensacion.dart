/// How the supplier makes up for goods sent back.
enum Compensacion {
  descuento('Descuenta', 'Baja lo que se le debe'),
  dinero('Devuelve dinero', 'Entra a la caja'),
  repone('Repone', 'Trae lo mismo, sin dinero');

  const Compensacion(this.etiqueta, this.detalle);

  final String etiqueta;
  final String detalle;
}
