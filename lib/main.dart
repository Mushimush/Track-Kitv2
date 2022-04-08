import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:trackkit/LoginSignup//login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Track Kit',
      theme: ThemeData(
        fontFamily: 'Raleway',
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.black,
              displayColor: Colors.grey[600],
            ),
        // This colors the [InputOutlineBorder] when it is selected
        primaryColor: Colors.grey[500],
        textSelectionTheme:
            TextSelectionThemeData(selectionHandleColor: Colors.green[500]),
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      builder: EasyLoading.init(),
    );
  }
}
