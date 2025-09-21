class Revizor {
  final int id;
  final String name;

  Revizor({required this.id, required this.name});

  factory Revizor.fromJson(Map<String, dynamic> json) {
    return Revizor(id: json['id'], name: json['name']);
  }
}