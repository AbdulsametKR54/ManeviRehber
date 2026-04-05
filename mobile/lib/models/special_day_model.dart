class SpecialDayModel {
  final String id;
  final String name;
  final DateTime date;
  final String description;

  SpecialDayModel({
    required this.id,
    required this.name,
    required this.date,
    required this.description,
  });

  factory SpecialDayModel.fromJson(Map<String, dynamic> json) {
    return SpecialDayModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      date: DateTime.parse(json['date']),
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'description': description,
    };
  }
}
