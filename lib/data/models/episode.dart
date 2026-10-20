import 'package:equatable/equatable.dart';

import '../../core/utils/text_utils.dart';

/// A single episode, from `/shows/:id/episodes`.
class Episode extends Equatable {
  const Episode({
    required this.id,
    required this.name,
    required this.season,
    this.number,
    this.airdate,
    this.runtime,
    this.image,
    this.summary,
  });

  final int id;
  final String name;
  final int season;
  final int? number; // null for special episodes
  final String? airdate; // yyyy-MM-dd
  final int? runtime;
  final String? image;
  final String? summary;

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Untitled episode',
      season: json['season'] as int? ?? 0,
      number: json['number'] as int?,
      airdate: json['airdate'] as String?,
      runtime: json['runtime'] as int?,
      image: json['image']?['medium'] as String?,
      summary: stripHtml(json['summary'] as String?),
    );
  }

  @override
  List<Object?> get props => [id];
}
