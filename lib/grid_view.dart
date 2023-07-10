import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'models/user.dart';
import 'screens/meeting_page.dart';

class GriDVideos extends ConsumerStatefulWidget {
  final IO.Socket socket;
  const GriDVideos({
    super.key,
    required this.socket,
  });

  @override
  ConsumerState<GriDVideos> createState() => _GriDVideosState();
}

class _GriDVideosState extends ConsumerState<GriDVideos> {
  @override
  Widget build(BuildContext context) {
    List<User> users = ref.watch(usersProvider).values.toList();
    List<RTCVideoRenderer> renderer = ref.watch(peersProvider).values.toList();
    return GridView.builder(
      itemCount: renderer.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: kIsWeb ? 5 : 3),
      itemBuilder: (context, index) {
        User? currentUser;
        if (index < users.length) currentUser = users[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.1,
            height: MediaQuery.of(context).size.height * 0.2,
            decoration: BoxDecoration(
                color: Colors.black, borderRadius: BorderRadius.circular(10)),
            child: currentUser == null
                ? RTCVideoView(renderer[index])
                : Stack(children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(255, 90, 90, 90)
                            .withOpacity(currentUser.camera ? 0 : 1),
                      ),
                      child: currentUser.camera
                          ? RTCVideoView(renderer[index])
                          : Center(
                              child: SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: users[index].photoUrl.isEmpty
                                      ? const Icon(Icons.videocam_off)
                                      : CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              users[index].photoUrl),
                                        ))),
                    ),
                    Positioned(
                        left: 5,
                        bottom: 5,
                        child: Icon(
                          currentUser.mic ? Icons.mic : Icons.mic_off,
                          color: Colors.white,
                        )),
                    Positioned(
                        left: 30, bottom: 5, child: Text(currentUser.name)),
                  ]),
          ),
        );
      },
    );
  }
}
