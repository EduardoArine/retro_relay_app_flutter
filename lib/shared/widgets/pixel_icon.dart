// Ícones em pixel art 16×16, os mesmos da interface web do ESP32.
//
// Cada '#' é um pixel aceso; linhas vazias ou mais curtas completam com apagado.
// Desenhados com retângulos (sem suavização), então ficam nítidos em qualquer tamanho.
//
// Uso: PixelIcon(PixelIcone.console, size: 20, color: AppCores.destaque)
import 'package:flutter/material.dart';

enum PixelIcone {
  console([
    '', '', '',
    '..############..',
    '.##############.',
    '###.########.###',
    '##...######.#.##',
    '###.########.###',
    '################',
    '#######..#######',
    '######....######',
    '#####......#####',
    '.###........###.',
  ]),
  lista([
    '', '',
    '.##.##########..',
    '.##.##########..',
    '', '',
    '.##.##########..',
    '.##.##########..',
    '', '',
    '.##.##########..',
    '.##.##########..',
  ]),
  ajustes([
    '',
    '......####......',
    '..##..####..##..',
    '..############..',
    '...##########...',
    '..#####..#####..',
    '######....######',
    '######....######',
    '######....######',
    '######....######',
    '..#####..#####..',
    '...##########...',
    '..############..',
    '..##..####..##..',
    '......####......',
  ]),
  voltar([
    '', '',
    '......##........',
    '.....##.........',
    '....##..........',
    '...##...........',
    '..############..',
    '..############..',
    '...##...........',
    '....##..........',
    '.....##.........',
    '......##........',
  ]),
  editar([
    '',
    '............##..',
    '...........####.',
    '............###.',
    '.........##..#..',
    '........####....',
    '.......#####....',
    '......#####.....',
    '.....#####......',
    '....#####.......',
    '....####........',
    '...#.##.........',
    '...##...........',
    '..#.............',
  ]),
  remover([
    '',
    '......####......',
    '..############..',
    '',
    '...##########...',
    '...##.#..#.##...',
    '...##.#..#.##...',
    '...##.#..#.##...',
    '...##.#..#.##...',
    '...##.#..#.##...',
    '...##.#..#.##...',
    '...##########...',
  ]),
  mais([
    '', '',
    '.......##.......',
    '.......##.......',
    '.......##.......',
    '.......##.......',
    '..############..',
    '..############..',
    '.......##.......',
    '.......##.......',
    '.......##.......',
    '.......##.......',
  ]),
  atualizar([
    '', '',
    '.....######.....',
    '...############.',
    '...###....####..',
    '..###......##...',
    '..##.......##...',
    '..##............',
    '..##............',
    '..##........##..',
    '..###......###..',
    '...###....###...',
    '...##########...',
    '.....######.....',
  ]),
  energia([
    '',
    '.......##.......',
    '...##..##..##...',
    '..##...##...##..',
    '.##....##....##.',
    '.##....##....##.',
    '##.....##.....##',
    '##............##',
    '##............##',
    '##............##',
    '.##..........##.',
    '.##..........##.',
    '..##........##..',
    '...##########...',
    '.....######.....',
  ]),
  seta([
    '', '', '', '', '',
    '..##........##..',
    '...##......##...',
    '....##....##....',
    '.....##..##.....',
    '......####......',
    '.......##.......',
  ]);

  const PixelIcone(this.linhas);
  final List<String> linhas;
}

class PixelIcon extends StatelessWidget {
  final PixelIcone icone;
  final double size;

  /// null = cor do IconTheme atual (como um Icon comum)
  final Color? color;

  const PixelIcon(this.icone, {super.key, this.size = 20, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _PixelPainter(icone.linhas, color ?? IconTheme.of(context).color!),
      ),
    );
  }
}

class _PixelPainter extends CustomPainter {
  final List<String> linhas;
  final Color cor;

  _PixelPainter(this.linhas, this.cor);

  @override
  void paint(Canvas canvas, Size size) {
    final px = size.width / 16;
    final paint = Paint()
      ..color = cor
      ..isAntiAlias = false;
    for (var y = 0; y < linhas.length; y++) {
      final linha = linhas[y];
      var x = 0;
      while (x < linha.length) {
        if (linha[x] != '#') {
          x++;
          continue;
        }
        // Junta os pixels seguidos da linha num retângulo só
        final inicio = x;
        while (x < linha.length && linha[x] == '#') {
          x++;
        }
        canvas.drawRect(Rect.fromLTWH(inicio * px, y * px, (x - inicio) * px, px), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_PixelPainter old) => old.cor != cor || old.linhas != linhas;
}
