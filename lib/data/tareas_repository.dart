import '../models/tarea.dart';
import 'database.dart';

/// Error de validación o de almacenamiento con mensaje para el usuario.
class TareaException implements Exception {
  final String mensaje;
  const TareaException(this.mensaje);

  @override
  String toString() => mensaje;
}

/// Valida un título. Devuelve el título limpio o lanza [TareaException].
String validarTitulo(String? titulo) {
  final limpio = (titulo ?? '').trim();
  if (limpio.isEmpty) {
    throw const TareaException('El título no puede estar vacío.');
  }
  if (limpio.length > 200) {
    throw const TareaException('El título no puede superar 200 caracteres.');
  }
  return limpio;
}

/// Capa entre la UI y Drift: valida, convierte modelos y traduce errores.
class TareasRepository {
  final AppDatabase _db;
  TareasRepository(this._db);

  Stream<List<Tarea>> observarTareas() =>
      _db.observarTareas().map((filas) => filas.map(_aModelo).toList());

  Future<List<Tarea>> obtenerTareas() async =>
      (await _db.obtenerTareas()).map(_aModelo).toList();

  Future<int> agregar(String titulo) async {
    final limpio = validarTitulo(titulo);
    return _ejecutar(() => _db.insertarTarea(limpio), 'guardar la tarea');
  }

  Future<void> editarTitulo(int id, String titulo) async {
    final limpio = validarTitulo(titulo);
    final filas = await _ejecutar(
        () => _db.actualizarTitulo(id, limpio), 'editar la tarea');
    if (filas == 0) throw const TareaException('La tarea ya no existe.');
  }

  Future<void> cambiarEstado(int id, bool completada) async {
    await _ejecutar(
        () => _db.cambiarEstado(id, completada), 'actualizar el estado');
  }

  Future<void> eliminar(int id) async {
    await _ejecutar(() => _db.eliminarTarea(id), 'eliminar la tarea');
  }

  Future<void> cerrar() => _db.close();

  Future<T> _ejecutar<T>(Future<T> Function() op, String accion) async {
    try {
      return await op();
    } on TareaException {
      rethrow;
    } catch (e) {
      throw TareaException('No se pudo $accion: $e');
    }
  }

  static Tarea _aModelo(TareaRegistro r) =>
      Tarea(id: r.id, titulo: r.titulo, completada: r.completada);
}
