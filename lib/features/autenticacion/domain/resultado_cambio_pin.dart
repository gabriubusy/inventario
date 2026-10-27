sealed class ResultadoCambioPin {
  const ResultadoCambioPin();
}

class PinCambiado extends ResultadoCambioPin {
  const PinCambiado();
}

/// The current PIN typed does not match, so nothing changed.
class PinActualIncorrecto extends ResultadoCambioPin {
  const PinActualIncorrecto();
}
