/// What money that is not a sale was for. Ingresos come in, the rest go out.
enum CategoriaGasto {
  servicios('Servicios'),
  sueldos('Sueldos'),
  alquiler('Alquiler'),
  transporte('Transporte'),
  mantenimiento('Mantenimiento'),
  empaques('Bolsas y empaques'),
  otrosGastos('Otros'),
  aporteDueno('Aporte del dueño', esIngreso: true),
  prestamo('Préstamo', esIngreso: true),
  otrosIngresos('Otros', esIngreso: true);

  const CategoriaGasto(this.etiqueta, {this.esIngreso = false});

  final String etiqueta;
  final bool esIngreso;

  static List<CategoriaGasto> de({required bool ingreso}) => [
    for (final c in values)
      if (c.esIngreso == ingreso) c,
  ];
}
