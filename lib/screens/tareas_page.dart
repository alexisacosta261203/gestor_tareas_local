import 'package:flutter/material.dart';

import '../data/tareas_repository.dart';
import '../models/tarea.dart';

class TareasPage extends StatefulWidget {
  final TareasRepository repositorio;
  const TareasPage({super.key, required this.repositorio});

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  final TextEditingController _tituloController = TextEditingController();

  // El Stream se crea una sola vez aquí, no dentro de build().
  late final Stream<List<Tarea>> _tareas;

  @override
  void initState() {
    super.initState();
    _tareas = widget.repositorio.observarTareas();
  }

  Future<void> _agregarTarea() async {
    try {
      await widget.repositorio.agregar(_tituloController.text);
      _tituloController.clear();
    } on TareaException catch (e) {
      _mensaje(e.mensaje);
    }
  }

  Future<void> _alternarCompletada(Tarea tarea, bool completada) async {
    try {
      await widget.repositorio.cambiarEstado(tarea.id, completada);
    } on TareaException catch (e) {
      _mensaje(e.mensaje);
    }
  }

  Future<void> _editarTarea(Tarea tarea) async {
    final nuevo = await showDialog<String>(
      context: context,
      builder: (_) => _DialogoEditar(tituloInicial: tarea.titulo),
    );
    if (nuevo == null) return;
    try {
      await widget.repositorio.editarTitulo(tarea.id, nuevo);
    } on TareaException catch (e) {
      _mensaje(e.mensaje);
    }
  }

  Future<void> _eliminarTarea(Tarea tarea) async {
    try {
      await widget.repositorio.eliminar(tarea.id);
      _mensaje('Tarea eliminada');
    } on TareaException catch (e) {
      _mensaje(e.mensaje);
    }
  }

  void _mensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de tareas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Nueva tarea',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _agregarTarea(),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _agregarTarea,
              icon: const Icon(Icons.add),
              label: const Text('Agregar tarea'),
            ),
            const SizedBox(height: 12),
            const Text('Mis tareas', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<Tarea>>(
                stream: _tareas,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error al leer la base: ${snapshot.error}'),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final tareas = snapshot.data!;
                  if (tareas.isEmpty) {
                    return const Center(
                        child: Text('Todavía no hay tareas guardadas'));
                  }
                  return ListView.builder(
                    itemCount: tareas.length,
                    itemBuilder: (context, index) {
                      final tarea = tareas[index];
                      return Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: tarea.completada,
                            onChanged: (valor) {
                              if (valor != null) {
                                _alternarCompletada(tarea, valor);
                              }
                            },
                          ),
                          title: Text(
                            tarea.titulo,
                            style: TextStyle(
                              decoration: tarea.completada
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                              'ID: ${tarea.id} · ${tarea.completada ? 'Completada' : 'Pendiente'}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Editar',
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editarTarea(tarea),
                              ),
                              IconButton(
                                tooltip: 'Eliminar',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _eliminarTarea(tarea),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogoEditar extends StatefulWidget {
  final String tituloInicial;
  const _DialogoEditar({required this.tituloInicial});

  @override
  State<_DialogoEditar> createState() => _DialogoEditarState();
}

class _DialogoEditarState extends State<_DialogoEditar> {
  late final TextEditingController _c =
      TextEditingController(text: widget.tituloInicial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar tarea'),
      content: TextField(
        controller: _c,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Título'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _c.text),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
