import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../models/message.dart';
import 'meeting_page.dart';

class MessageScreen extends ConsumerStatefulWidget {
  static const String route = '/message_screen';
  final String roomId;
  final IO.Socket socket;
  final String name;
  const MessageScreen(
      {required this.name,
      super.key,
      required this.socket,
      required this.roomId});

  @override
  ConsumerState<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen> {
  final _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Message> messages = ref.watch(messagesProvider);
    return Scaffold(
      appBar: AppBar(),
      body: messages.isEmpty
          ? const Center(
              child: Text('No message'),
            )
          : SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: ((context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(messages[index].userId),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                                "${messages[index].time.hour}:${messages[index].time.minute}")
                          ]),
                          Text(messages[index].message)
                        ],
                      ),
                    );
                  })),
            ),
      bottomSheet: Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 5),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'send message',
                )),
          ),
          IconButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  String value = _controller.text.trim();
                  _controller.clear();
                  ref.read(messagesProvider.notifier).state = [
                    Message(value, "You"),
                    ...ref.read(messagesProvider.notifier).state
                  ];
                  widget.socket.emit('send-message', [
                    widget.roomId,
                    json.encode({'message': value, 'name': widget.name})
                  ]);
                }
              },
              icon: const Icon(Icons.send)),
        ]),
      ),
    );
  }
}
