class Proveedor {
  const Proveedor({
    required this.id,
    required this.nombre,
    this.rif = '',
    this.telefono = '',
    this.contacto = '',
    this.notas = '',
  });

  final String id;

  /// Also the link to brand lots, which store the supplier by name.
  final String nombre;

  /// Optional fields are empty strings when not given.
  final String rif;
  final String telefono;
  final String contacto;
  final String notas;

  Proveedor copyWith({
    String? id,
    String? nombre,
    String? rif,
    String? telefono,
    String? contacto,
    String? notas,
  }) {
    return Proveedor(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      rif: rif ?? this.rif,
      telefono: telefono ?? this.telefono,
      contacto: contacto ?? this.contacto,
      notas: notas ?? this.notas,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Proveedor &&
      other.id == id &&
      other.nombre == nombre &&
      other.rif == rif &&
      other.telefono == telefono &&
      other.contacto == contacto &&
      other.notas == notas;

  @override
  int get hashCode => Object.hash(id, nombre, rif, telefono, contacto, notas);
}
