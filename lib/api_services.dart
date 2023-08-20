import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:online_cloud_meetings/screens/meeting_page.dart';

import 'models/user.dart';

String baseUrl = "https://online-meetings.me:3000";

class ApiServices {
  static Future<GoogleSignInAccount?> signInWithGoogle(
      BuildContext context) async {
    try {
      // if (kIsWeb) {
      final googleSignIn = GoogleSignIn(
          clientId:
              "1028824509975-ukuue07e91tmne4ij6sb7dt4ed3r3ick.apps.googleusercontent.com");
      if (await googleSignIn.isSignedIn()) googleSignIn.signOut();
      final GoogleSignInAccount? user = await googleSignIn.signIn();
      log(user!.displayName!);
      log(user.email);
      log(user.photoUrl.toString());
      return user;
      // } else if (Platform.isAndroid) {
      //

      //
      //   final GoogleSignInAccount? user = await googleSignIn.signIn();
      //   if (user == null) return null;
      //   user.authentication;
      //   return user;
      // }
      // return null;
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.toString()),
        ),
      );
      print(err.toString());
    }
    return null;
  }

  static Future<User?> getByPeerId({required String peerId}) async {
    try {
      var response =
          await http.post(Uri.parse("$baseUrl/api/user/peerId"), body: {
        "peerId": peerId,
      });
      if (response.statusCode == 200) {
        var data = decodeJson(response.body);
        var userData = data['message'];
        return User(
            peerId: userData['peerId'],
            streamId: userData['streamId'],
            camera: userData['cam'] == 1 ? true : false,
            mic: userData['mic'] == 1 ? true : false,
            name: userData['name'],
            photoUrl: userData['photoUrl'],
            email: userData['email']);
      } else {
        return null;
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  static Future<User?> getByStreamId({required String streamId}) async {
    try {
      var response =
          await http.post(Uri.parse("$baseUrl/api/user/streamId"), body: {
        "streamId": streamId.toString(),
      });
      if (response.statusCode == 200) {
        var data = decodeJson(response.body);
        var userData = data['message'];
        return User(
            peerId: userData['peerId'],
            streamId: userData['streamId'],
            camera: userData['cam'] == 1 ? true : false,
            mic: userData['mic'] == 1 ? true : false,
            name: userData['name'],
            photoUrl: userData['photoUrl'],
            email: userData['email']);
      } else {
        return null;
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  static Future<String> storePeer({
    required String email,
    required String name,
    required String peerId,
    required String streamId,
    required String photoUrl,
    required bool mic,
    required bool cam,
  }) async {
    var response =
        await http.post(Uri.parse("$baseUrl/api/user/store_peer"), body: {
      "email": email,
      "name": name,
      "peerId": peerId,
      "streamId": streamId,
      "photoUrl": photoUrl,
      "mic": mic ? "1" : "0",
      "cam": cam ? "1" : "0"
    });
    if (response.statusCode == 200) {
      print(response.body);
      if (json.decode(response.body)['message'].contains('duplicate key')) {
        return 'user already exists';
      }
      if (json
          .decode(response.body)['message']
          .contains('created successfully')) {
        return json.decode(response.body)['message'];
      }
      return json.decode(response.body)['message'];
    } else {
      print(response.body);

      return 'error occurred';
    }
  }
}

decodeJson(String body) {
  return json.decode(body);
}

setUser(WidgetRef ref, User user) {
  HashMap<String, User> map =
      HashMap.from(ref.read(usersProvider.notifier).state);
  map[user.streamId] = user;
  ref.read(usersProvider.notifier).state = map;
}

setStream(WidgetRef ref, RTCVideoRenderer renderer) {
  HashMap<String, RTCVideoRenderer> map =
      HashMap.from(ref.read(peersProvider.notifier).state);
  map[renderer.srcObject!.id] = renderer;
  ref.read(peersProvider.notifier).state = map;
}

removeUser(WidgetRef ref, String streamId) {
  HashMap<String, User> map =
      HashMap.from(ref.read(usersProvider.notifier).state);
  map.remove(streamId);
  ref.read(usersProvider.notifier).state = map;
}

removeStream(WidgetRef ref, String streamId) {
  HashMap<String, RTCVideoRenderer> map =
      HashMap.from(ref.read(peersProvider.notifier).state);
  map.remove(streamId);
  ref.read(peersProvider.notifier).state = map;
}
