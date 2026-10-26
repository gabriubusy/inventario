import 'package:inventario/core/numeros.dart';

/// Money is stored in hundredths: 980 is 9,80.
const decimalesDinero = 2;

String formatearDolares(int centimos) =>
    '\$ ${formatDecimal(centimos, decimales: decimalesDinero, minDecimales: decimalesDinero)}';

String formatearBolivares(int centimos) =>
    '${formatDecimal(centimos, decimales: decimalesDinero, minDecimales: decimalesDinero)} Bs';
