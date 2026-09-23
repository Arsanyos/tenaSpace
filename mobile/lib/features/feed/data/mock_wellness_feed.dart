import '../domain/suggested_action.dart';
import '../domain/wellness_feed.dart';
import '../domain/wellness_place.dart';
import '../domain/wellness_section.dart';

/// Hand-written Addis Ababa feed used when the app runs with
/// `--dart-define=USE_MOCK_API=true` (no Next.js server, no Groq key).
///
/// The `meskel-walk`, `entoto-view` and `ghion-garden` ids intentionally match
/// the per-place audio configs so the sound player exercises every branch.
const mockWellnessFeed = WellnessFeed(
  featured: WellnessPlace(
    id: 'meskel-walk',
    emoji: '🚶',
    name: 'Meskel Square Morning Walk',
    category: 'Walking route',
    distanceKm: 1.2,
    recommendation: 'A flat 25-minute loop that matches your walking goal and fresh-air mood.',
    section: WellnessSection.move,
    tags: ['walking', 'sunrise', 'open-air'],
    lat: 9.0107,
    lng: 38.7613,
    durationMinutes: 25,
    bestTime: '6:30 – 8:00 AM',
    suggestedActions: [
      SuggestedAction(
        type: SuggestedActionType.timer,
        label: 'Start a 25-minute walk',
        description: 'Two easy laps around the square before traffic builds.',
      ),
      SuggestedAction(
        type: SuggestedActionType.directions,
        label: 'Get directions',
        description: 'Open Meskel Square in Google Maps.',
      ),
      SuggestedAction(
        type: SuggestedActionType.audio,
        label: 'Play AI walking soundscape',
        description: 'A steady instrumental pace for your loop.',
      ),
      SuggestedAction(
        type: SuggestedActionType.save,
        label: 'Save for tomorrow',
        description: 'Keep this route in your wellness list.',
      ),
    ],
  ),
  sections: [
    WellnessFeedSection(
      section: WellnessSection.move,
      title: '🏃 Move Your Body',
      places: [
        WellnessPlace(
          id: 'bole-basketball-court',
          emoji: '🏀',
          name: 'Bole Community Basketball Court',
          category: 'Basketball court',
          distanceKm: 1.8,
          recommendation: 'Evening pick-up games nearby — perfect for your basketball interest.',
          section: WellnessSection.move,
          tags: ['basketball', 'evenings', 'outdoor'],
          lat: 8.9936,
          lng: 38.7870,
          bestTime: 'After 5 PM',
          audioKind: AudioKind.ambient,
          suggestedActions: [
            SuggestedAction(
              type: SuggestedActionType.timer,
              label: 'Plan a 40-minute session',
              description: 'Warm up, play, and stretch before you leave.',
            ),
            SuggestedAction(
              type: SuggestedActionType.directions,
              label: 'Get directions',
            ),
          ],
        ),
        WellnessPlace(
          id: 'jan-meda-running-track',
          emoji: '🏃',
          name: 'Jan Meda Running Track',
          category: 'Running track',
          distanceKm: 3.4,
          recommendation: 'Soft grass loops at altitude — a gentle way to stay active this week.',
          section: WellnessSection.move,
          tags: ['running', 'walking', 'grass'],
          lat: 9.0355,
          lng: 38.7620,
          audioKind: AudioKind.walkingMix,
          bestTime: 'Early morning',
        ),
      ],
    ),
    WellnessFeedSection(
      section: WellnessSection.eat,
      title: '🥗 Eat Well',
      places: [
        WellnessPlace(
          id: 'kazanchis-green-bowl',
          emoji: '🥗',
          name: 'Kazanchis Green Bowl',
          category: 'Healthy restaurant',
          distanceKm: 2.1,
          recommendation:
              'Diabetic-friendly bowls with shiro and greens, low on sugar.',
          section: WellnessSection.eat,
          tags: ['diabetic-friendly', 'low-sugar', 'lunch'],
          lat: 9.0180,
          lng: 38.7690,
          audioKind: AudioKind.none,
          bestTime: 'Lunch, 12 – 2 PM',
          suggestedActions: [
            SuggestedAction(
              type: SuggestedActionType.menu,
              label: 'Preview menu ideas',
              description: 'Pick options that match your food preferences.',
            ),
            SuggestedAction(
              type: SuggestedActionType.call,
              label: 'Call before visiting',
              description: 'Confirm today\'s specials and opening hours.',
            ),
          ],
        ),
        WellnessPlace(
          id: 'lideta-vegan-kitchen',
          emoji: '🥬',
          name: 'Lideta Vegan Kitchen',
          category: 'Vegetarian café',
          distanceKm: 2.9,
          recommendation:
              'Fasting-style plates every day — ideal for a plant-based week.',
          section: WellnessSection.eat,
          tags: ['vegetarian', 'fasting-food'],
          lat: 9.0110,
          lng: 38.7350,
          audioKind: AudioKind.none,
        ),
      ],
    ),
    WellnessFeedSection(
      section: WellnessSection.calm,
      title: '🧘 Calm Places',
      places: [
        WellnessPlace(
          id: 'entoto-view',
          emoji: '🧘',
          name: 'Entoto Viewpoint',
          category: 'Meditation spot',
          distanceKm: 7.6,
          recommendation:
              'Eucalyptus air and city views — a reset for a stressed week.',
          section: WellnessSection.calm,
          tags: ['quiet', 'nature', 'viewpoint'],
          lat: 9.0846,
          lng: 38.7635,
          bestTime: 'Late afternoon',
          suggestedActions: [
            SuggestedAction(
              type: SuggestedActionType.breathing,
              label: 'Start a grounding pause',
              description: 'Five slow breaths before you head back down.',
            ),
            SuggestedAction(
              type: SuggestedActionType.audio,
              label: 'Play calm background sound',
              description: 'Meditation music curated for Entoto.',
            ),
            SuggestedAction(
              type: SuggestedActionType.save,
              label: 'Save for sunset',
            ),
          ],
        ),
        WellnessPlace(
          id: 'ghion-garden',
          emoji: '🌿',
          name: 'Ghion Hotel Garden',
          category: 'Quiet garden',
          distanceKm: 2.4,
          recommendation:
              'Shaded lawns near Meskel Square for a slow, quiet pause.',
          section: WellnessSection.calm,
          tags: ['garden', 'shade', 'quiet'],
          lat: 9.0137,
          lng: 38.7644,
        ),
      ],
    ),
    WellnessFeedSection(
      section: WellnessSection.health,
      title: '🏥 Health Support',
      places: [
        WellnessPlace(
          id: 'megenagna-family-clinic',
          emoji: '🏥',
          name: 'Megenagna Family Clinic',
          category: 'Clinic',
          distanceKm: 1.5,
          recommendation:
              'Walk-in checkups and blood sugar screening close to home.',
          section: WellnessSection.health,
          tags: ['clinic', 'screening'],
          lat: 9.0202,
          lng: 38.8011,
          audioKind: AudioKind.none,
          suggestedActions: [
            SuggestedAction(
              type: SuggestedActionType.call,
              label: 'Call before visiting',
              description: 'Confirm opening hours and available services.',
            ),
            SuggestedAction(
              type: SuggestedActionType.checklist,
              label: 'Prepare your questions',
              description: 'Note symptoms and medications before you go.',
            ),
          ],
        ),
        WellnessPlace(
          id: 'bole-wellness-pharmacy',
          emoji: '💊',
          name: 'Bole Wellness Pharmacy',
          category: 'Pharmacy',
          distanceKm: 2.2,
          recommendation:
              'Stocks glucose monitors and heart-friendly supplements.',
          section: WellnessSection.health,
          tags: ['pharmacy', 'open-late'],
          lat: 8.9950,
          lng: 38.7900,
          audioKind: AudioKind.none,
        ),
      ],
    ),
  ],
);
