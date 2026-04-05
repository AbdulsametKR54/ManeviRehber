class Country {
  final int id;
  final String name;

  Country({required this.id, required this.name});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['ulkeID'] ?? json['UlkeID'] ?? 0,
      name: json['ulkeAdi'] ?? json['UlkeAdi'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'ulkeID': id,
    'ulkeAdi': name,
  };
}

class City {
  final int id;
  final String name;

  City({required this.id, required this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['sehirID'] ?? json['SehirID'] ?? 0,
      name: json['sehirAdi'] ?? json['SehirAdi'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'sehirID': id,
    'sehirAdi': name,
  };
}

class District {
  final int id;
  final String name;

  District({required this.id, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['ilceID'] ?? json['IlceID'] ?? 0,
      name: json['ilceAdi'] ?? json['IlceAdi'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'ilceID': id,
    'ilceAdi': name,
  };
}
