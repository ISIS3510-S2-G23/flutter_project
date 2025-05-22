import 'package:flutter/material.dart';

class WasteClassifierScreen extends StatefulWidget {
  @override
  _WasteClassifierScreenState createState() => _WasteClassifierScreenState();
}

class _WasteClassifierScreenState extends State<WasteClassifierScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clasificador de Residuos'),
      ),
      body: Center(
        child: Text('Pantalla de Clasificador de Residuos'),
      ),
    );
  }
}
