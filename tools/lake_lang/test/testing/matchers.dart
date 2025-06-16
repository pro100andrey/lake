import 'package:lake_lang/src/ast/base/types.dart';
import 'package:test/test.dart';

class HasSpan extends Matcher {
  HasSpan(this.expectedStart, this.expectedEnd);
  final int expectedStart;
  final int expectedEnd;

  @override
  bool matches(Object? item, Map matchState) {
    if (item is! Span) {
      matchState['type'] = item.runtimeType;
      return false;
    }

    return item.start == expectedStart && item.end == expectedEnd;
  }

  @override
  Description describe(Description description) => description
      .add('has span starting at ')
      .addDescriptionOf(expectedStart)
      .add(' and ending at ')
      .addDescriptionOf(expectedEnd);

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! Span) {
      return mismatchDescription.add(
        'is not a Span (actual type: ${matchState['type']})',
      );
    }

    return mismatchDescription
        .add('has span starting at ')
        .addDescriptionOf(item.start)
        .add(' and ending at ')
        .addDescriptionOf(item.end)
        .add(' (expected: start ')
        .addDescriptionOf(expectedStart)
        .add(', end ')
        .addDescriptionOf(expectedEnd)
        .add(')');
  }
}

/// A convenience function to create a [HasSpan] matcher.
/// Example: `expect(node.span, hasSpan(0, 21));`
Matcher hasSpan(int start, int end) => HasSpan(start, end);
