import 'package:ecosphere/views-viewmodels/account/Policy_TermsOfService/privacy_policy.dart';
import 'package:ecosphere/views-viewmodels/account/Policy_TermsOfService/terms_of_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';
  bool _isLoading = false;

  final List<String> _languages = ['English', 'Spanish', 'French', 'German'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
        _selectedLanguage = prefs.getString('language') ?? 'English';
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error loading settings: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setBool('dark_mode_enabled', _darkModeEnabled);
      await prefs.setString('language', _selectedLanguage);

      Fluttertoast.showToast(
        msg: 'Settings saved successfully',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error saving settings: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF49447E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings & Privacy',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF49447E),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF49447E)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección de notificaciones
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF49447E),
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    value: _notificationsEnabled,
                    activeColor: const Color(0xFF49447E),
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      _saveSettings();
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(height: 32),

                  // Sección de visualización
                  const Text(
                    'Display',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF49447E),
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: _darkModeEnabled,
                    activeColor: const Color(0xFF49447E),
                    onChanged: (value) {
                      setState(() {
                        _darkModeEnabled = value;
                      });
                      _saveSettings();
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(height: 32),

                  // Sección de idioma
                  const Text(
                    'Language',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF49447E),
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF5F5F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _languages.map((language) {
                      return DropdownMenuItem(
                        value: language,
                        child: Text(language),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedLanguage = value;
                        });
                        _saveSettings();
                      }
                    },
                  ),
                  const Divider(height: 32),

                  // Sección de privacidad
                  const Text(
                    'Privacy',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF49447E),
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navegar a la página de política de privacidad
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicy(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Terms of Service'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navegar a la página de términos de servicio
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsOfService(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),

                  // Botón para borrar la cuenta
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Mostrar diálogo de confirmación para borrar cuenta
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Account'),
                            content: const Text(
                                'Are you sure you want to delete your account? This action cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Lógica para eliminar la cuenta
                                  Navigator.pop(context);
                                },
                                child: const Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text(
                        'Delete Account',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
