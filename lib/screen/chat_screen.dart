import 'package:flutter/material.dart';
import '../services/socket_service.dart';
import 'call_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SocketService _socketService = SocketService();
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _socketService.connect();

    // মেসেজ রিসিভ করা
    _socketService.socket.on('receive_message', (data) {
      if (mounted) {
        setState(() {
          messages.add(data);
        });
      }
    });

    // কল রিসিভ করার সিগন্যাল পেলে স্ক্রিনে যাওয়া
    _socketService.socket.on('incoming_call', (data) {
      _navigateToCall(data['channel']);
    });
  }

  void _navigateToCall(String channel) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CallScreen(channelName: channel)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Chat"),
        backgroundColor: const Color(0xFFFF8C42),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              String channelId = "test_channel_123"; // ডাইনামিক আইডি হতে পারে
              _socketService.socket.emit('make_call', {'channel': channelId});
              _navigateToCall(channelId);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(messages[index]['message']),
                subtitle: Text(messages[index]['sender']),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFFF8C42)),
                  onPressed: () {
                    _socketService.sendMessage(_messageController.text, "User");
                    _messageController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
