import 'package:equatable/equatable.dart';

import '../../core/utils/text_utils.dart';

/// A TV show from the TVMaze API.
///
/// Every field except [id] and [name] can be missing in the API,
/// so they are nullable and the UI shows a fallback when they are null.
class Show extends Equatable {
  const Show({
    required this.id,
    required this.name,
    this.genres = const [],
    this.status,
    this.premiered,
    this.ended,
    this.rating,
    this.imageMedium,
    this.imageOriginal,
    this.summary,
    this.language,
    this.runtime,
    this.network,
    this.scheduleDays = const [],
    this.scheduleTime,
  });

  final int id;
  final String name;
  final List<String> genres;
  final String? status;
  final String? premiered; // yyyy-MM-dd
  final String? ended; // yyyy-MM-dd
  final double? rating;
  final String? imageMedium;
  final String? imageOriginal;
  final String? summary; // plain text, HTML already removed
  final String? language;
  final int? runtime; // minutes
  final String? network; // TV network or web channel (e.g. Netflix)
  final List<String> scheduleDays;
  final String? scheduleTime;

  factory Show.fromJson(Map<String, dynamic> json) {
    final image = json['image'] as Map<String, dynamic>?;
    final schedule = json['schedule'] as Map<String, dynamic>?;
    final channel = (json['network'] ?? json['webChannel']) as Map<String, dynamic>?;

    return Show(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Untitled',
      genres: List<String>.from(json['genres'] as List? ?? const []),
      status: json['status'] as String?,
      premiered: json['premiered'] as String?,
      ended: json['ended'] as String?,
      rating: (json['rating']?['average'] as num?)?.toDouble(),
      imageMedium: image?['medium'] as String?,
      imageOriginal: image?['original'] as String?,
      summary: stripHtml(json['summary'] as String?),
      language: json['language'] as String?,
      runtime: (json['runtime'] ?? json['averageRuntime']) as int?,
      network: channel?['name'] as String?,
      scheduleDays: List<String>.from(schedule?['days'] as List? ?? const []),
      scheduleTime: schedule?['time'] as String?,
    );
  }

  /// Same shape as the API JSON, so [Show.fromJson] can read it back.
  /// Used to save the watchlist locally.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'genres': genres,
        'status': status,
        'premiered': premiered,
        'ended': ended,
        'rating': {'average': rating},
        'image': {'medium': imageMedium, 'original': imageOriginal},
        'summary': summary,
        'language': language,
        'runtime': runtime,
        'network': {'name': network},
        'schedule': {'days': scheduleDays, 'time': scheduleTime},
      };

  /// "2008 - 2013", "2023 - Present", "2019", or "Unknown year".
  String get yearRange {
    final start = _year(premiered);
    if (start == null) return 'Unknown year';
    if (status == 'Running') return '$start - Present';
    final end = _year(ended);
    if (end == null || end == start) return start;
    return '$start - $end';
  }

  String get genresText => genres.isEmpty ? 'Unknown genre' : genres.join(', ');

  static String? _year(String? date) =>
      date == null || date.length < 4 ? null : date.substring(0, 4);

  // Two shows are the same show when their ids match.
  @override
  List<Object?> get props => [id];
}
