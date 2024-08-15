import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubjectDetailScreen extends StatefulWidget {
  final String subjectId;
  final String subjectName;

  SubjectDetailScreen({required this.subjectId, required this.subjectName});

  @override
  _SubjectDetailScreenState createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  final _controller = TextEditingController();

  void _addGrade() async {
    final grade = int.tryParse(_controller.text);
    if (grade == null || grade < 0 || grade > 100) return;

    final subjectRef = FirebaseFirestore.instance.collection('materias').doc(widget.subjectId);
    final subjectDoc = await subjectRef.get();

    List<dynamic> grades = subjectDoc['calificaciones'] ?? [];

    if (grades.length < 3) {
      grades.add(grade);
      await subjectRef.update({'calificaciones': grades});
      _controller.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solo puedes agregar hasta 3 calificaciones')),
      );
    }
  }

  void _editGrade(int index, int oldGrade) async {
    final newGrade = await _showEditGradeDialog(oldGrade);
    if (newGrade == null) return;

    final subjectRef = FirebaseFirestore.instance.collection('materias').doc(widget.subjectId);
    final subjectDoc = await subjectRef.get();
    List<dynamic> grades = subjectDoc['calificaciones'] ?? [];

    grades[index] = newGrade;
    await subjectRef.update({'calificaciones': grades});
  }

  void _deleteGrade(int index) async {
    final subjectRef = FirebaseFirestore.instance.collection('materias').doc(widget.subjectId);
    final subjectDoc = await subjectRef.get();
    List<dynamic> grades = subjectDoc['calificaciones'] ?? [];

    grades.removeAt(index);
    await subjectRef.update({'calificaciones': grades});
  }

  Future<int?> _showEditGradeDialog(int oldGrade) async {
    final TextEditingController controller = TextEditingController(text: oldGrade.toString());

    return await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Editar Calificación'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Nueva calificación'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final newGrade = int.tryParse(controller.text);
              if (newGrade != null && newGrade >= 0 && newGrade <= 100) {
                Navigator.of(ctx).pop(newGrade);
              }
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la Materia'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Materia: ${widget.subjectName}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('materias')
                  .doc(widget.subjectId)
                  .snapshots(),
              builder: (ctx, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final subjectData = snapshot.data!;
                final grades = List.from(subjectData['calificaciones'] ?? []);
                return ListView.builder(
                  itemCount: grades.length,
                  itemBuilder: (ctx, index) => ListTile(
                    title: Text('Calificación: ${grades[index]}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editGrade(index, grades[index]),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteGrade(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: 'Agregar Calificación'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                ElevatedButton(
                  onPressed: _addGrade,
                  child: Text('Agregar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
