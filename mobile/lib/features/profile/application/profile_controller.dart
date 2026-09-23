import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/profile_storage.dart';
import '../domain/wellness_profile.dart';

/// Holds the **committed** wellness profile — the one the feed is curated
/// against. Onboarding edits a separate draft and only calls [commit] at the
/// end, so the (expensive) Groq curation never re-runs mid-onboarding.
class ProfileController extends Notifier<WellnessProfile> {
  @override
  WellnessProfile build() => ref.watch(profileStorageProvider).load();

  Future<void> commit(WellnessProfile profile) async {
    state = profile;
    await ref.read(profileStorageProvider).save(profile);
  }

  /// "Explore as Guest": persists an empty profile so the feed still loads.
  Future<void> continueAsGuest() => commit(WellnessProfile.empty);
}

final profileControllerProvider =
    NotifierProvider<ProfileController, WellnessProfile>(ProfileController.new);
