/// How long the app may sit idle before it locks itself, in minutes.
/// Zero means never, which is what a one-person counter wants.
abstract interface class AlmacenBloqueo {
  Future<int> leerMinutos();
  Future<void> guardarMinutos(int minutos);
}
