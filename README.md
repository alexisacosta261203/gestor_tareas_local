# Gestor de tareas con SQLite (Flutter + Drift)

App Flutter que guarda tareas en una base **SQLite local** (sin servidor, sin HTTP).
Una sola base de código para Android, iOS, Windows, Linux, macOS y web.

## Tecnología de persistencia

- **Drift** (`drift`) — ORM tipado sobre SQLite, consultas reactivas con `Stream`.
- **drift_flutter** — `driftDatabase()` abre la base correcta en cada plataforma:
  - Nativo: archivo `gestor_tareas.sqlite` en el directorio de documentos de la app.
  - Web: SQLite compilado a WebAssembly (`web/sqlite3.wasm`) en un worker
    (`web/drift_worker.js`); se guarda en OPFS o IndexedDB del navegador.
- **drift_dev + build_runner** — generan `lib/data/database.g.dart`.

## Tabla `tareas`

| Columna    | Tipo SQLite                        |
|------------|------------------------------------|
| id         | INTEGER PRIMARY KEY AUTOINCREMENT  |
| titulo     | TEXT NOT NULL (1–200)              |
| completada | INTEGER NOT NULL DEFAULT 0 (bool)  |

## Estructura

```
lib/
  main.dart                    arranque, abre y cierra la base
  models/tarea.dart            modelo de dominio
  data/database.dart           tabla Drift + operaciones CRUD
  data/tareas_repository.dart  validación y manejo de errores
  screens/tareas_page.dart     UI (StreamBuilder; sin consultas en build())
web/
  sqlite3.wasm, drift_worker.js
test/
  widget_test.dart, tareas_test.dart
```

## Cómo ejecutar

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run -d chrome      # web
flutter run -d linux       # o windows / macos / un dispositivo Android
```

Si `pubspec.lock` resuelve otras versiones de `drift`/`sqlite3`, descarga los
archivos web correspondientes desde los releases:
- https://github.com/simolus3/sqlite3.dart/releases (`sqlite3.wasm`)
- https://github.com/simolus3/drift/releases (`drift_worker.js`)

## Pruebas automatizadas

- `widget_test.dart`: la pantalla abre con una base en memoria.
- `tareas_test.dart`: validación de títulos (vacío/espacios/longitud),
  CRUD completo, edición de id inexistente y persistencia al cerrar y reabrir
  un archivo SQLite.

## Plataformas verificadas

| Plataforma | Estado |
|------------|--------|
| Web (Chrome) | _pendiente de llenar_ |
| Android / Windows / Linux | _pendiente de llenar_ |
| iOS / macOS | prevista (requiere Mac) |

## Pruebas manuales P1–P6

| ID | Resultado |
|----|-----------|
| P1 | _pendiente_ |
| P2 | _pendiente_ |
| P3 | _pendiente_ |
| P4 | _pendiente_ |
| P5 | _pendiente_ |
| P6 | _pendiente_ |
