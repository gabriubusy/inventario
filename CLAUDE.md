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
- Rapidez ante todo: pocos pasos por proceso, atajos de teclado visibles en la propia UI y deshacer en vez de diálogos de confirmación.
- Inicio: opción B del lienzo "Dashboard Inventario" (acciones de mostrador). F1 salida, F2 entrada, F3 merma, F4 productos, Ctrl+K buscar, Esc limpiar búsqueda, Ctrl+L bloquear, Ctrl+N nuevo producto.
- Crear producto: ventana rápida (diseño "Crear producto · B con piezas, kilos y marcas" del lienzo "Módulos Inventario"). Enter recorre los campos y crea en el último; Alt+1–4 categoría, Alt+Q/W/E/R forma de conteo, Ctrl+M otra marca, Ctrl+Enter crea y deja la ventana lista para otro. Nombre único sin distinguir mayúsculas ni tildes (`NombreRepetido`).
- Modelo de stock: cada `Producto` tiene una `FormaConteo` (piezas y kilos, por kilo, por litro, por unidad) y una lista de `LoteMarca` (marca, proveedor, piezas enteras, pieza abierta, cantidad escalada). El mínimo y el stock bajo van sobre el total: piezas (enteras + abiertas) o cantidad. Marca + proveedor identifican cada lote.
- Ventas (pendiente de diseño): pieza entera = se pesa y se descuenta 1 pieza + su peso real; por kilo = abre una pieza si no hay abierta. Al vender se elige la marca.
- Proveedores (F5 desde el inicio): opción A del lienzo "Proveedores Inventario" (lista + ficha). Esc vuelve, ↑/↓ elige, Ctrl+K busca por nombre o marca, Ctrl+N nuevo, Ctrl+E editar. Solo se guardan nombre (único), RIF, teléfono, contacto y notas; marcas y productos se derivan de los `LoteMarca` cuyo `proveedor` coincide por nombre (`suministrosDe`). Renombrar un proveedor renombra sus lotes (`renombrarProveedor`).
- Productos (F4 desde el inicio): opción A de la fila "Productos (F4) · con marcas y foto" del lienzo "Módulos Inventario" (lista + ficha). La ficha reutiliza el mismo formulario que "Nuevo producto" (`FormularioProducto`: vacío crea, con `producto` edita). Al editar, las existencias se ven pero no se escriben (cambian con entradas, salidas y mermas) y la forma de conteo se bloquea si hay existencias. Esc sale de la ficha, luego limpia la búsqueda, luego vuelve; ↑/↓ y Enter solo cuando el foco no está en la ficha; Ctrl+S guarda con "Deshacer" en el aviso (no Ctrl+Z, que es deshacer al escribir); Ctrl+T tasa; Alt+F foto.
- Precios: cada `LoteMarca` tiene su `precio` en céntimos de dólar por kg, l o und (marcas y proveedores distintos venden a precios distintos). Los bolívares nunca se guardan: se calculan con la tasa del día (`ControladorTasa`, guardada con `shared_preferences`); sin tasa de hoy se usa la última y se avisa.
- Cada módulo nuevo se diseña primero en Claude Design y se programa solo tras elegirlo.
- Estilos: tema Material 3 en `lib/app/tema.dart`, solo modo claro, acento granate (`#7A1F2B`) y bordes finos en vez de sombras. Espaciado con la extensión `Espaciado` (`context.espaciado`: 4, 8, 12, 16, 24, 32). Sin Tailwind ni paquetes de estilos.
- Estado (provisional): `ChangeNotifier` en `application/` con estados `sealed`, inyectado por constructor. Revisar si crece la app.
- Fotos de producto: archivos JPEG en la carpeta de la app (`AlmacenImagenesArchivos`, `imagenes/` dentro de `getApplicationSupportDirectory()`), nunca base64 ni dentro de la base de datos. Se guardan reducidas a 800 px y con miniatura de 200 px (`TamanoImagen`); el producto solo guarda el id. Se crean con `crearAlmacenImagenesLocal()` (import condicional: en web van en memoria), nunca importando `AlmacenImagenesArchivos` directamente. Una foto subida y no guardada se borra al cerrar el formulario; la sustituida se borra cuando ya no se puede deshacer (`GestorFotos.soltarSustituida`).
- La sesión abierta se guarda con `shared_preferences` (`AlmacenSesionPreferencias`) y se restaura en `main()` antes del primer frame; dura hasta pulsar Bloquear (Ctrl+L). En tests se usa `AlmacenSesionEnMemoria`.

## Decisiones pendientes

Registrar aquí cuando se decidan:
- Persistencia local (p. ej. Drift/SQLite). Hasta entonces, el login usa `RepositorioAutenticacionEnMemoria` con una cuenta de desarrollo.
- Navegación (p. ej. go_router). Por ahora `app/puerta_sesion.dart` alterna entre el login y el inicio.
- Fuente (Inter incluida como asset, con cifras tabulares).
