/// A backup file found in the backups folder.
class ArchivoRespaldo {
  const ArchivoRespaldo({
    required this.ruta,
    required this.nombre,
    required this.fecha,
    required this.bytes,
  });

  final String ruta;
  final String nombre;

  /// When it was written.
  final DateTime fecha;
  final int bytes;

  @override
  bool operator ==(Object other) =>
      other is ArchivoRespaldo &&
      other.ruta == ruta &&
      other.nombre == nombre &&
      other.fecha == fecha &&
      other.bytes == bytes;

  @override
  int get hashCode => Object.hash(ruta, nombre, fecha, bytes);
}

/// "inventario 2026-10-29 151207.inventario": sorts by date by name alone.
/// [copia] tells apart two made in the same second: "… 151207 (2)".
String nombreRespaldo(
  DateTime fecha, {
  String prefijo = 'inventario',
  int copia = 1,
}) {
  String dos(int n) => n.toString().padLeft(2, '0');
  final repetido = copia > 1 ? ' ($copia)' : '';
  return '$prefijo ${fecha.year}-${dos(fecha.month)}-${dos(fecha.day)} '
      '${dos(fecha.hour)}${dos(fecha.minute)}${dos(fecha.second)}'
      '$repetido.inventario';
}

/// "4,2 MB", "820 KB".
String textoTamano(int bytes) {
  const kb = 1024;
  const mb = kb * kb;
  if (bytes < mb) return '${(bytes + kb - 1) ~/ kb} KB';
  final decimas = (bytes * 10 + mb ~/ 2) ~/ mb;
  return '${decimas ~/ 10},${decimas % 10} MB';
}
