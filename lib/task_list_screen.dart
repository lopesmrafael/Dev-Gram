import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _photosCollection = FirebaseFirestore.instance.collection('fotos');
  final _captionController = TextEditingController();
  File? _selectedImage;
  XFile? _webSelectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    if (kIsWeb) {
      setState(() => _webSelectedImage = picked);
    } else {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  String _getLocalImagePath() {
    if (kIsWeb && _webSelectedImage != null) {
      return _webSelectedImage!.path;
    } else if (!kIsWeb && _selectedImage != null) {
      return _selectedImage!.path;
    }
    return '';
  }

  Future<void> _addPhoto() async {
    if (_selectedImage == null && _webSelectedImage == null) {
      return;
    }

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final localPath = _getLocalImagePath();
      final fileName = 'imagem_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = 'fotos/$fileName';
      
      await _photosCollection.add({
        'userId': userId,
        'imageUrl': localPath,
        'storagePath': storagePath,
        'timestamp': FieldValue.serverTimestamp(),
        'sharedWith': [],
      });

      _captionController.clear();
      setState(() {
        _selectedImage = null;
        _webSelectedImage = null;
      });
    } catch (e) {
      debugPrint('Erro ao adicionar foto: $e');
    }
  }

  Future<void> _deletePhoto(DocumentSnapshot doc) async {
    try {
      await doc.reference.delete();
    } catch (e) {
      debugPrint('Erro ao deletar foto: $e');
    }
  }

  Future<void> _sharePhoto(DocumentSnapshot doc) async {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[800],
        title: const Text('Compartilhar Foto', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Email do usuário',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final data = doc.data() as Map<String, dynamic>;
                final sharedWith = List<String>.from(data['sharedWith'] ?? []);
                if (!sharedWith.contains(controller.text.trim())) {
                  sharedWith.add(controller.text.trim());
                  await doc.reference.update({'sharedWith': sharedWith});
                }
              }
              Navigator.pop(context);
            },
            child: const Text('Compartilhar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        title: const Text('DevGram', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[850],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _photosCollection
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.grey[300]),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          
          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Nenhuma foto ainda\nToque no + para adicionar',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final photos = snapshot.data!.docs;
          
          if (photos.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma foto ainda\nToque no + para adicionar',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final doc = photos[index];
              final photo = doc.data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () => _showPhotoDetail(context, photo),
                onLongPress: () => _sharePhoto(doc),
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                      ),
                      child: kIsWeb 
                          ? Image.network(
                              photo['imageUrl'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[700],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                );
                              },
                            )
                          : Image.file(
                              File(photo['imageUrl']),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[700],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                    ),
                    if (photo['userId'] == userId)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _deletePhoto(doc),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPhotoDialog(context),
        backgroundColor: Colors.grey[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showPhotoDetail(BuildContext context, Map<String, dynamic> photo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.grey[800],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            kIsWeb 
                ? Image.network(
                    photo['imageUrl'],
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[700],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 60,
                        ),
                      );
                    },
                  )
                : Image.file(
                    File(photo['imageUrl']),
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[700],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 60,
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  void _showAddPhotoDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[800],
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedImage != null || _webSelectedImage != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb && _webSelectedImage != null
                      ? Image.network(_webSelectedImage!.path, height: 200, fit: BoxFit.cover)
                      : Image.file(_selectedImage!, height: 200, fit: BoxFit.cover),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                            _webSelectedImage = null;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _addPhoto();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[500],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Publicar',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: () async {
                    await _pickImage();
                    setModalState(() {});
                  },
                  icon: const Icon(Icons.photo_camera, color: Colors.white, size: 24),
                  label: const Text(
                    'Selecionar Foto',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
