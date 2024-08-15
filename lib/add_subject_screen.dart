import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddSubjectScreen extends StatefulWidget {
  @override
  _AddSubjectScreenState createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final _controller = TextEditingController();

  void _addSubject() {
    final subjectName = _controller.text;
    if (subjectName.isEmpty) return;

    // Agregar materia con un campo 'calificaciones' como una lista vacía
    FirebaseFirestore.instance.collection('materias').add({
      'nombre': subjectName,
      'calificaciones': [], // Inicializar con una lista vacía
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Materia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Nombre de la materia'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addSubject,
              child: Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }
}
