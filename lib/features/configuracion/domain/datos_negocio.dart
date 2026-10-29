/// The shop's own details, printed on the PDF reports.
class DatosNegocio {
  const DatosNegocio({
    this.nombre = '',
    this.rif = '',
    this.direccion = '',
    this.telefono = '',
  });

  final String nombre;
  final String rif;
  final String direccion;
  final String telefono;

  bool get vacio =>
      nombre.isEmpty && rif.isEmpty && direccion.isEmpty && telefono.isEmpty;

  /// "Charcutería La Esquina · RIF J-40123456-7 · 0414-1234567"; empty
  /// parts are left out.
  String get encabezado => [
    nombre,
    if (rif.isNotEmpty) 'RIF $rif',
    direccion,
    telefono,
  ].where((parte) => parte.isNotEmpty).join(' · ');

  @override
  bool operator ==(Object other) =>
      other is DatosNegocio &&
      other.nombre == nombre &&
      other.rif == rif &&
      other.direccion == direccion &&
      other.telefono == telefono;

  @override
  int get hashCode => Object.hash(nombre, rif, direccion, telefono);
}
