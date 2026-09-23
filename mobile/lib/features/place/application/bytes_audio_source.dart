// StreamAudioSource is flagged experimental by just_audio, but it is the
// documented way to play in-memory data without writing a temp file.
// ignore_for_file: experimental_member_use

import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';

/// Serves an in-memory buffer to just_audio through its local proxy, so AI
/// generated clips can play without ever touching the file system.
class BytesAudioSource extends StreamAudioSource {
  BytesAudioSource(this._bytes, {required this.contentType})
    : super(tag: 'tenaspace-generated-audio');

  final Uint8List _bytes;
  final String contentType;

  int get length => _bytes.length;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final from = start ?? 0;
    final to = end ?? _bytes.length;
    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: to - from,
      offset: from,
      stream: Stream.value(_bytes.sublist(from, to)),
      contentType: contentType,
    );
  }
}
