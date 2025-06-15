import 'package:lake_lang/src/ast/ast_visitor.dart';
import 'package:lake_lang/src/ast/base/types.dart';
import 'package:lake_lang/src/ast/nodes/ast_nodes.dart';
import 'package:test/test.dart';

class RecordingVisitor extends AstVisitor<void> {
  final List<String> calls = [];

  void _record(String name) => calls.add(name);

  @override
  void visitDocumentNode(DocumentNode node) => _record('visitDocumentNode');

  @override
  void visitImportNode(ImportNode node) => _record('visitImportNode');

  @override
  void visitNamespaceNode(NamespaceNode node) => _record('visitNamespaceNode');

  @override
  void visitConstDefinitionNode(ConstDefinitionNode node) =>
      _record('visitConstDefinitionNode');

  @override
  void visitTypedefDefinitionNode(TypedefDefinitionNode node) =>
      _record('visitTypedefDefinitionNode');

  @override
  void visitEnumDefinitionNode(EnumDefinitionNode node) =>
      _record('visitEnumDefinitionNode');

  @override
  void visitEnumValueNode(EnumValueNode node) => _record('visitEnumValueNode');

  @override
  void visitStructDefinitionNode(StructDefinitionNode node) =>
      _record('visitStructDefinitionNode');

  @override
  void visitUnionDefinitionNode(UnionDefinitionNode node) =>
      _record('visitUnionDefinitionNode');

  @override
  void visitExceptionDefinitionNode(ExceptionDefinitionNode node) =>
      _record('visitExceptionDefinitionNode');

  @override
  void visitServiceDefinitionNode(ServiceDefinitionNode node) =>
      _record('visitServiceDefinitionNode');

  @override
  void visitFieldRequirementNode(FieldRequirementNode node) =>
      _record('visitFieldRequirementNode');

  @override
  void visitFieldNode(FieldNode node) => _record('visitFieldNode');

  @override
  void visitFunctionNode(FunctionNode node) => _record('visitFunctionNode');

  @override
  void visitBaseTypeNode(BaseTypeNode node) => _record('visitBaseTypeNode');

  @override
  void visitMapTypeNode(MapTypeNode node) => _record('visitMapTypeNode');

  @override
  void visitSetTypeNode(SetTypeNode node) => _record('visitSetTypeNode');

  @override
  void visitListTypeNode(ListTypeNode node) => _record('visitListTypeNode');

  @override
  void visitStreamTypeNode(StreamTypeNode node) =>
      _record('visitStreamTypeNode');

  @override
  void visitCustomTypeNode(CustomTypeNode node) =>
      _record('visitCustomTypeNode');

  @override
  void visitVoidTypeNode(VoidTypeNode node) => _record('visitVoidTypeNode');

  @override
  void visitIntConstantNode(IntConstantNode node) =>
      _record('visitIntConstantNode');

  @override
  void visitDoubleConstantNode(DoubleConstantNode node) =>
      _record('visitDoubleConstantNode');

  @override
  void visitBoolConstantNode(BoolConstantNode node) =>
      _record('visitBoolConstantNode');

  @override
  void visitLiteralNode(LiteralNode node) => _record('visitLiteralNode');

  @override
  void visitIdentifierNode(IdentifierNode node) =>
      _record('visitIdentifierNode');

  @override
  void visitConstListNode(ConstListNode node) => _record('visitConstListNode');

  @override
  void visitConstMapNode(ConstMapNode node) => _record('visitConstMapNode');
}

Span _dummySpan() => (start: 0, end: 0);

void main() {
  group('AST Visitor integration', () {
    test('calls correct visit methods for all node types', () {
      final visitor = RecordingVisitor();

      // Create minimal nodes for each type
      final literal = LiteralNode(rawValue: '"str"', span: _dummySpan());
      final ident = IdentifierNode(value: 'foo', span: _dummySpan());
      final intConst = IntConstantNode(rawValue: '1', span: _dummySpan());
      final doubleConst = DoubleConstantNode(
        rawValue: '1.0',
        span: _dummySpan(),
      );
      final boolConst = BoolConstantNode(rawValue: 'true', span: _dummySpan());
      final constList = ConstListNode(elements: [intConst], span: _dummySpan());
      final constMap = ConstMapNode(
        entries: [(key: intConst, value: literal)],
        span: _dummySpan(),
      );

      final baseType = BaseTypeNode(value: 'i32', span: _dummySpan());
      final customType = CustomTypeNode(value: 'MyType', span: _dummySpan());
      final voidType = VoidTypeNode(span: _dummySpan());
      final mapType = MapTypeNode(
        keyType: baseType,
        valueType: customType,
        span: _dummySpan(),
      );
      final setType = SetTypeNode(elementType: baseType, span: _dummySpan());
      final listType = ListTypeNode(elementType: baseType, span: _dummySpan());
      final streamType = StreamTypeNode(
        elementType: baseType,
        span: _dummySpan(),
      );

      final fieldReq = FieldRequirementNode(
        value: 'required',
        span: _dummySpan(),
      );
      final field = FieldNode(
        fieldId: intConst,
        requirement: fieldReq,
        type: baseType,
        identifier: ident,
        defaultValue: intConst,
        span: _dummySpan(),
      );
      final func = FunctionNode(
        returnType: baseType,
        identifier: ident,
        parameters: [field],
        throws: [field],
        span: _dummySpan(),
      );
      final enumValue = EnumValueNode(
        identifier: ident,
        value: intConst,
        span: _dummySpan(),
      );
      final enumDef = EnumDefinitionNode(
        identifier: ident,
        members: [enumValue],
        span: _dummySpan(),
      );
      final structDef = StructDefinitionNode(
        identifier: ident,
        fields: [field],
        span: _dummySpan(),
      );
      final unionDef = UnionDefinitionNode(
        identifier: ident,
        fields: [field],
        span: _dummySpan(),
      );
      final excDef = ExceptionDefinitionNode(
        identifier: ident,
        fields: [field],
        span: _dummySpan(),
      );
      final serviceDef = ServiceDefinitionNode(
        identifier: ident,
        extendsService: ident,
        functions: [func],
        span: _dummySpan(),
      );
      final constDef = ConstDefinitionNode(
        type: baseType,
        identifier: ident,
        value: intConst,
        span: _dummySpan(),
      );
      final typedefDef = TypedefDefinitionNode(
        type: baseType,
        identifier: ident,
        span: _dummySpan(),
      );
      final importNode = ImportNode(path: literal, span: _dummySpan());
      final nsNode = NamespaceNode(
        scope: ident,
        identifier: ident,
        span: _dummySpan(),
      );

      final doc = DocumentNode(
        headers: [importNode, nsNode],
        definitions: [
          constDef,
          typedefDef,
          enumDef,
          structDef,
          unionDef,
          excDef,
          serviceDef,
        ],
        span: _dummySpan(),
      );

      // Accept visitor for each node type
      doc.accept(visitor);
      importNode.accept(visitor);
      nsNode.accept(visitor);
      constDef.accept(visitor);
      typedefDef.accept(visitor);
      enumDef.accept(visitor);
      enumValue.accept(visitor);
      structDef.accept(visitor);
      unionDef.accept(visitor);
      excDef.accept(visitor);
      serviceDef.accept(visitor);
      fieldReq.accept(visitor);
      field.accept(visitor);
      func.accept(visitor);
      baseType.accept(visitor);
      mapType.accept(visitor);
      setType.accept(visitor);
      listType.accept(visitor);
      streamType.accept(visitor);
      customType.accept(visitor);
      voidType.accept(visitor);
      intConst.accept(visitor);
      doubleConst.accept(visitor);
      boolConst.accept(visitor);
      literal.accept(visitor);
      ident.accept(visitor);
      constList.accept(visitor);
      constMap.accept(visitor);

      final expected = [
        'visitDocumentNode',
        'visitImportNode',
        'visitNamespaceNode',
        'visitConstDefinitionNode',
        'visitTypedefDefinitionNode',
        'visitEnumDefinitionNode',
        'visitEnumValueNode',
        'visitStructDefinitionNode',
        'visitUnionDefinitionNode',
        'visitExceptionDefinitionNode',
        'visitServiceDefinitionNode',
        'visitFieldRequirementNode',
        'visitFieldNode',
        'visitFunctionNode',
        'visitBaseTypeNode',
        'visitMapTypeNode',
        'visitSetTypeNode',
        'visitListTypeNode',
        'visitStreamTypeNode',
        'visitCustomTypeNode',
        'visitVoidTypeNode',
        'visitIntConstantNode',
        'visitDoubleConstantNode',
        'visitBoolConstantNode',
        'visitLiteralNode',
        'visitIdentifierNode',
        'visitConstListNode',
        'visitConstMapNode',
      ];

      for (final method in expected) {
        expect(visitor.calls, contains(method), reason: 'Should call $method');
      }
    });
  });
}
