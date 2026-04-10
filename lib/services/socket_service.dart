import 'dart:io';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect() {
    socket = IO.io(
      Platform.isAndroid
          ? 'http://192.168.0.150:3000'
          : 'http://192.168.0.150:3000',
      // Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000',
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      },
    );
    socket.connect();

    socket.onConnect((_) {
      print('✅ Connected to Socket Server');
    });

    socket.onConnectError((data) {
      print('❌ Connection Error: $data');
    });
  }

  void sendMessage(String msg, String sender) {
    socket.emit('send_message', {'message': msg, 'sender': sender});
  }

  void dispose() {
    socket.disconnect();
  }
}
