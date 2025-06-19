import 'package:lake_lang/lake_lang.dart';
import 'package:lake_lang/src/analyzer/engine/analysis_cache.dart';
import 'package:lake_lang/src/analyzer/engine/semantic_info.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

import 'analysis_cache_test.mocks.dart';

@GenerateNiceMocks(
  [MockSpec<DocumentNode>(), MockSpec<SemanticInfo>()],
)
void main() {
  group('AST Caching', () {
    late AnalysisCache cache;
    late MockDocumentNode mockAst1;
    late MockSemanticInfo mockSemanticInfo1;
    late MockDocumentNode mockAst2;
    late MockSemanticInfo mockSemanticInfo2;

    const filePath1 = 'file1.lake';
    const filePath2 = 'file2.lake';

    setUp(() {
      cache = AnalysisCache();
      mockAst1 = MockDocumentNode();
      mockAst2 = MockDocumentNode();
      mockSemanticInfo1 = MockSemanticInfo();
      mockSemanticInfo2 = MockSemanticInfo();
    });

    test('caches AST nodes', () {
      cache.setAst(filePath1, mockAst1);

      final cachedNode = cache.getAst(filePath1);
      expect(cachedNode, isNotNull);
      expect(cachedNode, equals(mockAst1));
    });

    test('setAst should update an existing AST', () {
      cache.setAst(filePath1, mockAst1);

      final updatedMockAst = MockDocumentNode();
      cache.setAst(filePath1, updatedMockAst);
      expect(cache.getAst(filePath1), equals(updatedMockAst));
    });

    group('Semantic Info Caching', () {
      test(
        'setSemanticInfo should store and getSemanticInfo should retrieve '
        'semantic info',
        () {
          cache.setSemanticInfo(filePath1, mockSemanticInfo1);
          expect(cache.getSemanticInfo(filePath1), equals(mockSemanticInfo1));
        },
      );
    });

    group('Invalidation', () {
      setUp(() {
        cache
          ..setAst(filePath1, mockAst1)
          ..setSemanticInfo(filePath1, mockSemanticInfo1)
          ..setAst(filePath2, mockAst2)
          ..setSemanticInfo(filePath2, mockSemanticInfo2);
      });

      test('invalidate should mark a file as invalidated', () {
        expect(cache.isInvalidated(filePath1), isFalse);
        cache.invalidate(filePath1);
        expect(cache.isInvalidated(filePath1), isTrue);
      });

      test('getAst should return null for an invalidated file', () {
        cache.invalidate(filePath1);
        expect(cache.getAst(filePath1), isNull);
      });

      test('setAst should re-validate an invalidated file', () {
        cache.invalidate(filePath1);
        expect(cache.isInvalidated(filePath1), isTrue);
        cache.setAst(filePath1, mockAst1);
        expect(cache.isInvalidated(filePath1), isFalse);
        expect(cache.getAst(filePath1), equals(mockAst1));
      });
    });

    group('clearAll', () {
      test('should clear all cached ASTs and invalidation flags', () {
        cache
          ..setAst(filePath1, mockAst1)
          ..setSemanticInfo(filePath1, mockSemanticInfo1)
          ..invalidate(filePath2);

        expect(cache.getAst(filePath1), isNotNull);
        expect(cache.isInvalidated(filePath2), isTrue);

        cache.clearAll();

        expect(cache.getAst(filePath1), isNull);
        expect(cache.getSemanticInfo(filePath1), equals(mockSemanticInfo1));
        expect(cache.isInvalidated(filePath2), isFalse);
      });
    });
  });
}
