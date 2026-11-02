// Caixa com linhas separadas por um traço, como .grupo / .lista da página do aparelho.
//
// Usado pelo Cadastro (lista de consoles) e pelos Ajustes (grupos de opções).
// [titulo] opcional aparece acima, no estilo de rótulo laranja.
import 'package:flutter/material.dart';

import '../../app/theme.dart';

class Grupo extends StatelessWidget {
  final String? titulo;
  final List<Widget> linhas;

  const Grupo({super.key, this.titulo, required this.linhas});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (titulo != null)
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 10),
            child: Text(titulo!.toUpperCase(), style: estiloRotulo),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppCores.superficie,
            borderRadius: BorderRadius.circular(raio),
            border: Border.all(color: AppCores.borda),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(raio),
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                children: [
                  for (var i = 0; i < linhas.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    linhas[i],
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Linha padrão de um [Grupo]: título, subtítulo opcional e um controle à direita.
class LinhaGrupo extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final Widget? trailing;
  final VoidCallback? onTap;

  const LinhaGrupo({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (subtitulo != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(subtitulo!, style: const TextStyle(fontSize: 14, color: AppCores.apagado)),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 16), trailing!],
          ],
        ),
      ),
    );
  }
}
