/// Where a rate came from, kept so it is clear which one priced the day.
enum OrigenTasa {
  manual('A mano'),
  bcv('BCV');

  const OrigenTasa(this.etiqueta);

  final String etiqueta;
}
