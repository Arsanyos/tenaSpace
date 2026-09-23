/// Raw payload shaped like the Next.js `/api/wellness-feed` response,
/// deliberately containing the edge cases the parser must tolerate.
const curatedFeedJson = <String, dynamic>{
  'featured': {
    'id': 'meskel-walk',
    'emoji': '🚶',
    'name': 'Meskel Square Walk',
    'category': 'Walking route',
    'section': 'move',
    'distanceKm': 1.2,
    'recommendation': 'Flat loop that fits your walking goal.',
    'tags': ['walking', 'sunrise'],
    'lat': 9.0107,
    'lng': 38.7613,
    'durationMinutes': 25,
    'bestTime': 'Early morning',
    'suggestedActions': [
      {'type': 'timer', 'label': 'Start a 25-minute walk'},
      {
        'type': 'directions',
        'label': 'Get directions',
        'description': ' Open maps ',
      },
      {'type': 'teleport', 'label': 'Not a real action'},
      {'label': 'Missing type'},
    ],
  },
  'sections': [
    {
      'id': 'move',
      'title': 'Get moving',
      'places': [
        {
          'id': 'bole-court',
          'emoji': '🏀',
          'name': 'Bole Court',
          'category': 'Basketball court',
          'distanceKm': 2,
          'recommendation': 'Evening pick-up games.',
          'tags': ['a', 'b', 'c', 'd', 'e', 'f', 'g'],
          'audioKind': 'ambient',
        },
        {
          // Missing name → dropped.
          'id': 'broken',
          'emoji': '❓',
          'category': 'Unknown',
          'distanceKm': 1,
          'recommendation': 'Should never appear.',
        },
        {
          // Duplicate id → suffixed.
          'id': 'bole-court',
          'emoji': '🏀',
          'name': 'Bole Court Annex',
          'category': 'Basketball court',
          'distanceKm': 2.5,
          'recommendation': 'Second court.',
        },
        {
          // No id → slugified from name.
          'emoji': '🏃',
          'name': 'Jan Meda Running Track!',
          'category': 'Running track',
          'distanceKm': 3.4,
          'recommendation': 'Grass loops.',
          'section': 'move',
        },
        {
          // Fourth valid place → trimmed by the per-section cap.
          'id': 'extra-gym',
          'emoji': '🏋️',
          'name': 'Extra Gym',
          'category': 'Gym',
          'distanceKm': 4,
          'recommendation': 'Too many places.',
        },
      ],
    },
    {
      'id': 'eat',
      'places': [
        {
          'id': 'green-bowl',
          'emoji': '🥗',
          'name': 'Green Bowl',
          'category': 'Healthy restaurant',
          'distanceKm': 2.1,
          'recommendation': 'Low-sugar lunch bowls.',
          'audioKind': 'none',
          'lat': 9.018,
          'lng': 38.769,
        },
      ],
    },
    {
      'id': 'mystery',
      'places': [
        {
          'id': 'ignored',
          'emoji': '👻',
          'name': 'Ignored Place',
          'category': 'Unknown section',
          'distanceKm': 1,
          'recommendation': 'Unknown section ids are skipped.',
        },
      ],
    },
    {
      'id': 'health',
      'title': '   ',
      'places': [
        {
          'id': 'megenagna-clinic',
          'emoji': '🏥',
          'name': 'Megenagna Clinic',
          'category': 'Clinic',
          'distanceKm': 1.5,
          'recommendation': 'Walk-in checkups.',
          'audioKind': 'none',
        },
      ],
    },
  ],
};
