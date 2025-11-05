class Venue {
  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final double latitude;
  final double longitude; 
  final int capacity;
  final double pricePerHour;
  final Set<String> facilities; 
  final double rating; 
  final int totalReviews; 
  final bool isVerified;
  final Uri? websiteUri;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  Venue({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required double latitude,
    required double longitude,
    required int capacity,
    required double pricePerHour,
    Set<String>? facilities,
    required double rating,
    required int totalReviews,
    this.isVerified = false,
    this.websiteUri,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  })  : latitude = latitude.clamp(-90.0, 90.0),
        longitude = longitude.clamp(-180.0, 180.0),
        capacity = capacity < 1 ? 1 : capacity,
        pricePerHour = pricePerHour < 0 ? 0 : pricePerHour, 
        rating = rating.clamp(0.0, 5.0),
        totalReviews = totalReviews < 0 ? 0 : totalReviews,
        facilities = {...?facilities};

  String get fullAddress => '$address, $city - $state, $zipCode';

  String get ratingDisplay {
    final stars = '⭐' * rating.round();
    return '$stars ${rating.toStringAsFixed(1)} (${totalReviews} avaliações)';
  }

  String get priceDisplay => pricePerHour > 0
      ? 'R\$ ${pricePerHour.toStringAsFixed(2)}/hora'
      : 'Gratuito';

  String get capacityCategory {
    if (capacity <= 10) return 'Pequeno';
    if (capacity <= 50) return 'Médio';
    if (capacity <= 200) return 'Grande';
    return 'Extra Grande';
  }

  bool get hasEssentials {
    return facilities.contains('WiFi') && facilities.contains('AC');
  }

  String get mapsUrl =>
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

  String get badge => isVerified ? '✅ Verificado' : '⏳ Não verificado';

  Venue copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    double? latitude,
    double? longitude,
    int? capacity,
    double? pricePerHour,
    Set<String>? facilities,
    double? rating,
    int? totalReviews,
    bool? isVerified,
    Uri? websiteUri,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Venue(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      capacity: capacity ?? this.capacity,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      facilities: facilities ?? this.facilities,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      isVerified: isVerified ?? this.isVerified,
      websiteUri: websiteUri ?? this.websiteUri,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}