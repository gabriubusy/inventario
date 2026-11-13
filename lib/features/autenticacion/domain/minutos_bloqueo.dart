/// How long the app may sit idle before locking itself. Zero means never,
/// which is what a counter with only one person wants.
abstract final class MinutosBloqueo {
  static const opciones = [0, 5, 15, 30];

  /// Never, so nothing changes until it is chosen on purpose.
  static const porDefecto = 0;

  static String etiqueta(int minutos) =>
      minutos == 0 ? 'Nunca' : '$minutos min';
}
