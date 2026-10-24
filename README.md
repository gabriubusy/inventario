# Inventario

App de escritorio (Windows) para llevar el inventario desde el mostrador: entradas, salidas y mermas con atajos de teclado. Formato numérico venezolano (`1.234,5`).

## Requisitos

- Flutter estable (SDK de Dart `^3.13.7`).
- En Windows, activar el **Modo de desarrollador** (`start ms-settings:developers`); los plugins lo necesitan para compilar.

## Uso

```powershell
flutter pub get
flutter run -d windows
```

En desarrollo, el PIN de acceso es `1234`.

| Atajo | Acción |
|---|---|
| F1 / F2 / F3 | Salida / entrada / merma |
| F4 | Productos |
| Ctrl+K | Buscar |
| Esc | Limpiar búsqueda |
| Ctrl+L | Bloquear |

## Desarrollo

```powershell
flutter analyze
flutter test
dart format lib test
```

Arquitectura, principios y decisiones del proyecto en [CLAUDE.md](CLAUDE.md).
