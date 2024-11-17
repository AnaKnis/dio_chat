import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio_chat/pages/chat_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? userName;

  void _createChatRoom() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _roomNameController =
            TextEditingController();
        return AlertDialog(
          title: const Text('Criar nova sala'),
          content: TextField(
            controller: _roomNameController,
            decoration: const InputDecoration(
              labelText: 'Nome da sala',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newRoom = _roomNameController.text.trim();
                if (newRoom.isNotEmpty) {
                  await _firestore.collection('chat_rooms').add({
                    'name': newRoom,
                    'created_at': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Criar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha uma Sala'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Informe seu nome',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                setState(() {
                  userName = text;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chat_rooms')
                    .orderBy('created_at')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final rooms = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      return ListTile(
                        title: Text(room['name']),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => _enterChatRoom(room['name']),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              onPressed: _createChatRoom,
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  void _enterChatRoom(String roomName) {
    if (userName == null || userName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira seu nome primeiro.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(roomName: roomName, userName: userName!),
      ),
    );
  }
}
