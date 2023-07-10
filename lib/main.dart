import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_cloud_meetings/router.dart';
import 'package:online_cloud_meetings/screens/login_screen.dart';
import 'package:online_cloud_meetings/screens/preview_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(),
        title: 'Flutter Demo',
        onGenerateRoute: generateRoute,
        home: const PreviewPage(
            meetingId: "meetingId",
            name: "name",
            email: "email",
            photoUrl: "photoUrl"));
  }
}
