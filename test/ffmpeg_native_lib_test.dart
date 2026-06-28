import 'package:test/test.dart';

import 'package:ffmpeg_native_lib/ffmpeg_native_lib.dart';

void main() {
  test('invoke native function', () {
    expect(sum(24, 18), 42);
  });

  test('invoke async native callback', () async {
    expect(await sumAsync(24, 18), 42);
  });
}
