class Integrante {
  final String id;
  final String nome;
  final String cargo;
  final String grupo; // 'a', 'b', 'c', 'd', 'e', 'f'
  final String? telefone;

  Integrante({
    required this.id,
    required this.nome,
    required this.cargo,
    required this.grupo,
    this.telefone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'cargo': cargo,
      'grupo': grupo,
      'telefone': telefone,
    };
  }

  factory Integrante.fromMap(Map<String, dynamic> map) {
    return Integrante(
      id: map['id'],
      nome: map['nome'],
      cargo: map['cargo'],
      grupo: map['grupo'],
      telefone: map['telefone'],
    );
  }
}
