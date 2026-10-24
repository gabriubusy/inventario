class Usuario {
  const Usuario({required this.id, required this.nombre});

  final String id;
  final String nombre;

  Usuario copyWith({String? id, String? nombre}) {
    return Usuario(id: id ?? this.id, nombre: nombre ?? this.nombre);
  }

  @override
  bool operator ==(Object other) =>
      other is Usuario && other.id == id && other.nombre == nombre;

  @override
  int get hashCode => Object.hash(id, nombre);
}
