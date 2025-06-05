import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:teeyai_app/providers/cart_provider.dart';
import 'package:teeyai_app/screens/home_screen.dart';
import 'package:teeyai_app/widgets/menu_screen_widget.dart';
import 'package:logging/logging.dart';

void main() async {
  Logger.root.level = Level.ALL; // Set the logging level
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
  });
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

 runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: {
    '/': (_) => const HomeScreen(),
    
  },
    );
  }
}

