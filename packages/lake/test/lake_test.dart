import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    const result = true;

    setUp(() {
      expect(result, true);
      // Additional setup goes here.
    });
  });
}
