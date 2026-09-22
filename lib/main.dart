import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SeniorHomeScreen extends StatefulWidget {
  const SeniorHomeScreen({super.key});

  @override
  State<SeniorHomeScreen> createState() => _SeniorHomeScreenState();
}

class _SeniorHomeScreenState extends State<SeniorHomeScreen> {
  final ImagePicker _picker = ImagePicker();

  // Função para selecionar foto da galeria ou tirar foto com a câmera
  Future<void> _selecionarFoto(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        debugPrint('Imagem selecionada: ${image.path}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto selecionada com sucesso!')),
        );
      }
    } catch (e) {
      debugPrint('Erro ao selecionar foto: $e');
    }
  }

  // Função para abrir diálogo de configurações (Engrenagem)
  void _abrirConfiguracoes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurações'),
        content: const Text('Opções do Modo Sênior e preferências da conta.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obter dados do usuário logado no Supabase
    final user = Supabase.instance.client.auth.currentUser;
    final String nomeOuEmail = user?.email ?? 'Usuário Sênior';
    final String telefone = user?.userMetadata?['phone'] ?? 'Não informado';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerente Sênior'),
        actions: [
          // Botão de Engrenagem
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _abrirConfiguracoes,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exibição do Usuário e Telefone
            Text(
              'Usuário: $nomeOuEmail',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Telefone: $telefone', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),

            // Botões de Câmera e Galeria
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tirar Foto'),
              onPressed: () => _selecionarFoto(ImageSource.camera),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('Abrir Galeria'),
              onPressed: () => _selecionarFoto(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}
