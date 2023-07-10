import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'meeting_page.dart';

class PreviewPage extends ConsumerStatefulWidget {
  static const String route = '/preview_page';
  final String? name;
  final String? email;
  final String? photoUrl;
  final String meetingId;
  const PreviewPage(
      {super.key,
      required this.meetingId,
      required this.name,
      required this.email,
      required this.photoUrl});

  @override
  ConsumerState<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends ConsumerState<PreviewPage> {
  bool mic = true;
  bool cam = true;
  late MediaStream stream;
  final _localRenderer = RTCVideoRenderer();
  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
    init();
  }

  init() async {
    stream = await navigator.mediaDevices
        .getUserMedia({'video': true, 'audio': true});
    _localRenderer.srcObject = stream;
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _localRenderer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
            color: Colors.black,
            child: Stack(children: [
              Container(
                width: kIsWeb
                    ? MediaQuery.of(context).size.width * 0.2
                    : MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.4,
                color: Colors.red.withOpacity(cam ? 0 : 1),
                child: cam
                    ? RTCVideoView(_localRenderer)
                    : const Center(
                        child: Icon(
                          Icons.videocam_off,
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
              ),
              Positioned(
                  left: 5,
                  bottom: 5,
                  child: Icon(
                    mic ? Icons.mic : Icons.mic_off,
                    color: Colors.white,
                  )),
            ]),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () {
                    mic = !mic;
                    _localRenderer.srcObject!.getAudioTracks().first.enabled =
                        mic;
                    setState(() {});
                  },
                  icon: Icon(mic ? Icons.mic : Icons.mic_off)),
              IconButton(
                  onPressed: () {
                    cam = !cam;
                    _localRenderer.srcObject!.getVideoTracks().first.enabled =
                        cam;

                    setState(() {});
                  },
                  icon: Icon(cam ? Icons.videocam : Icons.videocam_off)),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, MeetingPage.route, arguments: {
                      'meetingId': widget.meetingId,
                      'micOn': mic,
                      'camOn': cam,
                      'name': widget.name ?? "",
                      'email': widget.email ?? "",
                      'photoUrl': widget.photoUrl ?? "",
                      'stream': stream,
                    });
                  },
                  child: const Text("join"))
            ],
          )
        ],
      ),
    );
  }
}
