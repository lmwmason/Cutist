import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/coach_controller.dart';
import 'screens/connect_screen.dart';
import 'theme/toss_theme.dart';

void main() {
  runApp(const CutistApp());
}

class CutistApp extends StatelessWidget {
  const CutistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CoachController(),
      child: MaterialApp(
        title: 'Cutist',
        debugShowCheckedModeBanner: false,
        theme: TossTheme.light,
        home: const ConnectScreen(),
      ),
    );
  }
}
