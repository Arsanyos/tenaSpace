import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/saved_places_storage.dart';

/// Bookmarks. Exposed as an immutable `Set` so widgets can `select` a single
/// membership check and only rebuild when *their* place flips.
class SavedPlacesController extends Notifier<Set<String>> {
  @override
  Set<String> build() => ref.watch(savedPlacesStorageProvider).load();

  Future<void> toggle(String placeId) async {
    final next = {...state};
    if (!next.remove(placeId)) next.add(placeId);
    state = next;
    await ref.read(savedPlacesStorageProvider).save(next);
  }
}

final savedPlacesControllerProvider =
    NotifierProvider<SavedPlacesController, Set<String>>(
      SavedPlacesController.new,
    );

/// `ref.watch(isPlaceSavedProvider(id))` rebuilds only when that id changes.
final isPlaceSavedProvider = Provider.autoDispose.family<bool, String>((
  ref,
  placeId,
) {
  return ref.watch(
    savedPlacesControllerProvider.select((ids) => ids.contains(placeId)),
  );
});
