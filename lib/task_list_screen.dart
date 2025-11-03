import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _itemsCollection = FirebaseFirestore.instance.collection('tarefas');
  final _textController = TextEditingController();
  int _selectedPriority = 2;
  File? _selectedImage;
  XFile? _webSelectedImage;
  final ImagePicker _picker = ImagePicker();

  // -------------------- PICK DE IMAGEM --------------------
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    if (kIsWeb) {
      setState(() => _webSelectedImage = picked);
    } else {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  // -------------------- UPLOAD DE IMAGEM --------------------
 Future<String?> _uploadImage() async {
  try {
    Uint8List? data;
    String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    if (kIsWeb && _webSelectedImage != null) {
      data = await _webSelectedImage!.readAsBytes();
    } else if (!kIsWeb && _selectedImage != null) {
      data = await _selectedImage!.readAsBytes();
    }

    if (data == null) return null;

    final ref = FirebaseStorage.instance.ref().child('tarefas_imagens/$fileName');
    await ref.putData(data);
    return await ref.getDownloadURL();
  } catch (e) {
    debugPrint('Erro ao enviar imagem: $e');
    return null;
  }
}


  // -------------------- ADICIONAR TAREFA --------------------
  Future<void> _addItem() async {
    if (_textController.text.trim().isEmpty &&
        _selectedImage == null &&
        _webSelectedImage == null) {
      return;
    }

    final userId = FirebaseAuth.instance.currentUser!.uid;

    String? imageUrl;
    if (_selectedImage != null || _webSelectedImage != null) {
      imageUrl = await _uploadImage();
    }

    await _itemsCollection.add({
      'title': _textController.text.trim().isEmpty
          ? '(Sem título)'
          : _textController.text.trim(),
      'isDone': false,
      'priority': _selectedPriority,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': userId,
      'imageUrl': imageUrl,
    });

    _textController.clear();
    setState(() {
      _selectedImage = null;
      _webSelectedImage = null;
      _selectedPriority = 2;
    });
  }

  // -------------------- EDITAR / EXCLUIR / TOGGLE --------------------
  Future<void> _toggleDone(String docId, bool currentValue) async {
    await _itemsCollection.doc(docId).update({'isDone': !currentValue});
  }

  Future<void> _deleteItem(String docId) async {
    await _itemsCollection.doc(docId).delete();
  }

  Future<void> _editItem(String docId, String currentTitle) async {
    final controller = TextEditingController(text: currentTitle);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Tarefa'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nome da tarefa'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await _itemsCollection.doc(docId).update({
                  'title': controller.text.trim(),
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  // -------------------- AUXILIARES --------------------
  Icon _getPriorityIcon(int priority) {
    switch (priority) {
      case 3:
        return const Icon(Icons.flag, color: Colors.redAccent);
      case 2:
        return const Icon(Icons.flag, color: Colors.blueAccent);
      default:
        return const Icon(Icons.flag, color: Colors.green);
    }
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 3:
        return 'Alta';
      case 2:
        return 'Média';
      default:
        return 'Baixa';
    }
  }

  // -------------------- INTERFACE --------------------
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de texto e imagem
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (kIsWeb && _webSelectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _webSelectedImage!.path,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: 'Digite uma nova tarefa',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _addItem(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                      ),
                      child: const Text('Adicionar'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Adicionar Imagem'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text('Prioridade:'),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: _selectedPriority,
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Baixa')),
                        DropdownMenuItem(value: 2, child: Text('Média')),
                        DropdownMenuItem(value: 3, child: Text('Alta')),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedPriority = value ?? 2);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Lista de tarefas
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _itemsCollection
                  .where('userId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar tarefas'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                      child: Text('Nenhuma tarefa encontrada.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final title = data['title'] ?? '';
                    final isDone = data['isDone'] ?? false;
                    final priority = data['priority'] ?? 2;
                    final imageUrl = data['imageUrl'];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : _getPriorityIcon(priority),
                        title: GestureDetector(
                          onTap: () => _editItem(doc.id, title),
                          child: Text(
                            title,
                            style: TextStyle(
                              decoration:
                                  isDone ? TextDecoration.lineThrough : null,
                              color: isDone ? Colors.grey : Colors.black,
                            ),
                          ),
                        ),
                        subtitle:
                            Text('Prioridade: ${_getPriorityText(priority)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: isDone,
                              onChanged: (_) => _toggleDone(doc.id, isDone),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteItem(doc.id),
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
    );
  }

  @override
  void initState() {
    super.initState();
    print('Usuário logado: ${FirebaseAuth.instance.currentUser?.uid}');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
