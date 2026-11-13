sealed class ResultadoGuardarImagen {
  const ResultadoGuardarImagen();
}

class ImagenGuardada extends ResultadoGuardarImagen {
  const ImagenGuardada(this.id);

  final String id;
}

/// The bytes are not an image format we can read.
class ImagenNoValida extends ResultadoGuardarImagen {
  const ImagenNoValida();
}

/// Over [maximoBytesImagen]: a shop photo is never this big, and opening
/// one of 100 megapixels can take the app down.
class ImagenMuyGrande extends ResultadoGuardarImagen {
  const ImagenMuyGrande();
}

/// The biggest photo file that is opened at all.
const maximoMegasImagen = 25;
const maximoBytesImagen = maximoMegasImagen * 1024 * 1024;
