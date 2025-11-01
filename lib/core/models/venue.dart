import 'geo_point.dart';

class Venue {
  const Venue({
    required this.id,
    required this.name,
    required this.geo,
    required this.address,
    required this.amenities,
    required this.photos,
    required this.rating,
    this.policies,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'] as String,
      name: json['name'] as String,
      geo: GeoPoint.fromJson(json['geo'] as Map<String, dynamic>),
      address: json['address'] as String,
      amenities: (json['amenities'] as List<dynamic>).cast<String>(),
      photos: (json['photos'] as List<dynamic>).cast<String>(),
      rating: (json['rating'] as num).toDouble(),
      policies: json['policies'] as String?,
    );
  }

  final String id;
  final String name;
  final GeoPoint geo;
  final String address;
  final List<String> amenities;
  final List<String> photos;
  final double rating;
  final String? policies;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'geo': geo.toJson(),
        'address': address,
        'amenities': amenities,
        'photos': photos,
        'rating': rating,
        'policies': policies,
      };
}
