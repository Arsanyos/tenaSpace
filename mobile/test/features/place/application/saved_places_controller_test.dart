import 'package:flutter_test/flutter_test.dart';
import 'package:tenaspace/features/place/application/saved_places_controller.dart';
import 'package:tenaspace/features/place/data/saved_places_storage.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('SavedPlacesController', () {
    test('loads persisted ids and toggles membership', () async {
      final prefs = await fakePreferences({
        SavedPlacesStorage.storageKey: ['entoto-view'],
      });
      final container = createContainer(overrides: baseOverrides(prefs));
      container.listen(isPlaceSavedProvider('meskel-walk'), (_, _) {});

      expect(container.read(isPlaceSavedProvider('entoto-view')), isTrue);
      expect(container.read(isPlaceSavedProvider('meskel-walk')), isFalse);

      final controller = container.read(savedPlacesControllerProvider.notifier);
      await controller.toggle('meskel-walk');
      expect(container.read(isPlaceSavedProvider('meskel-walk')), isTrue);
      expect(
        prefs.getStringList(SavedPlacesStorage.storageKey),
        containsAll(['entoto-view', 'meskel-walk']),
      );

      await controller.toggle('entoto-view');
      expect(container.read(savedPlacesControllerProvider), {'meskel-walk'});
    });
  });
}
