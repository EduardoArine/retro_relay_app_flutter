// Representa um console no formato serializado para SharedPreferences.
//
// Por que existe separado de ConsoleConfig?
//   ConsoleConfig é o model da UI (sem referência de canal).
//   PersistedConsole inclui o canal para poder recriar o Map<int, ConsoleConfig>
//   ao carregar do storage. Essa separação mantém ConsoleConfig limpo e reutilizável.
//
// Fluxo de serialização:
//   Map<int, ConsoleConfig>
//     → List<PersistedConsole>
//     → List<Map<String, dynamic>>
//     → JSON string no SharedPreferences

import 'console_config.dart';

class PersistedConsole {
  final int canal;
  final String nome;
  final String imagem;

  const PersistedConsole({
    required this.canal,
    required this.nome,
    required this.imagem,
  });

  factory PersistedConsole.fromConsoleConfig(int canal, ConsoleConfig config) {
    return PersistedConsole(
      canal: canal,
      nome: config.nome,
      imagem: config.imagem,
    );
  }

  ConsoleConfig toConsoleConfig() => ConsoleConfig(nome: nome, imagem: imagem);

  Map<String, dynamic> toJson() => {
        'canal': canal,
        'nome': nome,
        'imagem': imagem,
      };

  factory PersistedConsole.fromJson(Map<String, dynamic> json) {
    return PersistedConsole(
      canal: json['canal'] as int,
      nome: json['nome'] as String,
      imagem: json['imagem'] as String,
    );
  }
}
