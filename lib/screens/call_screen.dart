import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_cloud_meetings/screens/preview_page.dart';
import 'package:uuid/uuid.dart';

class CallScreen extends ConsumerStatefulWidget {
  static const String route = '/call_screen';
  final String? name;
  final String? email;
  final String? photoUrl;
  const CallScreen(
      {Key? key,
      required this.name,
      required this.email,
      required this.photoUrl})
      : super(key: key);

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('join or create Meeting'),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(40),
              child: TextField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter Meeting Id'),
                controller: _controller,
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    Navigator.pushNamed(context, PreviewPage.route, arguments: {
                      'name': widget.name,
                      'email': widget.email,
                      'photoUrl': widget.photoUrl,
                      'meetingId': _controller.text.toString().trim(),
                    });
                  }
                },
                child: const Text("join Meeting")),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, PreviewPage.route, arguments: {
                    'name': widget.name,
                    'email': widget.email,
                    'photoUrl': widget.photoUrl,
                    'meetingId': const Uuid().v4(),
                  });
                },
                child: const Text("create Meeting")),
          ],
        )));
  }
}
