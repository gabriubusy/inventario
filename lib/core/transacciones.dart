/// Runs several writes as one: either all are saved or none. A sale, for
/// instance, takes stock out and notes the movement together.
abstract interface class Transacciones {
  Future<T> enUna<T>(Future<T> Function() escrituras);
}

/// For in-memory repositories (tests), where there is nothing to roll back.
class SinTransaccion implements Transacciones {
  const SinTransaccion();

  @override
  Future<T> enUna<T>(Future<T> Function() escrituras) => escrituras();
}
