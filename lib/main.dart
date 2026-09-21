import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'senior_home_screen.dart';

// Ponto de entrada único da aplicação
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Supabase com as credenciais do seu projeto
  await Supabase.initialize(
    url: 'https://nazpvahffqyixqzfncgc.supabase.co',
    publishableKey: 'sb_publishable_ltCs0QXVwTw801B9K61fg_4waKuGrB',
  );

  runApp(const SeniorCareApp());
}

// Referência global para acessar o Supabase em qualquer lugar do app
final supabase = Supabase.instance.client;

class SeniorCareApp extends StatelessWidget {
  const SeniorCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EloSênior',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const SeniorHomeScreen(),
    );
  }
}
