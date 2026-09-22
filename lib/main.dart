import 'package:flutter/material.dart';

import 'senior_home_screen.dart';

void main() async {
  // Necessário para inicializar recursos nativos/web antes do runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização do Supabase
  await Supabase.initialize(
    url: 'https://nazpvahffqyixqzfncgc.supabase.co',
    anonKey: 'sb_publishable_ltCs0QxVVwTw80lB9K61fg_4waKuGrB',
  );

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
          primary: const Color(0xFF0D47A1), // Azul escuro de alto contraste
          error: const Color(0xFFD32F2F), // Vermelho forte para o SOS
        ),
        useMaterial3: true,
      ),
      // Redireciona diretamente para o Modo Sênior
      home: const SeniorHomeScreen(), // <-- Substitua pelo nome exato do seu Widget do Modo Sênior
    );
  }
}

class ProfileSelectionScreen extends StatelessWidget {
  const ProfileSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Como este celular será usado?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // Botão de Perfil: Idoso
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                ),
                icon: const Icon(Icons.nightlight_round, size: 40),
                label: const Text(
                  'Modo Sênior (Modo Fácil)',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SeniorHomeScreen(),
                    ),
                  );
                },
              ), // <-- Certifique-se de que a vírgula está aqui
              const SizedBox(height: 20),

              const SizedBox(height: 20),

              // Botão de Perfil: Cuidador / Filho
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                ),
                icon: const Icon(
                  IconData(0xe57f, fontFamily: 'MaterialIcons'),
                  size: 32,
                ),
                label: const Text(
                  'Painel do Cuidador / Filho',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  // Navega para o painel de monitoramento
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
