import 'package:flutter/material.dart';
import 'package:sun_envidiado_website/app/app_theme.dart';
import 'package:sun_envidiado_website/ui/crt_effect/crt_shader_overlay.dart';
import 'package:sun_envidiado_website/ui/terminal/terminal_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '/sun',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home: const Scaffold(body: CRTShaderOverlay(child: TerminalScreen())),
    );
  }
}
