// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class User {
  final String peerId;
  final String name;
  final String email;
  final String photoUrl;
  final String streamId;
  final bool camera;
  final bool mic;

  User({
    required this.peerId,
    required this.streamId,
    required this.camera,
    required this.mic,
    required this.name,
    required this.photoUrl,
    required this.email,
  });

  User copyWith(
      {String? peerId,
      String? streamId,
      bool? camera,
      bool? mic,
      String? name,
      String? photoUrl,
      String? email}) {
    return User(
      peerId: peerId ?? this.peerId,
      streamId: streamId ?? this.streamId,
      camera: camera ?? this.camera,
      mic: mic ?? this.mic,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'peerId': peerId,
      'streamId': streamId,
      'camera': camera,
      'mic': mic,
      'name': name,
      'photoUrl': photoUrl,
      'email': email
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      peerId: map['peerId'] as String,
      streamId: map['streamId'] as String,
      camera: map['camera'] as bool,
      mic: map['mic'] as bool,
      name: map['name'] as String,
      photoUrl: map['photoUrl'] as String,
      email: map['email'] as String,
    );
  }
  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);
}
