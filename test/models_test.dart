import 'package:flutter_test/flutter_test.dart';
import 'package:tvmaze_app/data/models/cast_member.dart';
import 'package:tvmaze_app/data/models/show.dart';

void main() {
  group('Show.fromJson', () {
    test('parses a full API response and strips HTML from the summary', () {
      final show = Show.fromJson({
        'id': 169,
        'name': 'Breaking Bad',
        'genres': ['Drama', 'Crime'],
        'status': 'Ended',
        'premiered': '2008-01-20',
        'ended': '2013-09-29',
        'rating': {'average': 9.2},
        'image': {'medium': 'm.jpg', 'original': 'o.jpg'},
        'summary': '<p><b>Breaking Bad</b> follows Walter &amp; Jesse.</p>',
        'runtime': 60,
        'network': {'name': 'AMC'},
        'webChannel': null,
        'schedule': {'time': '22:00', 'days': ['Sunday']},
      });

      expect(show.name, 'Breaking Bad');
      expect(show.rating, 9.2);
      expect(show.summary, 'Breaking Bad follows Walter & Jesse.');
      expect(show.network, 'AMC');
      expect(show.yearRange, '2008 - 2013');
      expect(show.genresText, 'Drama, Crime');
    });

    test('handles missing information', () {
      final show = Show.fromJson({
        'id': 1,
        'name': null,
        'genres': [],
        'status': 'Running',
        'premiered': '2023-01-15',
        'rating': {'average': null},
        'image': null,
        'summary': null,
        'network': null,
        'webChannel': {'name': 'Netflix'},
      });

      expect(show.name, 'Untitled');
      expect(show.rating, isNull);
      expect(show.imageMedium, isNull);
      expect(show.summary, isNull);
      expect(show.network, 'Netflix'); // falls back to the web channel
      expect(show.yearRange, '2023 - Present');
      expect(show.genresText, 'Unknown genre');
      expect(const Show(id: 2, name: 'X').yearRange, 'Unknown year');
    });

    test('toJson can be read back by fromJson (used by the watchlist)', () {
      const show = Show(
        id: 82,
        name: 'Game of Thrones',
        genres: ['Drama'],
        rating: 8.9,
        imageMedium: 'm.jpg',
        network: 'HBO',
      );

      final copy = Show.fromJson(show.toJson());

      expect(copy, show);
      expect(copy.name, show.name);
      expect(copy.genres, show.genres);
      expect(copy.rating, show.rating);
      expect(copy.imageMedium, show.imageMedium);
      expect(copy.network, show.network);
    });
  });

  test('CastMember.fromJson uses the character image when the actor has none', () {
    final member = CastMember.fromJson({
      'person': {'id': 1, 'name': 'Bryan Cranston', 'image': null},
      'character': {'name': 'Walter White', 'image': {'medium': 'walt.jpg'}},
    });

    expect(member.name, 'Bryan Cranston');
    expect(member.character, 'Walter White');
    expect(member.image, 'walt.jpg');
  });
}
