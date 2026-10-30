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
- Rapidez ante todo: pocos pasos por proceso, atajos de teclado visibles en la propia UI como texto suave junto a la acción (`TeclaAtajo`), nunca en recuadros tipo tecla y deshacer en vez de diálogos de confirmación. En los grupos de opciones (tarjetas, chips o botones para elegir uno), cada opción lleva solo su nombre o sus datos (stock, precio), sin atajo ni explicación fija: atajos y explicaciones van en un tooltip "?" sobre el nombre del campo (`ConEtiqueta(ayuda:)`), no uno por opción. Los filtros sin nombre llevan el tooltip sobre el grupo. Los botones de acción siguen con su atajo al lado.
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
- Fase 4 (opción B del lienzo "Fase 4 Inventario"): F11 "Caja" (`PantallaCaja`): sin caja abierta pide el fondo (efectivo $ y Bs); abierta muestra "Debería haber ahora" por `MedioPago` y el total en $ a la tasa de hoy, y todos los movimientos de dinero desde la apertura (`movimientosDeCaja`: ventas con su vuelto, anulaciones y devoluciones, compras de contado, abonos a proveedores, gastos e ingresos). El vuelto y lo devuelto salen del efectivo $ si la venta recibió dólares en efectivo, si no del efectivo Bs a la tasa de la venta; las devoluciones de cliente salen de su `medioReembolso` (las antiguas, sin él, de efectivo $). Ctrl+S cierra: por cada forma de pago viene lo esperado y se corrige lo contado ("Cuadra" / "Faltan" / "Sobran"), con nota. Ctrl+G "Gasto o ingreso" (`DialogoGasto`, desde el inicio y la caja): Alt+Q gasto / Alt+W ingreso, categoría (`CategoriaGasto`, Alt+A…), forma de pago Alt+1–6, monto en la moneda de esa forma; "Deshacer" en el aviso. F12 "Reportes" (`PantallaReportes`): ventas, ganancia (ventas − costo − gastos), más vendidos, inventario valorizado (al costo y a precio), cuentas por pagar y gastos (Alt+1–6), periodo Alt+P; Ctrl+P imprime/guarda PDF (`printing`) y Ctrl+E guarda un Excel `.xlsx` (`ExportadorArchivos`, `xlsxDeReporte`): se arma a mano con `archive` porque el paquete `excel` choca con `pdf` (piden versiones distintas de `xml`); las columnas numéricas van como números (`numeroDeCelda`) y el resto como texto. Cada reporte es un `Reporte` genérico (cifras + tabla ya formateada) que sirve igual a pantalla, PDF y CSV. Tablas Drift `Cajas` y `Gastos` (schemaVersion 4).
- Fase 3 (opción A del lienzo "Fase 3 Inventario"): F2 es "Pedido a proveedor" (`DialogoCompra`; F1 en el inicio se llama "Vender": el usuario encontró confusos "Registrar salida" y "Registrar compra"): proveedor, n° de factura opcional y varias líneas (producto, marca del proveedor o una nueva, piezas, peso o cantidad y costo por kg/l/und, que viene con el último costo de esa marca); Enter en el costo añade la línea, Alt+1… marca. Contado (Alt+Q, con `MedioPago` Alt+A–G) o crédito (Alt+W, "vence en N días", 15 por defecto); Ctrl+S registra en una transacción: sube el stock con `recibirLinea` (también fija `LoteMarca.costo`), anota una entrada por línea en el kardex ("Factura X") y guarda la compra con la tasa del día; "Deshacer" en el aviso. F10 "Cuentas por pagar" (`PantallaCuentas`): facturas a crédito con total, abonado, debe y vencimiento (rojo vencidas, ámbar las que vencen en 7 días); Alt+A por pagar, Alt+T pagadas, ↑/↓, Alt+P paga o abona (`DialogoPago`): Alt+1–5 forma de pago (la moneda sale de la forma: efectivo $ y Zelle en dólares; efectivo Bs, transferencia y pago móvil en bolívares a la tasa de hoy, guardada en el pago), Alt+T pagar todo. La ficha del proveedor (F5) muestra cuánto se le debe; renombrar un proveedor renombra sus compras. Tablas Drift `Compras`, `LineasCompra`, `Pagos` (schemaVersion 2). El viejo `DialogoEntrada` ya no se abre desde ningún sitio.
- Fase 2 (opción B del lienzo "Fase 2 Inventario": cada cosa donde nace). F3 merma o robo (`DialogoAjuste`, Alt+Q merma / Alt+W robo, Alt+A–F motivo, Alt+1… marca, nunca más de lo que hay, "Deshacer" en el aviso). F9 conteo físico de varios productos a la vez (`PantallaConteo`): se escribe lo contado por marca, vacío = no cambia, Ctrl+S guarda todas las diferencias (`conteoFalta`/`conteoSobra`) y se pueden deshacer juntas. Devolución de cliente desde F7 "Ventas" (opción A del lienzo "Devoluciones Inventario": cualquier día con Alt+←/→ u Hoy/Ayer, Ctrl+K filtra por producto, ventas agrupadas por ticket con cómo se pagó; anular con Supr solo hoy), Alt+D: parcial o total, vuelve al stock o va a merma (Alt+Q/W), devuelve la parte proporcional del importe y se resta del vendido del día; "Cómo se le devuelve el dinero" (Alt+1–6 con el número de su `MedioPago`, sin punto de venta; viene elegido como pagó, `medioSugerido`) se guarda en `Movimiento.medioReembolso` (schemaVersion 5) y el monto en Bs usa la tasa de esa venta (`Movimiento.tasa` de la devolución). Una venta con devolución ya no se puede anular entera ni deshacer. Lo devuelto de una pieza sin la pieza entera queda como pieza abierta. Devolución a proveedor: opción B del lienzo "Devolución a proveedor Inventario". Ventana "Devolver a proveedor" (`DialogoDevolucionProveedor`, Ctrl+D desde el inicio y la ficha del proveedor; desde F6 con Ctrl+D sobre una incidencia abierta viene llena y la deja "Se devolvió"): proveedor, por qué (`MotivoDevolucion`, Alt+Z–V), varias líneas con `EditorLineaCompra` sin "Otra marca" (valor = costo × cantidad), y cómo compensa (`Compensacion`): Alt+Q descuenta de una factura a crédito (la más vieja con deuda, Alt+T otra; nunca más de lo que debe) y baja `CuentaPorPagar.devuelto`; Alt+W devuelve dinero (Alt+A–G forma, en Bs a la tasa de hoy) que entra a la caja; Alt+E repone (pendiente hasta Alt+R en la lista). Saca del stock con `sacarDeLote` (salvo que la incidencia ya lo sacó) y anota `TipoMovimiento.devolucionProveedor` en el kardex, todo en una transacción; "Deshacer" en el aviso. Lista en F6 con Alt+D (`PantallaDevolucionesProveedor`). F10 muestra "Devuelto −$" junto a lo abonado. Tablas Drift `DevolucionesProveedor` y `LineasDevolucion` (schemaVersion 6). F8 kardex (`PantallaKardex`, desde el inicio con búsqueda o desde F4 sobre el producto elegido): resumen del periodo, filtros Alt+1–4 (todo/ventas/entradas/pérdidas), Alt+P periodo y marca; el saldo se calcula hacia atrás desde el stock actual (`lineasKardex`), sin guardarlo en cada movimiento. `TipoMovimiento` lleva `signo` y `grupo`; `Movimiento` lleva `nota` y `origenId` (venta de una devolución).
- Incidencias con proveedores (lienzo "Incidencias Inventario", A y B juntas): ventana "Registrar incidencia" con Ctrl+I desde el inicio y desde la ficha del proveedor (con él ya puesto), y Ctrl+N en la pantalla F6. Proveedor → producto+marca de lo que trae (Alt+1…) → qué pasó (`TipoIncidencia`, Alt+Q–T) → piezas/peso → "Sacar del inventario" (Alt+S; marcada salvo "Faltó peso o piezas", descuenta del `LoteMarca` con `sacarDeLote`) → nota; Ctrl+S registra, "Deshacer" en el aviso. Queda abierta hasta marcar cómo respondió el proveedor (`RespuestaProveedor`: repuso, descuento, se devolvió, sin respuesta); sin dinero. La ficha F5 muestra sus incidencias y la lista cuántas abiertas; F6 lista todas con filtro Abiertas/Todas (Alt+A/Alt+T), ↑/↓ y Alt+1–4 responde; en rojo las abiertas de más de 7 días. Fecha siempre la de hoy. Renombrar un proveedor renombra sus incidencias (`alRenombrar`).
- Cada módulo nuevo se diseña primero en Claude Design y se programa solo tras elegirlo.
- Estilos: tema Material 3 en `lib/app/tema.dart`, solo modo claro, acento granate (`#7A1F2B`) y bordes finos en vez de sombras. Espaciado con la extensión `Espaciado` (`context.espaciado`: 4, 8, 12, 16, 24, 32). Sin Tailwind ni paquetes de estilos.
- Logo: opción A4 del lienzo "Logo Inventario" (tres cajas en tonos de granate sobre un cuadrado granate redondeado). La forma vive en `core/marca.dart` (`Marca`) y se dibuja, no es imagen: `LogoInventario` en pantalla (PIN y cabecera del inicio) y `logoPdf` en los PDF. Los iconos (Windows `app_icon.ico`, web, asistente del instalador) se generan con `python tool/generar_iconos.py .`; si cambia `Marca`, actualizar también el script y regenerarlos.
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
- Vender (F1, opción B del lienzo "Venta completa Inventario"): la ventana rápida de siempre con un ticket de varios productos debajo. Enter agrega la línea (`Ticket.agregar`, que comprueba el stock contando las líneas ya puestas), Alt+↑/↓ elige línea, Alt+Supr la quita y Alt+Z la recupera (Supr y Ctrl+Z son de los campos de texto). Esc cierra sin perder el ticket (`ControladorSalidas.ticketEnCurso`). F10 agrega la línea en curso y abre "Cobrar": forma de pago con Alt+1–6 (`MedioPago` en `core/medio_pago.dart`, compartido con compras; recuerda la última), monto vacío = exacto, Ctrl+M añade otro pago (mixto), vuelto en $ y Bs; solo hay vuelto si algún pago es en efectivo (`ResumenCobro`). Al cobrar, en una transacción: la `Venta` (total, tasa, pagos; tablas `ventas` y `pagos_venta`), el stock de cada producto y un `Movimiento` por línea con su `ventaId`. "Deshacer" y Ctrl+Z en el inicio deshacen la venta entera. Anular (F7) sigue siendo por línea. Bajo el buscador, "Más vendidos": hasta 8 botones con los productos vendidos más veces en los últimos 30 días (`masVendidos`), Ctrl+1–8 los elige.

- Fase 5 (lienzo "Fase 5 Inventario", A y A):
  - Configuración (Ctrl+, desde el inicio, `PantallaConfiguracion`): una sola página con datos del negocio (nombre, RIF, dirección, teléfono; tabla Drift `Negocio`, una fila, schemaVersion 7), que salen arriba de los PDF (`DatosNegocio.encabezado`); respaldo; y cambiar PIN. Ctrl+S guarda, Ctrl+B respalda, Esc vuelve.
  - Respaldo (`ControladorRespaldo`, `GestorRespaldosArchivos`): un archivo `.inventario` (zip con copia `VACUUM INTO` de la base + `imagenes/` + `respaldo.json`) en la carpeta elegida, con fecha y hora en el nombre. Carpeta, cada cuántos días recordar (3/7/15/30) y último respaldo van en `shared_preferences` (`AjustesRespaldo`). El inicio avisa si toca (`AvisoRespaldo`: "Respaldar ahora Ctrl+B" o "Mañana"). Restaurar: primero respalda lo de ahora ("antes de restaurar…"), deja el archivo como `restaurar.inventario` y cierra la app; `main()` lo aplica antes de abrir la base (`aplicarRestauracionPendiente`), porque no se puede reemplazar una SQLite abierta. En web no hay respaldo.
  - Listas de precios (`ListaPrecio`: Detal, Mayor, Especial). Detal es el precio de cada marca; Mayor y Especial tienen una regla por producto (`ReglaPrecio`: `MargenSobreCosto` en centésimas de % sobre el costo de la marca, o `PrecioFijo` por kg/l/und), tabla `ReglasPrecio` (schemaVersion 8). Sin regla, o margen sin costo, vale Detal (`precioDeLote`, `precioDePresentacion`, que escala por el tamaño del paquete). En la ventana del producto, sección "Listas de precios" plegada mientras no haya reglas (Alt+L la abre y va a Mayor) con "Queda" por marca. En Vender, Alt+L cambia la lista de todo el ticket y recalcula las líneas (`Ticket.conLista`); la venta guarda su lista (`Venta.lista`, columna `ventas.lista`) y el siguiente ticket vuelve a Detal. Ajuste masivo desde F4 (Ctrl+Shift+A, `DialogoAjustePrecios`, `ControladorAjustePrecios`): sube/baja (Alt+Q/W) un %, lista Alt+1–3, a todos / una categoría / un proveedor (Alt+A/S/D; repetir la tecla pasa a la siguiente), con vista previa; Enter o Ctrl+Enter aplica en una transacción (`ajustarPrecios`: en Mayor/Especial mueve la regla para que el precio final cambie igual) y "Deshacer" en el aviso si nada cambió después.
  - Instalador: `installer/inventario.iss` (Inno Setup, por usuario, sin administrador). Antes hay que compilar con `flutter build windows --release`, que necesita Visual Studio con C++. Los datos quedan en AppData al desinstalar.

## Decisiones pendientes

Registrar aquí cuando se decidan:
- Navegación (p. ej. go_router). Por ahora `app/puerta_sesion.dart` alterna entre el login y el inicio.
- Fuente (Inter incluida como asset, con cifras tabulares).
