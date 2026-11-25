import 'package:flutter/material.dart';

import 'data/database.dart';
import 'data/tareas_repository.dart';
import 'screens/tareas_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = TareasRepository(AppDatabase.abrir());
  runApp(GestorTareasApp(repositorio: repo));
}

class GestorTareasApp extends StatefulWidget {
  final TareasRepository repositorio;
  const GestorTareasApp({super.key, required this.repositorio});

  @override
  State<GestorTareasApp> createState() => _GestorTareasAppState();
}

class _GestorTareasAppState extends State<GestorTareasApp> {
  @override
  void dispose() {
    // Libera la conexión a SQLite al destruir la app.
    widget.repositorio.cerrar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de tareas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: TareasPage(repositorio: widget.repositorio),
    );
  }
}
