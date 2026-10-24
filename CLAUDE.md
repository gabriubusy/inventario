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
- Inicio: opción B del lienzo "Dashboard Inventario" (acciones de mostrador). F1 salida, F2 entrada, F3 merma, F4 productos, Ctrl+K buscar, Esc limpiar búsqueda, Ctrl+L bloquear.
- Estilos: tema Material 3 en `lib/app/tema.dart`, solo modo claro, acento granate (`#7A1F2B`) y bordes finos en vez de sombras. Espaciado con la extensión `Espaciado` (`context.espaciado`: 4, 8, 12, 16, 24, 32). Sin Tailwind ni paquetes de estilos.
- Estado (provisional): `ChangeNotifier` en `application/` con estados `sealed`, inyectado por constructor. Revisar si crece la app.
- La sesión abierta se guarda con `shared_preferences` (`AlmacenSesionPreferencias`) y se restaura en `main()` antes del primer frame; dura hasta pulsar Bloquear (Ctrl+L). En tests se usa `AlmacenSesionEnMemoria`.

## Decisiones pendientes

Registrar aquí cuando se decidan:
- Persistencia local (p. ej. Drift/SQLite). Hasta entonces, el login usa `RepositorioAutenticacionEnMemoria` con una cuenta de desarrollo.
- Navegación (p. ej. go_router). Por ahora `app/puerta_sesion.dart` alterna entre el login y el inicio.
- Fuente (Inter incluida como asset, con cifras tabulares).
