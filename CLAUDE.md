# Inventario

App Flutter (escritorio Windows) para gestionar inventario. Formato numérico venezolano (`1.234,5`).

## Comandos

El SDK está en `D:\src\flutter` (no está en el PATH).

```powershell
D:\src\flutter\bin\flutter analyze      # debe quedar sin avisos
D:\src\flutter\bin\flutter test
D:\src\flutter\bin\dart format lib test
D:\src\flutter\bin\flutter run -d windows
```

Antes de dar algo por terminado: `analyze` limpio, `test` en verde y código formateado.

## Arquitectura

Organización por funcionalidad (feature-first) con capas. Las dependencias solo apuntan hacia dentro: `presentation → application → domain ← data`.

```
lib/
  main.dart              # solo arranque y wiring de dependencias
  app/                   # MaterialApp, tema, rutas
  core/                  # utilidades puras compartidas (numeros, unidad, errores)
  features/
    <feature>/
      domain/            # entidades, value objects, contratos de repositorio. Dart puro, sin Flutter
      data/              # implementaciones de repositorios, DTOs, fuentes de datos
      application/       # casos de uso / controladores de estado
      presentation/      # pantallas y widgets
test/                    # misma estructura que lib/
```

- `domain/` no importa `package:flutter` ni nada de `data/`.
- Los widgets no hablan con la base de datos ni con APIs: pasan por `application/`.
- `core/` solo contiene código sin estado y sin dependencias de features.

## Principios

**SOLID**
- Una responsabilidad por clase y por archivo. Si un widget o clase pasa de ~200 líneas, partirlo.
- Abierto/cerrado: añadir comportamiento con nuevos tipos (enums con datos, `sealed class`) en vez de `if`/`switch` repartidos.
- Inversión de dependencias: `application/` depende de contratos abstractos de `domain/`, nunca de implementaciones concretas. Las dependencias se inyectan por constructor.
- Interfaces pequeñas: un repositorio por agregado, sin métodos que el consumidor no use.

**Modelo de datos**
- Cantidades y dinero siempre como `int` escalado (ver `core/numeros.dart` y `UnidadBase.fraccionesPorUnidad`). Nunca `double` para stock ni precios.
- Entidades inmutables: campos `final`, constructores `const` cuando se pueda, `copyWith` para cambios.
- Igualdad por valor en entidades y value objects (`==`/`hashCode` o `Equatable`).
- Estados y resultados con `sealed class` + `switch` exhaustivo; sin `default` que oculte casos nuevos.
- Validar en los bordes (formularios, parseo de datos externos); el dominio recibe datos ya válidos.

**Errores**
- Errores esperados (validación, no encontrado, stock insuficiente) se devuelven como tipos del dominio, no como excepciones genéricas.
- Nunca `catch (e) {}` vacío. Capturar tipos concretos.
- Solo se lanzan `Exception`/`Error` propios, nunca strings.

**Widgets**
- Preferir `StatelessWidget`; `StatefulWidget` solo para estado efímero de UI (animaciones, `TextEditingController`).
- Extraer widgets en clases, no en métodos `_buildX()`, para que Flutter pueda reconstruir solo lo necesario.
- `const` en todo lo que lo admita.
- Liberar en `dispose()` todo controller, `FocusNode`, `StreamSubscription`.
- Tras un `await`, comprobar `context.mounted` antes de usar `context`.
- Colores, tipografía y espaciado desde `Theme.of(context)`; nada de colores o tamaños sueltos repetidos.
- `build()` sin efectos secundarios ni trabajo pesado.

**Async**
- Todo `Future` se espera o se marca con `unawaited(...)` a propósito.
- Las operaciones de E/S van en `data/`, nunca en `build()`.

## Convenciones

- Identificadores del dominio en español (`producto`, `existencia`, `UnidadBase`), como el código actual.
- Comentarios en inglés, cortos (máx. 2 líneas) y solo cuando aportan el porqué.
- Imports `package:inventario/...`, nunca relativos.
- Archivos en `snake_case.dart`; una clase pública principal por archivo.

## Tests

- Toda lógica de `core/` y `domain/` lleva test unitario.
- Casos de uso con repositorios falsos (implementaciones en memoria del contrato), no mocks de la base de datos real.
- Widgets críticos (formularios de entrada de stock) con `testWidgets`.
- Un test por comportamiento, con nombre que describe el comportamiento.

## Decisiones tomadas

- Un solo usuario: el login pide solo un PIN de 4 dígitos (`Pin`), con teclado en pantalla y teclado físico. Sin nombre de usuario, perfiles ni roles. Diseño elegido: opción C del lienzo "Login Inventario" en Claude Design.
- Rapidez ante todo: pocos pasos por proceso, atajos de teclado visibles en la propia UI como texto suave junto a la acción (`TeclaAtajo`), nunca en recuadros tipo tecla y deshacer en vez de diálogos de confirmación.
- Inicio: opción B del lienzo "Dashboard Inventario" (acciones de mostrador). F1 salida, F2 entrada, F3 merma, F4 productos, Ctrl+K buscar, Esc limpiar búsqueda, Ctrl+L bloquear, Ctrl+N nuevo producto.
- Crear producto: ventana rápida (diseño "Crear producto · B con piezas, kilos y marcas" del lienzo "Módulos Inventario"). Enter recorre los campos y crea en el último; Alt+1–4 categoría, Alt+Q/W/E/R forma de conteo, Ctrl+M otra marca, Ctrl+Enter crea y deja la ventana lista para otro. Nombre único sin distinguir mayúsculas ni tildes (`NombreRepetido`).
- Modelo de stock: cada `Producto` tiene una `FormaConteo` (piezas y kilos, por kilo, por litro, por unidad) y una lista de `LoteMarca` (marca, proveedor, piezas enteras, pieza abierta, cantidad escalada). El mínimo y el stock bajo van sobre el total: piezas (enteras + abiertas) o cantidad. Marca + proveedor identifican cada lote.
- Salidas (F1 desde el inicio): opción A del lienzo "Salidas Inventario" (un producto por salida), elegida por velocidad. Pieza entera = se pesa y se descuenta 1 pieza + su peso real; por kilo = abre una pieza si no hay abierta (`vender`). La marca viene sugerida (pieza abierta o la de más stock, `loteSugerido`), "cómo se vende" recuerda la última vez por producto (Alt+P / Alt+K), el foco va directo a la cantidad y Enter registra; nunca se vende más de lo que hay. Importe = precio de la marca × cantidad, en $ y Bs. Marca sin precio = se registra sin importe. "Deshacer" en el aviso; Ctrl+Z en el inicio deshace el último movimiento, sea entrada o salida. Sin historial de ventas todavía.
- Proveedores (F5 desde el inicio): opción A del lienzo "Proveedores Inventario" (lista + ficha). Esc vuelve, ↑/↓ elige, Ctrl+K busca por nombre o marca, Ctrl+N nuevo, Ctrl+E editar. Solo se guardan nombre (único), RIF, teléfono, contacto y notas; marcas y productos se derivan de los `LoteMarca` cuyo `proveedor` coincide por nombre (`suministrosDe`). Renombrar un proveedor renombra sus lotes (`renombrarProveedor`).
- Entradas (F2 desde el inicio, o desde la ficha de un proveedor con su marca ya elegida): opción A del lienzo "Entradas Inventario" (un producto por entrada). Se busca el producto, Alt+1… elige marca u "Otra marca", piezas + peso o cantidad (> 0), nota opcional; vista previa "quedará: antes → después". La entrada se suma al `LoteMarca` de igual marca + proveedor o crea uno nuevo (`sumarEntrada`). Ctrl+Enter registra y deja la ventana lista. "Deshacer" en el aviso y Ctrl+Z en el inicio (fuera de campos de texto) devuelven el producto a como estaba, solo si no cambió después. Sin precio de compra ni historial de movimientos todavía.
- Productos (F4 desde el inicio): lista a todo el ancho (basada en la opción A de la fila "Productos (F4) · con marcas y foto" del lienzo "Módulos Inventario"). Crear y editar son ventanas modales, no un panel fijo (lo pidió el usuario): la misma ventana que "Nuevo producto" (`mostrarDialogoNuevoProducto` / `mostrarDialogoEditarProducto`, ambas con `FormularioProducto`: vacío crea, con `producto` edita). Clic en un producto o ↑/↓ + Enter abre su ventana; la lista absorbe ↑/↓/Enter para que Flutter no mueva el foco a otros botones. Al editar, las existencias se ven pero no se escriben (cambian con entradas, salidas y mermas) y la forma de conteo se bloquea si hay existencias. Esc limpia la búsqueda y luego vuelve; Ctrl+S guarda, cierra la ventana con "Deshacer" en el aviso (no Ctrl+Z, que es deshacer al escribir); Ctrl+T tasa; Alt+F foto.
- Precios: cada `LoteMarca` tiene su `precio` en céntimos de dólar por kg, l o und (marcas y proveedores distintos venden a precios distintos). Los bolívares nunca se guardan: se calculan con la tasa del día (`ControladorTasa`, guardada con `shared_preferences`); sin tasa de hoy se usa la última y se avisa.
- Tasa del dólar: oficial BCV desde DolarApi (`https://ve.dolarapi.com/v1/dolares/oficial`, `FuenteTasaDolarApi`). Al arrancar, si no hay tasa de hoy, se consulta una vez y se guarda sola con `origen: bcv`; nunca se consulta en cada operación. Sin internet o con la API caída queda la última y el aviso pide escribirla a mano (Ctrl+T, `origen: manual`); una tasa escrita a mano gana a la que llegue después. Se ve siempre en la cabecera del inicio y de Productos.
- Inicio actualizado: opción C del lienzo "Inicio con movimientos". Botones F1–F4 bajos; cuatro cifras del día (vendido hoy en $ y Bs, kilos vendidos, más vendido, cuántos hay que reponer); "Últimas ventas" de hoy y "Hay que reponer" (agotados y bajos con su proveedor, `porReponer`); debajo existencias en tarjetas compactas. La cabecera muestra siempre texto + atajo (sin iconos) y se encoge si no cabe. Ventas y entradas se anotan en el historial `ControladorMovimientos` (feature `movimientos`) y deshacer las quita; en memoria hasta decidir persistencia.
- Fase 2 (opción B del lienzo "Fase 2 Inventario": cada cosa donde nace). F3 merma o robo (`DialogoAjuste`, Alt+Q merma / Alt+W robo, Alt+A–F motivo, Alt+1… marca, nunca más de lo que hay, "Deshacer" en el aviso). F9 conteo físico de varios productos a la vez (`PantallaConteo`): se escribe lo contado por marca, vacío = no cambia, Ctrl+S guarda todas las diferencias (`conteoFalta`/`conteoSobra`) y se pueden deshacer juntas. Devolución de cliente desde "Ventas de hoy" (F7, Alt+D): parcial o total, vuelve al stock o va a merma (Alt+Q/W), devuelve la parte proporcional del importe y se resta del vendido del día; una venta con devolución ya no se puede anular entera. Devolución a proveedor = incidencia con "Sacar del inventario" (queda en el kardex como `incidencia`). F8 kardex (`PantallaKardex`, desde el inicio con búsqueda o desde F4 sobre el producto elegido): resumen del periodo, filtros Alt+1–4 (todo/ventas/entradas/pérdidas), Alt+P periodo y marca; el saldo se calcula hacia atrás desde el stock actual (`lineasKardex`), sin guardarlo en cada movimiento. `TipoMovimiento` lleva `signo` y `grupo`; `Movimiento` lleva `nota` y `origenId` (venta de una devolución).
- Incidencias con proveedores (lienzo "Incidencias Inventario", A y B juntas): ventana "Registrar incidencia" con Ctrl+I desde el inicio y desde la ficha del proveedor (con él ya puesto), y Ctrl+N en la pantalla F6. Proveedor → producto+marca de lo que trae (Alt+1…) → qué pasó (`TipoIncidencia`, Alt+Q–T) → piezas/peso → "Sacar del inventario" (Alt+S; marcada salvo "Faltó peso o piezas", descuenta del `LoteMarca` con `sacarDeLote`) → nota; Ctrl+S registra, "Deshacer" en el aviso. Queda abierta hasta marcar cómo respondió el proveedor (`RespuestaProveedor`: repuso, descuento, se devolvió, sin respuesta); sin dinero. La ficha F5 muestra sus incidencias y la lista cuántas abiertas; F6 lista todas con filtro Abiertas/Todas (Alt+A/Alt+T), ↑/↓ y Alt+1–4 responde; en rojo las abiertas de más de 7 días. Fecha siempre la de hoy. Renombrar un proveedor renombra sus incidencias (`alRenombrar`).
- Cada módulo nuevo se diseña primero en Claude Design y se programa solo tras elegirlo.
- Estilos: tema Material 3 en `lib/app/tema.dart`, solo modo claro, acento granate (`#7A1F2B`) y bordes finos en vez de sombras. Espaciado con la extensión `Espaciado` (`context.espaciado`: 4, 8, 12, 16, 24, 32). Sin Tailwind ni paquetes de estilos.
- Estado (provisional): `ChangeNotifier` en `application/` con estados `sealed`, inyectado por constructor. Revisar si crece la app.
- Fotos de producto: archivos JPEG en la carpeta de la app (`AlmacenImagenesArchivos`, `imagenes/` dentro de `getApplicationSupportDirectory()`), nunca base64 ni dentro de la base de datos. Se guardan reducidas a 800 px y con miniatura de 200 px (`TamanoImagen`); el producto solo guarda el id. Se crean con `crearAlmacenImagenesLocal()` (import condicional: en web van en memoria), nunca importando `AlmacenImagenesArchivos` directamente. Una foto subida y no guardada se borra al cerrar el formulario; la sustituida se borra cuando ya no se puede deshacer (`GestorFotos.soltarSustituida`).
- La sesión abierta se guarda con `shared_preferences` (`AlmacenSesionPreferencias`) y se restaura en `main()` antes del primer frame; dura hasta pulsar Bloquear (Ctrl+L). En tests se usa `AlmacenSesionEnMemoria`.
- Fase 1 (lienzo "Fase 1 Inventario", aprobado). Sin historial de tasas.
  - Cambiar PIN: enlace junto a Bloquear (Ctrl+Shift+L), tres pasos (actual, nuevo, repetir). Se guarda solo la huella PBKDF2-SHA256 con sal (`HuellaPin`, `RepositorioAutenticacionPreferencias`); sin huella guardada vale el PIN de la cuenta de desarrollo.
  - Presentaciones (`Presentacion`: nombre, factor, precio fijo igual para todas las marcas, código de barras único entre productos, una predeterminada) solo en productos por kilo, litro o unidad; quesos y jamones siguen con piezas. Ctrl+P añade una en el formulario. Si hay presentaciones, el precio de venta es el de la presentación; si no, el de la marca.
  - Stock legible: `textoStock` → "26,5 kg (1 saco + 11,5 kg)" con el paquete más grande que cabe (`desglosarStock`).
  - Salida por presentación: el buscador acepta el código exacto y deja elegida la presentación; Alt+1… presentación y, si las hay, Alt+Q… marca. Cantidad con 3 decimales en paquetes.
  - Anular venta (F7 o "Ver y anular" en Últimas ventas): ventana "Ventas de hoy", ↑/↓ elige, Supr pide confirmación (la única del app, la pidió el usuario; Enter anula, Esc no). Devuelve el stock a su lote y cierra la pieza que la venta abrió (`devolverVenta`); la venta queda tachada como "Anulada" y no cuenta en el resumen del día.
  - Tasa obligatoria: sin tasa de hoy no se vende (`SinTasaDelDia`; F1 abre antes la ventana de tasa) y al entrar al inicio se pide una vez si internet no la trajo (`PedirTasaSiFalta`, `hayQuePedirla`). Cada venta guarda la tasa usada (`Movimiento.tasa`) y su costo (`Movimiento.costo`, `costoDeSalida`).
  - Costo: opcional por marca (`LoteMarca.costo`, $ por kg/l/und, campo "Costo" junto a "Precio"), como el precio.
  - Borrar producto: en su ventana de edición, "Borrar producto" o Alt+Supr (Ctrl+Supr borra palabras al escribir), con confirmación (`confirmar` en `app/dialogo_confirmar.dart`, para acciones delicadas sin deshacer). El historial guarda su propia copia del nombre.
- Persistencia: SQLite con Drift (`app/base_datos/`: `BaseDatos`, `abrirBaseDatos()`). Cada funcionalidad declara sus tablas en su `data/` (`tablas_productos.dart`, `tabla_movimientos.dart`…) y su `Repositorio…Drift`; los `…EnMemoria` quedan para tests. Ids de texto (`nuevoId`), enums guardados por nombre, fechas como texto (`build.yaml`) para conservar hora local y microsegundos. Archivo `inventario.sqlite` en `getApplicationSupportDirectory()`, claves foráneas y WAL. En web usa `web/sqlite3.wasm` y `web/drift_worker.js` (de sqlite3 3.5.2 y drift 2.35.3: actualizarlos si cambian esas versiones). Solo en debug, una base vacía se llena con los datos de ejemplo (`sembrarEjemplos`); la app compilada empieza vacía. Tras cambiar tablas: `dart run build_runner build` y subir `schemaVersion` con su migración. PIN, sesión y tasa siguen en `shared_preferences`.

- Transacciones: lo que cambia stock e historial a la vez (ventas, anular, entradas, mermas, conteo, devoluciones, incidencias, y sus deshacer) va dentro de `Transacciones.enUna` (`core/transacciones.dart`), inyectado por constructor: `TransaccionesDrift` en la app (las llamadas a repositorios dentro se unen a la misma transacción SQLite) y `SinTransaccion` por defecto en tests. Si falla a mitad, nada queda escrito.

## Decisiones pendientes

Registrar aquí cuando se decidan:
- Navegación (p. ej. go_router). Por ahora `app/puerta_sesion.dart` alterna entre el login y el inicio.
- Fuente (Inter incluida como asset, con cifras tabulares).
