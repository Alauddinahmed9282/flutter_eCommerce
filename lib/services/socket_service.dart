import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect() {
    socket = IO.io('http://YOUR_SERVER_IP:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();
  }

  void sendMessage(String msg, String sender) {
    socket.emit('send_message', {'message': msg, 'sender': sender});
  }

  void dispose() {
    socket.disconnect();
  }
}
