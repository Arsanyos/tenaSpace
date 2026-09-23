import 'dart:math' as math;
import 'dart:typed_data';

/// Generates the 6-second, 16 kHz mono WAV loop the web player synthesises
/// when AI generation fails: a warm 174 Hz + 220 Hz drone with a slow
/// 0.17 Hz wobble and a 1.2 s fade at both ends.
///
/// Building it in Dart (instead of bundling a file) keeps the app free of
/// binary assets and mirrors `makeFallbackAmbientDataUrl` exactly.
Uint8List buildFallbackAmbientWav({
  int sampleRate = 16000,
  int durationSeconds = 6,
}) {
  final frameCount = sampleRate * durationSeconds;
  final dataLength = frameCount * 2;
  final bytes = ByteData(44 + dataLength);

  _writeAscii(bytes, 0, 'RIFF');
  bytes.setUint32(4, 36 + dataLength, Endian.little);
  _writeAscii(bytes, 8, 'WAVE');
  _writeAscii(bytes, 12, 'fmt ');
  bytes.setUint32(16, 16, Endian.little); // PCM chunk size
  bytes.setUint16(20, 1, Endian.little); // PCM format
  bytes.setUint16(22, 1, Endian.little); // mono
  bytes.setUint32(24, sampleRate, Endian.little);
  bytes.setUint32(28, sampleRate * 2, Endian.little); // byte rate
  bytes.setUint16(32, 2, Endian.little); // block align
  bytes.setUint16(34, 16, Endian.little); // bits per sample
  _writeAscii(bytes, 36, 'data');
  bytes.setUint32(40, dataLength, Endian.little);

  const twoPi = 2 * math.pi;
  for (var frame = 0; frame < frameCount; frame++) {
    final t = frame / sampleRate;
    final fadeIn = math.min(1.0, t / 1.2);
    final fadeOut = math.min(1.0, (durationSeconds - t) / 1.2);
    final envelope = math.min(fadeIn, fadeOut) * 0.22;
    final tone =
        math.sin(twoPi * 174 * t) * 0.62 +
        math.sin(twoPi * 220 * t) * 0.38 +
        math.sin(twoPi * 0.17 * t) * 0.2;
    final sample = (tone * envelope).clamp(-1.0, 1.0) * 0x7fff;
    bytes.setInt16(44 + frame * 2, sample.round(), Endian.little);
  }

  return bytes.buffer.asUint8List();
}

void _writeAscii(ByteData target, int offset, String value) {
  for (var i = 0; i < value.length; i++) {
    target.setUint8(offset + i, value.codeUnitAt(i));
  }
}
