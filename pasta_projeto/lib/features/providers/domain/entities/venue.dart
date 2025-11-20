class Venue {
  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final int capacity;
  final Set<String> facilities; 
  final double rating; 
  final int totalReviews; 
  final DateTime createdAt;
  final DateTime updatedAt;

  Venue({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required int capacity,
    Set<String>? facilities,
    required double rating,
    required int totalReviews,
    required this.createdAt,
    required this.updatedAt,
  })  : capacity = capacity < 1 ? 1 : capacity,
        rating = rating.clamp(0.0, 5.0),
        totalReviews = totalReviews < 0 ? 0 : totalReviews,
        facilities = {...?facilities};

  String get fullAddress => '$address, $city - $state';

  String get ratingDisplay {
    final stars = '⭐' * rating.round();
    return '$stars ${rating.toStringAsFixed(1)} ($totalReviews avaliações)';
  }

  String get capacityCategory {
    if (capacity <= 10) return 'Pequeno';
    if (capacity <= 50) return 'Médio';
    if (capacity <= 200) return 'Grande';
    return 'Extra Grande';
  }

  bool get hasEssentials {
    return facilities.contains('WiFi') && facilities.contains('AC');
  }

  Venue copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? state,
    int? capacity,
    Set<String>? facilities,
    double? rating,
    int? totalReviews,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Venue(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      capacity: capacity ?? this.capacity,
      facilities: facilities ?? this.facilities,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}