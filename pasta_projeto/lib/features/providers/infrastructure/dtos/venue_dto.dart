class VenueDto {
  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String zip_code;
  final double latitude;
  final double longitude;
  final int capacity;
  final double price_per_hour;
  final List<String>? facilities;
  final double rating;
  final int total_reviews;
  final bool is_verified;
  final String? website_url;
  final String? phone_number;
  final String created_at; // ISO8601
  final String updated_at; // ISO8601

  VenueDto({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.zip_code,
    required this.latitude,
    required this.longitude,
    required this.capacity,
    required this.price_per_hour,
    this.facilities,
    required this.rating,
    required this.total_reviews,
    required this.is_verified,
    this.website_url,
    this.phone_number,
    required this.created_at,
    required this.updated_at,
  });

  factory VenueDto.fromMap(Map<String, dynamic> map) {
    return VenueDto(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      city: map['city'] as String,
      state: map['state'] as String,
      zip_code: map['zip_code'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      capacity: map['capacity'] as int,
      price_per_hour: (map['price_per_hour'] as num).toDouble(),
      facilities: (map['facilities'] as List?)?.cast<String>(),
      rating: (map['rating'] as num).toDouble(),
      total_reviews: map['total_reviews'] as int,
      is_verified: map['is_verified'] as bool,
      website_url: map['website_url'] as String?,
      phone_number: map['phone_number'] as String?,
      created_at: map['created_at'] as String,
      updated_at: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'zip_code': zip_code,
      'latitude': latitude,
      'longitude': longitude,
      'capacity': capacity,
      'price_per_hour': price_per_hour,
      'facilities': facilities,
      'rating': rating,
      'total_reviews': total_reviews,
      'is_verified': is_verified,
      'website_url': website_url,
      'phone_number': phone_number,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }
}