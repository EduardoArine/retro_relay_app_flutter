// Card de um canal de relé, no visual da página do aparelho.
//
// Parâmetros:
//   canal   — dados do canal (índice, nome, estado ativo)
//   config  — configuração visual do console (null = slot vazio)
//   onTap   — callback de toggle — quem chama decide o que fazer
//
// Mostra "CH 01", a imagem com halo, o nome e o estado escrito com LED
// (LIGADO / DESLIGADO), para não depender só da cor.
//
// Não acessa providers — recebe tudo por parâmetro.
import 'dart:io';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../features/home/models/canal.dart';
import '../../features/novo_console/models/console_config.dart';
import 'pixel_icon.dart';

/// Rótulo do canal como na página: "CH 01" … "CH 16".
String rotuloCanal(int index) => 'CH ${(index + 1).toString().padLeft(2, '0')}';

class ConsoleCard extends StatelessWidget {
  final Canal canal;
  final ConsoleConfig? config;
  final VoidCallback onTap;

  const ConsoleCard({
    super.key,
    required this.canal,
    required this.config,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ativo = canal.ativo;
    final nome = config?.nome.isNotEmpty == true ? config!.nome : 'Canal ${canal.index + 1}';

    return Semantics(
      button: true,
      toggled: ativo,
      label: '$nome, ${ativo ? 'ligado' : 'desligado'}',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: ativo ? AppCores.painel : AppCores.superficie,
          borderRadius: BorderRadius.circular(raio),
          border: Border.all(
            color: ativo ? AppCores.destaque : AppCores.borda,
            width: ativo ? 2 : 1,
          ),
          boxShadow: ativo
              ? const [BoxShadow(color: AppCores.brilho, blurRadius: 28, spreadRadius: -10, offset: Offset(0, 10))]
              : const [],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(raio),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rotuloCanal(canal.index),
                    style: TextStyle(
                      fontFamily: fontePixel,
                      fontSize: 12,
                      letterSpacing: 1,
                      fontVariations: const [FontVariation.weight(500)],
                      color: ativo ? AppCores.destaque : AppCores.apagado,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      alignment: Alignment.center,
                      // Halo atrás do pixel art: destaca os consoles pretos; laranja quando ligado
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          radius: 0.5,
                          colors: ativo
                              ? const [AppCores.brilho, Color(0x00F28C28)]
                              : const [Color(0x1AF3E9D2), Color(0x00F3E9D2)],
                        ),
                      ),
                      child: _imagem(),
                    ),
                  ),
                  Text(
                    nome,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, height: 1.3, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: ativo ? AppCores.ok : AppCores.ledApagado,
                          boxShadow: ativo
                              ? const [BoxShadow(color: AppCores.ok, blurRadius: 8)]
                              : const [],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ativo ? 'LIGADO' : 'DESLIGADO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                          color: ativo ? AppCores.ok : AppCores.apagado,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _imagem() {
    const semImagem = PixelIcon(PixelIcone.console, size: 40, color: AppCores.bordaForte);
    if (config == null || config!.imagem.isEmpty) return semImagem;

    if (config!.isLocalImage) {
      return Image.file(
        File(config!.imagem),
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => semImagem,
      );
    }

    return Image.network(
      config!.imagem,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none, // pixel art sem borrar
      errorBuilder: (_, _, _) => semImagem,
    );
  }
}
