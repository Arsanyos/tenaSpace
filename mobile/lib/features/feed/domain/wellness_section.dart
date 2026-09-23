/// The four feed buckets. Titles fall back to these when Groq omits them.
enum WellnessSection {
  move('move', '🏃 Move Your Body', 'Move'),
  eat('eat', '🥗 Eat Well', 'Eat'),
  calm('calm', '🧘 Calm Places', 'Calm'),
  health('health', '🏥 Health Support', 'Health');

  const WellnessSection(this.wire, this.defaultTitle, this.filterLabel);

  final String wire;
  final String defaultTitle;
  final String filterLabel;

  static WellnessSection? fromWire(String? value) {
    for (final section in values) {
      if (section.wire == value) return section;
    }
    return null;
  }
}

/// Which kind of background audio a place supports.
enum AudioKind {
  walkingMix('walking-mix'),
  meditation('meditation'),
  ambient('ambient'),
  none('none');

  const AudioKind(this.wire);

  final String wire;

  static AudioKind? fromWire(String? value) {
    for (final kind in values) {
      if (kind.wire == value) return kind;
    }
    return null;
  }
}
