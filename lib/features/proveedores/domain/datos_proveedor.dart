/// What the user fills in to create or edit a supplier; already trimmed.
class DatosProveedor {
  const DatosProveedor({
    required this.nombre,
    this.rif = '',
    this.telefono = '',
    this.contacto = '',
    this.notas = '',
  });

  final String nombre;
  final String rif;
  final String telefono;
  final String contacto;
  final String notas;

  @override
  bool operator ==(Object other) =>
      other is DatosProveedor &&
      other.nombre == nombre &&
      other.rif == rif &&
      other.telefono == telefono &&
      other.contacto == contacto &&
      other.notas == notas;

  @override
  int get hashCode => Object.hash(nombre, rif, telefono, contacto, notas);
}
