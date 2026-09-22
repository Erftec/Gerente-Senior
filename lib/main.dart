import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'senior_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://nazpvahffqyixqzfncgc.supabase.co',
      publishableKey: 'sb_publishable_ltCs0QxVVwTw80lB9K61fg_4waKuGrB',
    );
    debugPrint('Supabase inicializado com sucesso!');
  } catch (e) {
    debugPrint('Erro ao inicializar Supabase: $e');
  }

  runApp(const SeniorCareApp());
}

class SeniorCareApp extends StatelessWidget {
  const SeniorCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerente-Sênior',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: const Color(0xFF0D47A1),
          error: const Color(0xFFD32F2F),
        ),
        useMaterial3: true,
      ),
      home: const SeniorHomeScreen(),
    );
  }
}
