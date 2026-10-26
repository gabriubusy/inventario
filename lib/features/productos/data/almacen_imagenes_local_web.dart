import 'package:inventario/features/productos/data/almacen_imagenes_en_memoria.dart';
import 'package:inventario/features/productos/domain/almacen_imagenes.dart';

/// Photos last until the tab is reloaded; the web build is only for trying.
Future<AlmacenImagenes> crearAlmacenImagenesLocal() async =>
    AlmacenImagenesEnMemoria();
