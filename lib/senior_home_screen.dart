import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Importação necessária

class SeniorHomeScreen extends StatefulWidget {
  const SeniorHomeScreen({super.key});

  @override
  State<SeniorHomeScreen> createState() => _SeniorHomeScreenState();
}

class _SeniorHomeScreenState extends State<SeniorHomeScreen> {
  // Simulação de confirmação do remédio
  bool _remedioTomado = false;

  // Função para registrar ações diretamente na tabela do Supabase
  Future<void> registrarAcaoSenior(String tipoAcao) async {
    try {
      await Supabase.instance.client.from('gerente_senior').insert({
        'created_at': DateTime.now().toIso8601String(),
        // Nota: Se adicionar uma coluna 'acao' ou 'tipo' no Supabase,
        // pode incluir: 'acao': tipoAcao,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ação "$tipoAcao" registrada com sucesso!'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Erro ao enviar dados para o Supabase: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro de conexão ao salvar ação no banco.'),
        ),
      );
    }
  }

  void _dispararSOS() {
    // Registra o evento de emergência no Supabase
    registrarAcaoSenior('ALERTA_SOS_EMERGENCIA');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.shade900,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 36),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'ALERTA ENVIADO!',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ],
        ),
        content: const Text(
          'Sua família e cuidadores receberam sua localização e um pedido de socorro.',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. HEADER: Data e Status da Bateria
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D47A1), // Azul escuro
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, Vovô!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Segunda-feira',
                          style: TextStyle(color: Colors.white70, fontSize: 20),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.battery_5_bar,
                          color: Colors.greenAccent,
                          size: 36,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '85%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. PAINEL DE REMÉDIO (Alerta Visual)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        _remedioTomado
                            ? Icons.check_circle
                            : Icons.medication_liquid,
                        size: 48,
                        color: _remedioTomado
                            ? Colors.green.shade800
                            : Colors.orange.shade900,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _remedioTomado
                                  ? 'Remédio Tomado!'
                                  : 'Remédio das 14:00',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _remedioTomado
                                  ? 'Próximo às 20:00'
                                  : 'Pressão (1 comprimido)',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      if (!_remedioTomado)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade900,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _remedioTomado = true;
                            });
                            // Salva no banco que o remédio foi tomado
                            registrarAcaoSenior('REMEDIO_TOMADO_14H');
                          },
                          child: const Text(
                            'TOMAR',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 3. GRADE DE BOTÕES GRANDES
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // Botão 1: Ligar para a Filha
                  _buildSeniorButton(
                    label: 'Ligar para\nFilha',
                    icon: Icons.phone_in_talk,
                    color: Colors.blue.shade700,
                    onTap: () => registrarAcaoSenior('LIGACAO_FILHA'),
                  ),

                  // Botão 2: WhatsApp João
                  _buildSeniorButton(
                    label: 'WhatsApp\nJoão',
                    icon: Icons.chat_bubble,
                    color: const Color(0xFF2E7D32),
                    onTap: () => registrarAcaoSenior('WHATSAPP_JOAO'),
                  ),

                  // Botão 3: Ver Fotos
                  _buildSeniorButton(
                    label: 'Galeria de\nFotos',
                    icon: Icons.photo_library,
                    color: Colors.purple.shade700,
                    onTap: () => registrarAcaoSenior('GALERIA_FOTOS'),
                  ),

                  // Botão 4: Câmera
                  _buildSeniorButton(
                    label: 'Tirar\nFoto',
                    icon: Icons.camera_alt,
                    color: Colors.teal.shade700,
                    onTap: () => registrarAcaoSenior('ABRIR_CAMERA'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 4. BOTÃO SOS
              SizedBox(
                height: 85,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onLongPress: _dispararSOS,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'SEGURE O BOTÃO POR 2 SEGUNDOS PARA DISPARAR O SOS!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        backgroundColor: Colors.black87,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sos, size: 50),
                      SizedBox(width: 12),
                      Text(
                        'EMERGÊNCIA (SOS)',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para criar os cartões gigantes da grade
  Widget _buildSeniorButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 54, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
