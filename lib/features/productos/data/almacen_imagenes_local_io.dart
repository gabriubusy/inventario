import 'package:inventario/features/productos/data/almacen_imagenes_archivos.dart';
import 'package:inventario/features/productos/domain/almacen_imagenes.dart';

Future<AlmacenImagenes> crearAlmacenImagenesLocal() =>
    AlmacenImagenesArchivos.enCarpetaDeLaApp();
