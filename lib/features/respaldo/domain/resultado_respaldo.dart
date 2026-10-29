sealed class ResultadoRespaldo {
  const ResultadoRespaldo();
}

class RespaldoGuardado extends ResultadoRespaldo {
  const RespaldoGuardado({required this.ruta, required this.bytes});

  final String ruta;
  final int bytes;
}

/// The folder is gone, e.g. the USB stick is not plugged in.
class CarpetaNoDisponible extends ResultadoRespaldo {
  const CarpetaNoDisponible(this.carpeta);

  final String carpeta;
}

/// The chosen file is not a backup of this app.
class RespaldoNoValido extends ResultadoRespaldo {
  const RespaldoNoValido();
}

/// Ready: the app must close; the next start puts the backup in place.
class RestauracionPreparada extends ResultadoRespaldo {
  const RestauracionPreparada({required this.copiaDeAntes});

  /// Where what there was before restoring got saved, just in case.
  final String copiaDeAntes;
}

/// The browser build has no files to copy.
class RespaldoNoDisponibleAqui extends ResultadoRespaldo {
  const RespaldoNoDisponibleAqui();
}
