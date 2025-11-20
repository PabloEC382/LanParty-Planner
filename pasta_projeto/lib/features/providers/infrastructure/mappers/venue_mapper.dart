import '../../domain/entities/venue.dart';
import '../dtos/venue_dto.dart';

class VenueMapper {
  static Venue toEntity(VenueDto dto) {
    return Venue(
      id: dto.id,
      name: dto.name,
      address: dto.address,
      city: dto.city,
      state: dto.state,
      capacity: dto.capacity,
      facilities: dto.facilities?.toSet() ?? {},
      rating: dto.rating,
      totalReviews: dto.total_reviews,
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
      capacity: entity.capacity,
      facilities: entity.facilities.toList(),
      rating: entity.rating,
      total_reviews: entity.totalReviews,
      created_at: entity.createdAt.toIso8601String(),
      updated_at: entity.updatedAt.toIso8601String(),
    );
  }

  static List<Venue> toEntities(List<VenueDto> dtos) => dtos.map(toEntity).toList();
  static List<VenueDto> toDtos(List<Venue> entities) => entities.map(toDto).toList();
}