// Configuração visual de um console cadastrado.
//
// Armazena apenas o que é necessário para exibir o console na UI:
// nome e referência de imagem. Não contém lógica de canal — o vínculo
// canal → ConsoleConfig é feito pelo ConsoleStorageService.
//
// [imagem] pode ser:
//   - URL CDN:    "https://raw.githubusercontent.com/..."
//   - Path local: "/data/user/0/.../console_1234567890.jpg"

class ConsoleConfig {
  final String nome;

  /// URL de CDN ou path absoluto de arquivo local.
  final String imagem;

  const ConsoleConfig({required this.nome, required this.imagem});

  ConsoleConfig copyWith({String? nome, String? imagem}) {
    return ConsoleConfig(
      nome: nome ?? this.nome,
      imagem: imagem ?? this.imagem,
    );
  }

  bool get isLocalImage => !imagem.startsWith('http');

  Map<String, dynamic> toJson() => {'nome': nome, 'imagem': imagem};

  factory ConsoleConfig.fromJson(Map<String, dynamic> json) {
    return ConsoleConfig(
      nome: json['nome'] as String,
      imagem: json['imagem'] as String,
    );
  }

  @override
  String toString() => 'ConsoleConfig("$nome", imagem: "$imagem")';

  @override
  bool operator ==(Object other) =>
      other is ConsoleConfig && other.nome == nome && other.imagem == imagem;

  @override
  int get hashCode => Object.hash(nome, imagem);
}
