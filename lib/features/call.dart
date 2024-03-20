import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

import '../utils/config.dart';

class CallScreen extends StatefulWidget {
  final ClientRoleType? role;
  final String? channelName;
  const CallScreen({super.key, this.channelName, this.role});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  List<int> remoteUids = [];
  List<String> userInfo = [];
  bool muted = false;
  bool viewPanel = false;
  late RtcEngine rtcEngine;

  @override
  void initState() {
    // TODO: implement initState
    initialize();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    remoteUids.clear();
    rtcEngine.leaveChannel();
    rtcEngine.disableVideo();
    super.dispose();
  }

  Future<void> initialize() async {
    if (Config.appId.isEmpty) {
      setState(() {
        userInfo.add('value');
      });
      return;
    }

    //initAgora rtc
    rtcEngine = createAgoraRtcEngine();
    await rtcEngine.initialize(RtcEngineContext(appId: Config.appId));
    await rtcEngine.enableVideo();
    await rtcEngine.setClientRole(role: widget.role!);
    await rtcEngine
        .setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
    addEvenHandlers();
    VideoEncoderConfiguration config = const VideoEncoderConfiguration();
    // config.dimensions = const VideoDimensions(width: 1920, height: 1080);
    await rtcEngine.setVideoEncoderConfiguration(config);
    await rtcEngine.joinChannel(
        token: Config.rtcToken,
        channelId: widget.channelName!,
        uid: 0,
        options: const ChannelMediaOptions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
      ),
    );
  }

  RtcEngineEventHandler addEvenHandlers() {
    return RtcEngineEventHandler(
      // Occurs when the network connection state changes
      onConnectionStateChanged: (RtcConnection connection,
          ConnectionStateType state, ConnectionChangedReasonType reason) {
        if (reason ==
            ConnectionChangedReasonType.connectionChangedLeaveChannel) {
          remoteUids.clear();
          // isJoined = false;
        }
        // Notify the UI
        Map<String, dynamic> eventArgs = {};
        eventArgs["connection"] = connection;
        eventArgs["state"] = state;
        eventArgs["reason"] = reason;
        // eventCallback("onConnectionStateChanged", eventArgs);
      },
      // Occurs when a local user joins a channel
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        // isJoined = true;
        // messageCallback(
        //     "Local user uid:${connection.localUid} joined the channel");
        // Notify the UI
        Map<String, dynamic> eventArgs = {};
        eventArgs["connection"] = connection;
        eventArgs["elapsed"] = elapsed;
        // eventCallback("onJoinChannelSuccess", eventArgs);
      },
      // Occurs when a remote user joins the channel
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        remoteUids.add(remoteUid);
        // messageCallback("Remote user uid:$remoteUid joined the channel");
        // Notify the UI
        Map<String, dynamic> eventArgs = {};
        eventArgs["connection"] = connection;
        eventArgs["remoteUid"] = remoteUid;
        eventArgs["elapsed"] = elapsed;
        // eventCallback("onUserJoined", eventArgs);
      },
      // Occurs when a remote user leaves the channel
      onUserOffline: (RtcConnection connection, int remoteUid,
          UserOfflineReasonType reason) {
        remoteUids.remove(remoteUid);
        // messageCallback("Remote user uid:$remoteUid left the channel");
        // Notify the UI
        Map<String, dynamic> eventArgs = {};
        eventArgs["connection"] = connection;
        eventArgs["remoteUid"] = remoteUid;
        eventArgs["reason"] = reason;
        // eventCallback("onUserOffline", eventArgs);
      },
    );
  }

  // void addEvenHandlers() {
  //   RtcEngineEventHandler() {}
  //   ;
  // }
}
