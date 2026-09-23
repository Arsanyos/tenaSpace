import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tenaspace/features/place/domain/fallback_ambient_wav.dart';

String _ascii(Uint8List bytes, int offset, int length) =>
    String.fromCharCodes(bytes.sublist(offset, offset + length));

void main() {
  test('buildFallbackAmbientWav produces a valid 16-bit mono PCM header', () {
    final wav = buildFallbackAmbientWav();
    final data = ByteData.sublistView(wav);

    expect(wav.length, 44 + 16000 * 6 * 2);
    expect(_ascii(wav, 0, 4), 'RIFF');
    expect(_ascii(wav, 8, 4), 'WAVE');
    expect(_ascii(wav, 12, 4), 'fmt ');
    expect(_ascii(wav, 36, 4), 'data');
    expect(data.getUint32(4, Endian.little), wav.length - 8);
    expect(data.getUint16(20, Endian.little), 1); // PCM
    expect(data.getUint16(22, Endian.little), 1); // mono
    expect(data.getUint32(24, Endian.little), 16000);
    expect(data.getUint16(34, Endian.little), 16);
    expect(data.getUint32(40, Endian.little), 16000 * 6 * 2);
  });

  test('fades in from silence and stays within range', () {
    final wav = buildFallbackAmbientWav(durationSeconds: 2);
    final data = ByteData.sublistView(wav);

    expect(data.getInt16(44, Endian.little), 0);

    var peak = 0;
    for (var offset = 44; offset < wav.length; offset += 2) {
      final sample = data.getInt16(offset, Endian.little).abs();
      if (sample > peak) peak = sample;
    }
    expect(peak, greaterThan(1000));
    expect(peak, lessThanOrEqualTo((0.22 * 1.2 * 0x7fff).round()));
  });
}
