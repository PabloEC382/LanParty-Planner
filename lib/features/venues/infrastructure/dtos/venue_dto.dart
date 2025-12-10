// ignore_for_file: non_constant_identifier_names

class VenueDto {
  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final int capacity;
  final List<String>? facilities;
  final double rating;
  final int total_reviews;
  final String created_at; // ISO8601
  final String updated_at; // ISO8601

  VenueDto({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.capacity,
    this.facilities,
    required this.rating,
    required this.total_reviews,
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
      capacity: map['capacity'] as int,
      facilities: (map['facilities'] as List?)?.cast<String>(),
      rating: (map['rating'] as num).toDouble(),
      total_reviews: map['total_reviews'] as int,
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
      'capacity': capacity,
      'facilities': facilities,
      'rating': rating,
      'total_reviews': total_reviews,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }
}