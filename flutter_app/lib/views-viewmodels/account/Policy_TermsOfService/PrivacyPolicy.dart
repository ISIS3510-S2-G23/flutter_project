import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

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
          'Privacy Policy',
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
              'Effective Date: March 1, 2025',
              style: TextStyle(
                color: Color(0xFF858597),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            
            // Introducción
            _buildSectionTitle('Introduction'),
            _buildParagraph(
              'Welcome to EcoSphere. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you about how we look after your personal data when you visit our app and tell you about your privacy rights and how the law protects you.'
            ),
            
            // Información que recopilamos
            _buildSectionTitle('Information We Collect'),
            _buildParagraph(
              'We collect several types of information from and about users of our app, including:'
            ),
            _buildBulletPoint('Personal identifiers such as name and email address'),
            _buildBulletPoint('Location data to find recycling points near you'),
            _buildBulletPoint('Photos that you upload to validate recycling activities'),
            _buildBulletPoint('Usage data and preferences to improve your experience'),
            
            // Cómo usamos la información
            _buildSectionTitle('How We Use Your Information'),
            _buildParagraph(
              'We use information that we collect about you or that you provide to us:'
            ),
            _buildBulletPoint('To provide, maintain, and improve our services'),
            _buildBulletPoint('To notify you about changes to our app or services'),
            _buildBulletPoint('To allow you to participate in interactive features'),
            _buildBulletPoint('To validate your recycling activities and award points'),
            _buildBulletPoint('To calculate environmental impact metrics'),
            
            // Divulgación de datos
            _buildSectionTitle('Disclosure of Your Information'),
            _buildParagraph(
              'We may disclose aggregated information about our users without restriction. We may disclose personal information:'
            ),
            _buildBulletPoint('To comply with any court order or legal process'),
            _buildBulletPoint('To enforce our terms of service'),
            _buildBulletPoint('To protect the rights, property, or safety of our users'),
            
            // Seguridad de datos
            _buildSectionTitle('Data Security'),
            _buildParagraph(
              'We have implemented measures designed to secure your personal information from accidental loss and from unauthorized access, use, alteration, and disclosure. However, we cannot guarantee that unauthorized third parties will never be able to defeat those measures.'
            ),
            
            // Derechos de los usuarios
            _buildSectionTitle('Your Rights'),
            _buildParagraph(
              'You have the right to:'
            ),
            _buildBulletPoint('Access and receive a copy of your data'),
            _buildBulletPoint('Rectify any incorrect or incomplete data'),
            _buildBulletPoint('Request erasure of your personal data'),
            _buildBulletPoint('Object to processing of your personal data'),
            _buildBulletPoint('Data portability'),
            
            // Cambios a esta política
            _buildSectionTitle('Changes to Our Privacy Policy'),
            _buildParagraph(
              'We may update our privacy policy from time to time. If we make material changes, we will notify you by email or through a notice on the app prior to the change becoming effective.'
            ),
            
            // Contacto
            _buildSectionTitle('Contact Us'),
            _buildParagraph(
              'If you have any questions about this privacy policy or our privacy practices, please contact us at:'
            ),
            _buildContactInfo('privacy@ecosphere.com'),
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