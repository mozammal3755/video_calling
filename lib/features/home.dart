import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:calling_app/features/call.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final channelController = TextEditingController();
  ClientRoleType? role = ClientRoleType.clientRoleBroadcaster;

  @override
  void dispose() {
    // TODO: implement dispose
    channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: channelController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                    hintText: 'Channel name'),
              ),
              RadioListTile(
                  title: const Text('Broadcaster'),
                  value: ClientRoleType.clientRoleBroadcaster,
                  groupValue: role,
                  onChanged: (ClientRoleType? value) {
                    setState(() {
                      role = value;
                    });
                  }),
              RadioListTile(
                  title: const Text('Audience'),
                  value: ClientRoleType.clientRoleAudience,
                  groupValue: role,
                  onChanged: (ClientRoleType? value) {
                    setState(() {
                      role = value;
                    });
                  }),
              ElevatedButton(
                onPressed: onJoin,
                child: const Text('Join Call'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onJoin() async {
    if (channelController.text.isNotEmpty) {
      await [Permission.microphone, Permission.camera].request();
      await Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(
              channelName: channelController.text,
              role: role,
            ),
          ));
    }
  }
}
