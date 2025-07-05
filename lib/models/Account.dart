class Account {
  final int id;
  final String name;

  Account({required this.id, required this.name});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(id: json['id'], name: json['name']);
  }
}