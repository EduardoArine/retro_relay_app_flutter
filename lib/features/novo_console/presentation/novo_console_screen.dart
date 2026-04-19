// Tela de criação/edição de um console em um canal específico.
// STUB: implementação completa na Fase 6 (form + image picker).
import 'package:flutter/material.dart';

class NovoConsoleScreen extends StatelessWidget {
  final int canalIndex;

  const NovoConsoleScreen({super.key, required this.canalIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Canal $canalIndex')),
      body: Center(
        child: Text('NovoConsoleScreen (canal: $canalIndex) — em construção'),
      ),
    );
  }
}
