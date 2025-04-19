import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Help extends StatelessWidget {
  const Help({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildFaqItem(String question, String answer, BuildContext context) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            answer,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF858597),
            ),
          ),
        ),
      ],
    );
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
          'Help Center',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF49447E),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de ayuda
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEAEAFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.support_agent,
                    color: Color(0xFF49447E),
                    size: 48,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Need Help?',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xFF49447E),
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Contact our support team for assistance',
                          style: TextStyle(
                            color: Color(0xFF858597),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            _launchUrl('mailto:support@ecosphere.com');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF49447E),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Contact Support',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Sección de FAQ
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFF49447E),
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),

            // Lista de preguntas frecuentes
            _buildFaqItem(
              'How do I earn points?',
              'You can earn points by completing challenges, attending events, and recycling at recognized collection points. Each activity awards a specific number of points based on your participation and impact.',
              context,
            ),
            _buildFaqItem(
              'How do I redeem my rewards?',
              'Navigate to the Rewards tab, browse available rewards, and select the one you want to redeem. Follow the on-screen instructions to complete the redemption process.',
              context,
            ),
            _buildFaqItem(
              'Can I transfer points to another user?',
              'Currently, our system does not support point transfers between users. Each account\'s points are tied to the individual\'s environmental activities.',
              context,
            ),
            _buildFaqItem(
              'How can I track my environmental impact?',
              'Your environmental impact is displayed on your profile dashboard. It shows metrics like CO2 saved, waste recycled, and your overall contribution ranking.',
              context,
            ),

            const SizedBox(height: 32),

            // Sección de Tutoriales
            const Text(
              'Tutorials & Resources',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFF49447E),
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),

            // Lista de tutoriales
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.play_circle_outline,
                  color: Color(0xFF49447E)),
              title: const Text('Getting Started Guide'),
              onTap: () {
                // Navegar al tutorial
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.play_circle_outline,
                  color: Color(0xFF49447E)),
              title: const Text('How to Complete Challenges'),
              onTap: () {
                // Navegar al tutorial
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  const Icon(Icons.article_outlined, color: Color(0xFF49447E)),
              title: const Text('Recycling Best Practices'),
              onTap: () {
                // Navegar al artículo
              },
            ),
          ],
        ),
      ),
    );
  }
}
