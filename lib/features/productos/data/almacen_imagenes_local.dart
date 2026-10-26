// Desktop keeps photos as files; the web build has no file system.
export 'package:inventario/features/productos/data/almacen_imagenes_local_io.dart'
    if (dart.library.js_interop) 'package:inventario/features/productos/data/almacen_imagenes_local_web.dart';
