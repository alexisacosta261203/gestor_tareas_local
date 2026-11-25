import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/data/database.dart';
import 'package:gestor_tareas_local/data/tareas_repository.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('Validación de títulos', () {
    test('rechaza vacío y solo espacios (P5)', () {
      expect(() => validarTitulo(''), throwsA(isA<TareaException>()));
      expect(() => validarTitulo('    '), throwsA(isA<TareaException>()));
      expect(() => validarTitulo(null), throwsA(isA<TareaException>()));
    });

    test('recorta espacios de un título válido', () {
      expect(validarTitulo('  Estudiar  '), 'Estudiar');
    });

    test('rechaza títulos de más de 200 caracteres', () {
      expect(() => validarTitulo('a' * 201), throwsA(isA<TareaException>()));
    });
  });

  group('CRUD en SQLite (en memoria)', () {
    late TareasRepository repo;

    setUp(() {
      repo = TareasRepository(AppDatabase(NativeDatabase.memory()));
    });

    tearDown(() => repo.cerrar());

    test('alta y consulta', () async {
      await repo.agregar('Uno');
      await repo.agregar('Dos');
      await repo.agregar('Tres');
      final tareas = await repo.obtenerTareas();
      expect(tareas.map((t) => t.titulo), ['Uno', 'Dos', 'Tres']);
      expect(tareas.every((t) => !t.completada), isTrue);
    });

    test('un título vacío no se guarda', () async {
      await expectLater(repo.agregar('   '), throwsA(isA<TareaException>()));
      expect(await repo.obtenerTareas(), isEmpty);
    });

    test('editar, cambiar estado y eliminar', () async {
      final id = await repo.agregar('Original');
      final otro = await repo.agregar('Otra');

      await repo.editarTitulo(id, 'Editada');
      await repo.cambiarEstado(id, true);
      var tareas = await repo.obtenerTareas();
      final t = tareas.firstWhere((x) => x.id == id);
      expect(t.titulo, 'Editada');
      expect(t.completada, isTrue);

      await repo.eliminar(otro);
      tareas = await repo.obtenerTareas();
      expect(tareas.map((x) => x.id), [id]);
    });

    test('editar una tarea inexistente lanza error', () async {
      await expectLater(
          repo.editarTitulo(999, 'X'), throwsA(isA<TareaException>()));
    });
  });

  test('los datos persisten al cerrar y reabrir el archivo (P1)', () async {
    final dir = await Directory.systemTemp.createTemp('tareas_test');
    final archivo = File('${dir.path}/db.sqlite');

    var repo = TareasRepository(AppDatabase(NativeDatabase(archivo)));
    await repo.agregar('Persistente');
    await repo.cerrar();

    repo = TareasRepository(AppDatabase(NativeDatabase(archivo)));
    final tareas = await repo.obtenerTareas();
    expect(tareas.single.titulo, 'Persistente');
    await repo.cerrar();
    await dir.delete(recursive: true);
  });
}
