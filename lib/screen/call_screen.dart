import 'package:flutter/material.dart';
import 'package:agora_uikit/agora_uikit.dart';

class CallScreen extends StatefulWidget {
  final String channelName;
  const CallScreen({super.key, required this.channelName});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late final AgoraClient _client;

  @override
  void initState() {
    super.initState();
    _client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
        appId: "fb92cdc3a2bc47719327cd5d792121d8", // আপনার Agora App ID দিন
        channelName: widget.channelName,
        tempToken: "YOUR_TOKEN", // টেস্ট করার জন্য টেম্প টোকেন
      ),
    );
    _initAgora();
  }

  void _initAgora() async {
    await _client.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Call"),
        backgroundColor: const Color(0xFFFF8C42),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            AgoraVideoViewer(client: _client),
            AgoraVideoButtons(client: _client),
          ],
        ),
      ),
    );
  }
}
