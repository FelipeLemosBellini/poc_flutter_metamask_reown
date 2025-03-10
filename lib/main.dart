import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:poc_metamask/home_view.dart';
import 'package:poc_metamask/injection_dependency.dart';

import 'deep_link_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  InjectionDependency.setup();
  DeepLinkHandler.initListener();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const HomeView(),
    );
  }
}
