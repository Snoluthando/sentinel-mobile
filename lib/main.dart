import 'package:flutter/material.dart';
import 'package:hello_flutter/Data/notifiers.dart';
import 'package:hello_flutter/Views/Pages/welcome_page.dart';
// main.dart



void main() {
  runApp(const MyApp()); 
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable:  darkmodeNotifier,
      builder: (BuildContext context, bool darkMode, Widget? child) {
        return  MaterialApp(
       debugShowCheckedModeBanner: false,
        theme:ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor:  Colors.teal,
          brightness: darkMode?Brightness.dark:Brightness.light),
        ) ,
      
      home:  WelcomePage( 
      ) 
        
    );
      },
    );
  }
}     
