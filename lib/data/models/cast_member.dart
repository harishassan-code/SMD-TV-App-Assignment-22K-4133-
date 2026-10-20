import 'package:equatable/equatable.dart';

/// An actor and the character they play, from `/shows/:id/cast`.
class CastMember extends Equatable {
  const CastMember({
    required this.personId,
    required this.name,
    required this.character,
    this.image,
  });

  final int personId;
  final String name;
  final String character;
  final String? image;

  factory CastMember.fromJson(Map<String, dynamic> json) {
    final person = json['person'] as Map<String, dynamic>;
    final character = json['character'] as Map<String, dynamic>?;

    return CastMember(
      personId: person['id'] as int,
      name: person['name'] as String? ?? 'Unknown',
      character: character?['name'] as String? ?? 'Unknown role',
      // Fall back to the character photo when the actor has none.
      image: (person['image'] ?? character?['image'])?['medium'] as String?,
    );
  }

  @override
  List<Object?> get props => [personId, character];
}
