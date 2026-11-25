import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Tabla `tareas` en SQLite:
///   id         INTEGER PRIMARY KEY AUTOINCREMENT
///   titulo     TEXT NOT NULL (1..200 caracteres)
///   completada INTEGER NOT NULL DEFAULT 0  (booleano 0/1)
@DataClassName('TareaRegistro')
class Tareas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get titulo => text().withLength(min: 1, max: 200)();
  BoolColumn get completada =>
      boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Tareas])
class AppDatabase extends _$AppDatabase {
  /// Permite inyectar otro executor (p. ej. base en memoria para pruebas).
  AppDatabase(super.e);

  /// Abre la base persistente en la plataforma actual.
  /// Nativo: archivo en el directorio de documentos de la app.
  /// Web: OPFS/IndexedDB mediante sqlite3.wasm + drift_worker.js en web/.
  factory AppDatabase.abrir() {
    return AppDatabase(
      driftDatabase(
        name: 'gestor_tareas',
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
        ),
      ),
    );
  }

  @override
  int get schemaVersion => 1;

  /// SELECT reactivo: emite de nuevo cada vez que cambia la tabla.
  Stream<List<TareaRegistro>> observarTareas() {
    return (select(tareas)..orderBy([(t) => OrderingTerm.asc(t.id)])).watch();
  }

  Future<List<TareaRegistro>> obtenerTareas() {
    return (select(tareas)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
  }

  /// INSERT; devuelve el id generado.
  Future<int> insertarTarea(String titulo) {
    return into(tareas).insert(TareasCompanion.insert(titulo: titulo));
  }

  /// UPDATE del título; devuelve filas afectadas.
  Future<int> actualizarTitulo(int id, String titulo) {
    return (update(tareas)..where((t) => t.id.equals(id)))
        .write(TareasCompanion(titulo: Value(titulo)));
  }

  /// UPDATE del estado.
  Future<int> cambiarEstado(int id, bool completada) {
    return (update(tareas)..where((t) => t.id.equals(id)))
        .write(TareasCompanion(completada: Value(completada)));
  }

  /// DELETE por id.
  Future<int> eliminarTarea(int id) {
    return (delete(tareas)..where((t) => t.id.equals(id))).go();
  }
}
