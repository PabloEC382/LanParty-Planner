import '../../domain/entities/venue.dart';
import '../dtos/venue_dto.dart';

/// Mapper for Venue: DTO ↔ Entity conversions.
class VenueMapper {
  static Venue toEntity(VenueDto dto) {
    Uri? websiteUri;
    if (dto.website_url != null && dto.website_url!.isNotEmpty) {
      websiteUri = Uri.tryParse(dto.website_url!);
    }

    return Venue(
      id: dto.id,
      name: dto.name,
      address: dto.address,
      city: dto.city,
      state: dto.state,
      zipCode: dto.zip_code,
      latitude: dto.latitude,
      longitude: dto.longitude,
      capacity: dto.capacity,
      pricePerHour: dto.price_per_hour,
      facilities: dto.facilities?.toSet() ?? {},
      rating: dto.rating,
      totalReviews: dto.total_reviews,
      isVerified: dto.is_verified,
      websiteUri: websiteUri,
      phoneNumber: dto.phone_number,
      createdAt: DateTime.parse(dto.created_at),
      updatedAt: DateTime.parse(dto.updated_at),
    );
  }

  static VenueDto toDto(Venue entity) {
    return VenueDto(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      city: entity.city,
      state: entity.state,
      zip_code: entity.zipCode,
      latitude: entity.latitude,
      longitude: entity.longitude,
      capacity: entity.capacity,
      price_per_hour: entity.pricePerHour,
      facilities: entity.facilities.toList(),
      rating: entity.rating,
      total_reviews: entity.totalReviews,
      is_verified: entity.isVerified,
      website_url: entity.websiteUri?.toString(),
      phone_number: entity.phoneNumber,
      created_at: entity.createdAt.toIso8601String(),
      updated_at: entity.updatedAt.toIso8601String(),
    );
  }

  static List<Venue> toEntities(List<VenueDto> dtos) => dtos.map(toEntity).toList();
  static List<VenueDto> toDtos(List<Venue> entities) => entities.map(toDto).toList();
}