/// How the supplier answered; an incident without one is still open.
enum RespuestaProveedor {
  repuso('Repuso'),
  descuento('Descuento'),
  devuelto('Se devolvió'),
  sinRespuesta('Sin respuesta');

  const RespuestaProveedor(this.etiqueta);

  final String etiqueta;
}
