import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CallScreen extends StatefulWidget {
  final String channelName;
  const CallScreen({super.key, required this.channelName});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  int? _remoteUid; // অন্য ইউজারের আইডি
  bool _localUserJoined = false; // আপনি জয়েন করেছেন কি না
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // ১. ক্যামেরা ও মাইক্রোফোন পারমিশন নেওয়া
    await [Permission.microphone, Permission.camera].request();

    // ২. ইঞ্জিন তৈরি করা
    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      const RtcEngineContext(
        appId: "YOUR_AGORA_APP_ID", // আপনার App ID দিন
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    // ৩. ইভেন্ট হ্যান্ডেলার সেট করা (কল কানেক্ট/ডিসকানেক্ট বোঝার জন্য)
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("Local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              debugPrint("Remote user $remoteUid left channel");
              setState(() {
                _remoteUid = null;
              });
            },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          setState(() {
            _localUserJoined = false;
            _remoteUid = null;
          });
        },
      ),
    );

    // ৪. ভিডিও এনাবল করা
    await _engine.enableVideo();
    await _engine.startPreview();

    // ৫. চ্যানেলে জয়েন করা
    await _engine.joinChannel(
      token: "YOUR_TEMP_TOKEN", // আপনার টেম্পোরারি টোকেন
      channelId: widget.channelName,
      uid: 0, // ০ দিলে আগোরা অটোমেটিক একটি আইডি দেবে
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  // ইউজার ইন্টারফেস
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Call')),
      body: Stack(
        children: [
          Center(child: _remoteVideo()), // বড় স্ক্রিনে অন্য ইউজার
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: Center(
                child: _localUserJoined
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
          _toolbar(), // কল কাটার বাটন
        ],
      ),
    );
  }

  // অন্য ইউজারের ভিডিও দেখানোর উইজেট
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    } else {
      return const Text(
        'Waiting for other user...',
        textAlign: TextAlign.center,
      );
    }
  }

  // কল কন্ট্রোল বাটন
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RawMaterialButton(
            onPressed: () => Navigator.pop(context),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
            child: const Icon(Icons.call_end, color: Colors.white, size: 35.0),
          ),
        ],
      ),
    );
  }
}
