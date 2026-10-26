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
