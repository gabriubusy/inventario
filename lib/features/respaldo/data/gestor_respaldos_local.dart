// Desktop copies files; the web build has no file system.
export 'package:inventario/features/respaldo/data/gestor_respaldos_local_io.dart'
    if (dart.library.js_interop) 'package:inventario/features/respaldo/data/gestor_respaldos_local_web.dart';
