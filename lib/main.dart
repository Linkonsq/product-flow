import 'package:flutter/material.dart';
import 'package:product_flow/views/main_shell/main_shell_view.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainShellView(),
    );
  }
}
