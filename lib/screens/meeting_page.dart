import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerdart/peerdart.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../api_services.dart';
import '../grid_view.dart';
import '../models/message.dart';
import '../models/user.dart';
import 'message_screen.dart';

final messagesProvider = StateProvider<List<Message>>((ref) => []);
final peersProvider = StateProvider<HashMap<String, RTCVideoRenderer>>(
    (ref) => HashMap<String, RTCVideoRenderer>());
final usersProvider =
    StateProvider<HashMap<String, User>>((ref) => HashMap<String, User>());

class MeetingPage extends ConsumerStatefulWidget {
  static const String route = '/meeting_screen';
  final String name;
  final String email;
  final String photoUrl;
  final bool micOn;
  final bool camOn;
  final MediaStream stream;
  final String meetingId;
  const MeetingPage(
      {Key? key,
      required this.meetingId,
      required this.micOn,
      required this.camOn,
      required this.name,
      required this.email,
      required this.photoUrl,
      required this.stream})
      : super(key: key);

  @override
  ConsumerState<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends ConsumerState<MeetingPage> {
  late bool camera = true;
  late bool mic = true;
  final IO.Socket socket = IO.io(
      "https://online-meetings-app-backend.onrender.com",
      // "http://localhost:5000/",
      <String, dynamic>{
        "transports": ["websocket"],
        "autoConnect": false
      });
  final TextEditingController _controller = TextEditingController();
  final Peer peer = Peer(options: PeerOptions(debug: LogLevel.All));
  final _localRenderer = RTCVideoRenderer();
  String? peerId;

  Future<void> connect() async {
    await socket.connect();
    socket
        .onConnect((_) => socket.emit('join-room', [widget.meetingId, peerId]));
    socket.onConnectError((data) => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(data.toString()))));
  }

  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
    camera = widget.camOn;
    mic = widget.micOn;
    peer.on("open").listen((id) async {
      _localRenderer.srcObject = widget.stream;
      setState(() {});
      peerId = peer.id;
      await ApiServices.storePeer(
          email: widget.email,
          name: widget.name,
          peerId: peerId!,
          streamId: widget.stream.id,
          photoUrl: widget.photoUrl,
          mic: mic,
          cam: camera);
      connect();
      peer.on<MediaConnection>('call').listen((call) {
        call.answer(widget.stream);
        call.on<MediaStream>('stream').listen((event) async {
          final RTCVideoRenderer _remoterenderer = RTCVideoRenderer();
          await _remoterenderer.initialize();
          _remoterenderer.srcObject = event;
          setStream(ref, _remoterenderer);
          User? user = await ApiServices.getByStreamId(streamId: event.id);
          if (user != null) {
            setUser(ref, user);
          }
        });
      });
      socket.on('user-connected', (userId) async {
        var call = peer.call(userId, widget.stream);
        call.on<MediaStream>('stream').listen((event) async {
          final RTCVideoRenderer _remoterenderer = RTCVideoRenderer();
          await _remoterenderer.initialize();
          _remoterenderer.srcObject = event;
          setStream(ref, _remoterenderer);
          ApiServices.getByStreamId(streamId: event.id).then((value) {
            if (value != null) {
              setUser(ref, value);
            }
          });
        });
      });
      socket.on('user-disconnected', (userId) async {
        var streamId =
            (await ApiServices.getByPeerId(peerId: userId))!.streamId;
        removeStream(ref, streamId);
        removeUser(ref, streamId);
      });

      socket.on('update-user', (eventId) async {
        User? user = await ApiServices.getByStreamId(streamId: eventId);
        if (user != null) {
          setUser(ref, user);
        }
      });
      socket.on('message', (value) {
        var data = json.decode(value);
        log(value);
        Message message = Message(data['message'], data['name']);
        ref.read(messagesProvider.notifier).state = [
          message,
          ...ref.read(messagesProvider.notifier).state
        ];
      });
    });
  }

  @override
  void dispose() {
    peer.dispose();
    _controller.dispose();
    _localRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, MessageScreen.route, arguments: {
                'roomId': widget.meetingId,
                'socket': socket,
                'name': widget.name,
              });
            },
            child: const Icon(Icons.chat)),
        appBar: AppBar(
          title: Row(
            children: [
              const Text("MeetingId"),
              IconButton(
                  onPressed: () async {
                    await Clipboard.setData(
                        ClipboardData(text: widget.meetingId.toString()));
                  },
                  icon: const Icon(Icons.copy))
            ],
          ),
        ),
        body: Stack(
          children: [
            ref.watch(peersProvider).isEmpty
                ? const Center(child: Text("waiting for others"))
                : GriDVideos(
                    socket: socket,
                  ),
            Positioned(
                left: 20,
                bottom: 20,
                child: Container(
                  width: kIsWeb ? 200 : 100,
                  height: kIsWeb ? 200 : 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black,
                  ),
                  child: Stack(children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(255, 90, 90, 90)
                            .withOpacity(camera ? 0 : 1),
                      ),
                      child: camera
                          ? RTCVideoView(_localRenderer)
                          : Center(
                              child: SizedBox(
                                  width: kIsWeb ? 100 : 50,
                                  height: kIsWeb ? 100 : 50,
                                  child: widget.photoUrl.isEmpty
                                      ? const Icon(Icons.videocam_off)
                                      : CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(widget.photoUrl),
                                        ))),
                    ),
                    Positioned(
                        left: 5,
                        bottom: 5,
                        child: Icon(
                          mic ? Icons.mic : Icons.mic_off,
                          color: Colors.white,
                        )),
                    const Positioned(left: 30, bottom: 5, child: Text("You")),
                  ]),
                )),
            Positioned(
                left: kIsWeb ? 300 : 200,
                bottom: 10,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () async {
                          mic = !mic;
                          widget.stream.getAudioTracks().first.enabled = mic;
                          setState(() {});
                          await ApiServices.storePeer(
                              email: widget.email,
                              name: widget.name,
                              peerId: peerId!,
                              streamId: widget.stream.id,
                              photoUrl: widget.photoUrl,
                              mic: mic,
                              cam: camera);
                          socket.emit('user-updated',
                              [widget.meetingId, widget.stream.id]);
                        },
                        icon: Icon(mic ? Icons.mic : Icons.mic_off)),
                    IconButton(
                        onPressed: () async {
                          camera = !camera;
                          widget.stream.getVideoTracks().first.enabled = camera;
                          setState(() {});
                          await ApiServices.storePeer(
                              email: widget.email,
                              name: widget.name,
                              peerId: peerId!,
                              streamId: widget.stream.id,
                              photoUrl: widget.photoUrl,
                              mic: mic,
                              cam: camera);
                          socket.emit('user-updated',
                              [widget.meetingId, widget.stream.id]);
                        },
                        icon:
                            Icon(camera ? Icons.videocam : Icons.videocam_off))
                  ],
                ))
          ],
        ));
  }
}
