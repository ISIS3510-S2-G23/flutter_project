import 'package:flutter/material.dart';

class TermsOfService extends StatelessWidget {
  const TermsOfService({super.key});

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
          'Terms of Service',
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
            // Encabezado
            const Text(
              'Last Updated: March 1, 2025',
              style: TextStyle(
                color: Color(0xFF858597),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            
            // Introducción
            _buildSectionTitle('Agreement to Terms'),
            _buildParagraph(
              'These Terms of Service constitute a legally binding agreement made between you and EcoSphere, concerning your access to and use of the EcoSphere mobile application. By accessing or using the app, you agree to be bound by these Terms. If you disagree with any part of the terms, you may not access the app.'
            ),
            
            // Cambios en los términos
            _buildSectionTitle('Changes to Terms'),
            _buildParagraph(
              'We reserve the right to modify these terms at any time. We will provide notice of any changes by updating the "Last Updated" date. Your continued use of the app following the posting of revised Terms means that you accept and agree to the changes.'
            ),
            
            // Registro de cuenta
            _buildSectionTitle('Account Registration'),
            _buildParagraph(
              'In order to use certain features of the app, you must register for an account. You agree to provide accurate, current, and complete information and to update this information to maintain its accuracy. You are responsible for maintaining the confidentiality of your account and password and for restricting access to your device.'
            ),
            
            // Verificación de actividades
            _buildSectionTitle('Verification of Recycling Activities'),
            _buildParagraph(
              'Our app uses photo verification to validate recycling activities. By submitting photos, you affirm that they accurately represent your environmental actions. We reserve the right to reject submissions that appear fraudulent or do not meet our verification standards.'
            ),
            
            // Sistema de puntos y recompensas
            _buildSectionTitle('Points and Rewards'),
            _buildParagraph(
              'Points earned in the app are for promotional purposes only and have no cash value. We reserve the right to modify, suspend, or terminate the points system at any time. Rewards are subject to availability and additional terms may apply.'
            ),
            _buildParagraph(
              'Points cannot be transferred, sold, or exchanged for cash. Attempting to manipulate the points system may result in account termination.'
            ),
            
            // Uso aceptable
            _buildSectionTitle('Acceptable Use'),
            _buildParagraph(
              'You agree not to use the app:'
            ),
            _buildBulletPoint('In any way that violates applicable laws or regulations'),
            _buildBulletPoint('To impersonate or attempt to impersonate another person'),
            _buildBulletPoint('To engage in any conduct that restricts or inhibits anyone\'s use of the app'),
            _buildBulletPoint('To submit false or misleading information about recycling activities'),
            _buildBulletPoint('To attempt to gain unauthorized access to the app or its systems'),
            
            // Propiedad intelectual
            _buildSectionTitle('Intellectual Property'),
            _buildParagraph(
              'The app and its original content, features, and functionality are owned by EcoSphere and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.'
            ),
            
            // Limitación de responsabilidad
            _buildSectionTitle('Limitation of Liability'),
            _buildParagraph(
              'In no event shall EcoSphere, its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential, or punitive damages, including loss of profits, data, or other intangible losses, resulting from your access to or use of the app.'
            ),
            
            // Indemnización
            _buildSectionTitle('Indemnification'),
            _buildParagraph(
              'You agree to defend, indemnify, and hold harmless EcoSphere and its licensees from and against any claims, liabilities, damages, judgments, awards, losses, costs, expenses, or fees arising out of your use of the app or your violation of these Terms.'
            ),
            
            // Terminación
            _buildSectionTitle('Termination'),
            _buildParagraph(
              'We may terminate or suspend your account and access to the app immediately, without prior notice, for conduct that we believe violates these Terms or is harmful to other users of the app, us, or third parties, or for any other reason at our sole discretion.'
            ),
            
            // Ley aplicable
            _buildSectionTitle('Governing Law'),
            _buildParagraph(
              'These Terms shall be governed by and defined following the laws of [Your Jurisdiction]. EcoSphere and you irrevocably consent to the exclusive jurisdiction of the courts in [Your Jurisdiction] for any action arising out of or relating to these Terms.'
            ),
            
            // Contacto
            _buildSectionTitle('Contact Us'),
            _buildParagraph(
              'If you have any questions about these Terms, please contact us at:'
            ),
            _buildContactInfo('terms@ecosphere.com'),
            _buildContactInfo('EcoSphere Inc.'),
            _buildContactInfo('123 Green Street, Sustainable City'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          color: Color(0xFF49447E),
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
    );
  }
  
  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          height: 1.5,
          color: Color(0xFF1F1F39),
        ),
      ),
    );
  }
  
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•  ',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF49447E),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF1F1F39),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactInfo(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF49447E),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}