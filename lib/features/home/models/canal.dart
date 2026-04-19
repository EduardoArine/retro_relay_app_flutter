// Model de um canal de relé.
//
// Representa um dos 16 slots físicos do ESP32. Cada canal pode estar
// associado a um console cadastrado (via ConsoleConfig) ou vazio.
//
// Imutável por design: use copyWith para produzir novas versões do objeto
// ao atualizar estado no Riverpod — nunca mute campos diretamente.

class Canal {
  /// Índice físico do canal: 0 a 15.
  final int index;

  /// Nome do canal (ex: "Super Nintendo"). String vazia = slot não configurado.
  final String nome;

  /// true = relé acionado (console ligado).
  final bool ativo;

  const Canal({
    required this.index,
    required this.nome,
    this.ativo = false,
  });

  Canal copyWith({String? nome, bool? ativo}) {
    return Canal(
      index: index,
      nome: nome ?? this.nome,
      ativo: ativo ?? this.ativo,
    );
  }

  bool get isEmpty => nome.isEmpty;

  @override
  String toString() => 'Canal($index, "$nome", ativo: $ativo)';

  @override
  bool operator ==(Object other) =>
      other is Canal &&
      other.index == index &&
      other.nome == nome &&
      other.ativo == ativo;

  @override
  int get hashCode => Object.hash(index, nome, ativo);
}
