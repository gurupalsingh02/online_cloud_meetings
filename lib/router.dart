import 'package:flutter/material.dart';
import 'package:online_cloud_meetings/screens/call_screen.dart';
import 'package:online_cloud_meetings/screens/login_screen.dart';
import 'package:online_cloud_meetings/screens/meeting_page.dart';
import 'package:online_cloud_meetings/screens/message_screen.dart';
import 'package:online_cloud_meetings/screens/preview_page.dart';

import 'screens/error_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case LoginScreen.route:
      return MaterialPageRoute(builder: (context) => const LoginScreen());

    case CallScreen.route:
      final arguments = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
          builder: (context) => CallScreen(
                email: arguments['email'],
                name: arguments['name'],
                photoUrl: arguments['photoUrl'],
              ));
    case MessageScreen.route:
      final arguments = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
          builder: (context) => MessageScreen(
                roomId: arguments['roomId'],
                name: arguments['name'],
                socket: arguments['socket'],
              ));
    case PreviewPage.route:
      final arguments = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
          builder: (context) => PreviewPage(
                email: arguments['email'],
                meetingId: arguments['meetingId'],
                name: arguments['name'],
                photoUrl: arguments['photoUrl'],
              ));

    case MeetingPage.route:
      final arguments = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
          builder: (context) => MeetingPage(
                camOn: arguments['camOn'],
                email: arguments['email'],
                meetingId: arguments['meetingId'],
                micOn: arguments['micOn'],
                name: arguments['name'],
                photoUrl: arguments['photoUrl'],
                stream: arguments['stream'],
              ));

    default:
      return MaterialPageRoute(
          builder: (context) => const Scaffold(body: ErrorScreen()));
  }
}
