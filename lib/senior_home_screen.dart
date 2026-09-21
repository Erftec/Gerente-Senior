import 'dart:async';

import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Medication {
  final String id;
  final String name;
  final String details;
  final String time;
  bool isTaken;

  Medication({
    required this.id,
    required this.name,
    required this.details,
    required this.time,
    this.isTaken = false,
  });
}

class SeniorHomeScreen extends StatefulWidget {
  const SeniorHomeScreen({super.key});

  @override
  State<SeniorHomeScreen> createState() => _SeniorHomeScreenState();
}

class _SeniorHomeScreenState extends State<SeniorHomeScreen> {
  final Battery _battery = Battery();
  int _batteryLevel = 100;
  late Timer _timer;
  DateTime _now = DateTime.now();
  bool _isLoading = true;

  final SupabaseClient _supabase = Supabase.instance.client;

  // Daily Medications Schedule List
  final List<Medication> _medications = [
    Medication(
      id: 'med_8am',
      name: 'Remédio das 08:00',
      details: 'Pressão (1 comprimido)',
      time: '08:00',
    ),
    Medication(
      id: 'med_2pm',
      name: 'Remédio das 14:00',
      details: 'Vitamina C (1 comprimido)',
      time: '14:00',
    ),
    Medication(
      id: 'med_8pm',
      name: 'Remédio das 20:00',
      details: 'Diabetes (1 comprimido)',
      time: '20:00',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getBatteryLevel();
    _loadSettingsFromSupabase();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Load status from Supabase
  Future<void> _loadSettingsFromSupabase() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await _supabase
          .from('user_settings')
          .select('settings_data')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null && response['settings_data'] != null) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          response['settings_data'],
        );

        setState(() {
          for (var med in _medications) {
            if (data.containsKey(med.id)) {
              med.isTaken = data[med.id] as bool;
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading settings from Supabase: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Save status to Supabase
  Future<void> _saveSettingsToSupabase() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final Map<String, dynamic> settingsData = {};
      for (var med in _medications) {
        settingsData[med.id] = med.isTaken;
      }

      await _supabase.from('user_settings').upsert({
        'user_id': userId,
        'settings_data': settingsData,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error saving settings to Supabase: $e');
    }
  }

  Future<void> _getBatteryLevel() async {
    try {
      final level = await _battery.batteryLevel;
      if (mounted) {
        setState(() {
          _batteryLevel = level;
        });
      }
    } catch (_) {}
  }

  String _formatWeekday(int weekday) {
    const days = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo',
    ];
    return days[weekday - 1];
  }

  Medication? _getNextMedication() {
    for (var med in _medications) {
      if (!med.isTaken) {
        return med;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final String timeStr =
        "${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}";

    final nextMedication = _getNextMedication();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D47A1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Olá, Vovô!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatWeekday(_now.weekday)} • $timeStr',
                          style: TextStyle(
                            color: Colors.grey.shade200,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.battery_std,
                          color: Colors.greenAccent,
                          size: 32,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_batteryLevel%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Dynamic Medication Banner
              _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    )
                  : _buildMedicationBanner(nextMedication),
              const SizedBox(height: 12),

              // Middle Buttons Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildGridButton(
                      icon: Icons.phone_forwarded,
                      label: 'Ligar para\nFilha',
                      color: const Color(0xFF1976D2),
                      onTap: () {},
                    ),
                    _buildGridButton(
                      icon: Icons.chat_bubble,
                      label: 'WhatsApp\nJoão',
                      color: const Color(0xFF2E7D32),
                      onTap: () {},
                    ),
                    _buildGridButton(
                      icon: Icons.photo_library,
                      label: 'Galeria de\nFotos',
                      color: const Color(0xFF7B1FA2),
                      onTap: () {},
                    ),
                    _buildGridButton(
                      icon: Icons.camera_alt,
                      label: 'Tirar\nFoto',
                      color: const Color(0xFF00695C),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // SOS Button
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(
                    Icons.warning,
                    color: Colors.white,
                    size: 28,
                  ),
                  label: const Text(
                    'SOS EMERGÊNCIA (SOS)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationBanner(Medication? med) {
    if (med == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 36),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Todos os remédios de hoje foram tomados!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.medication, color: Colors.deepOrange, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  med.details,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE65100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () async {
              setState(() {
                med.isTaken = true;
              });

              // Persist change to Supabase
              await _saveSettingsToSupabase();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Registrado: ${med.name}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text(
              'TOMAR',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(12),
      ),
      onPressed: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 44, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
