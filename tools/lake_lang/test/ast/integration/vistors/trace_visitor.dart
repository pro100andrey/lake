import 'package:lake_lang/src/ast/ast_visitor.dart';
import 'package:lake_lang/src/ast/nodes/ast_nodes.dart';

/// A simple AST visitor that records the sequence of visited nodes for tracing
/// traversal order.
class TraceVisitor extends AstVisitor<void> {
  final List<String> trace = [];

  void _t(String s) => trace.add(s);

  @override
  void visitDocumentNode(DocumentNode node) {
    _t('doc');
    for (final h in node.headers) {
      h.accept(this);
    }
    for (final d in node.definitions) {
      d.accept(this);
    }
  }

  @override
  void visitImportNode(ImportNode node) {
    _t('import');
    node.path.accept(this);
  }

  @override
  void visitNamespaceNode(NamespaceNode node) {
    _t('namespace');
    node.scope.accept(this);
    node.identifier.accept(this);
  }

  @override
  void visitConstDefinitionNode(ConstDefinitionNode node) {
    _t('const');
    node.type.accept(this);
    node.identifier.accept(this);
    node.value.accept(this);
  }

  @override
  void visitTypedefDefinitionNode(TypedefDefinitionNode node) {
    _t('typedef');
    node.type.accept(this);
    node.identifier.accept(this);
  }

  @override
  void visitEnumDefinitionNode(EnumDefinitionNode node) {
    _t('enum');
    node.identifier.accept(this);
    for (final m in node.members) {
      m.accept(this);
    }
  }

  @override
  void visitEnumValueNode(EnumValueNode node) {
    _t('enumValue');
    node.identifier.accept(this);
    node.value?.accept(this);
  }

  @override
  void visitStructDefinitionNode(StructDefinitionNode node) {
    _t('struct');
    node.identifier.accept(this);
    for (final f in node.fields) {
      f.accept(this);
    }
  }

  @override
  void visitUnionDefinitionNode(UnionDefinitionNode node) {
    _t('union');
    node.identifier.accept(this);
    for (final f in node.fields) {
      f.accept(this);
    }
  }

  @override
  void visitExceptionDefinitionNode(ExceptionDefinitionNode node) {
    _t('exception');
    node.identifier.accept(this);
    for (final f in node.fields) {
      f.accept(this);
    }
  }

  @override
  void visitServiceDefinitionNode(ServiceDefinitionNode node) {
    _t('service');
    node.identifier.accept(this);
    node.extendsService?.accept(this);
    for (final f in node.functions) {
      f.accept(this);
    }
  }

  @override
  void visitFieldRequirementNode(FieldRequirementNode node) => _t('fieldReq');
  @override
  void visitFieldNode(FieldNode node) {
    _t('field');
    node.fieldId?.accept(this);
    node.requirement?.accept(this);
    node.type.accept(this);
    node.identifier.accept(this);
    node.defaultValue?.accept(this);
  }

  @override
  void visitFunctionNode(FunctionNode node) {
    _t('func');
    node.returnType.accept(this);
    node.identifier.accept(this);
    for (final p in node.parameters) {
      p.accept(this);
    }
    for (final t in node.throws) {
      t.accept(this);
    }
  }

  @override
  void visitBaseTypeNode(BaseTypeNode node) => _t('baseType');
  @override
  void visitMapTypeNode(MapTypeNode node) => _t('mapType');
  @override
  void visitSetTypeNode(SetTypeNode node) => _t('setType');
  @override
  void visitListTypeNode(ListTypeNode node) => _t('listType');
  @override
  void visitStreamTypeNode(StreamTypeNode node) => _t('streamType');
  @override
  void visitCustomTypeNode(CustomTypeNode node) => _t('customType');
  @override
  void visitVoidTypeNode(VoidTypeNode node) => _t('voidType');
  @override
  void visitIntConstantNode(IntConstantNode node) => _t('intConst');
  @override
  void visitDoubleConstantNode(DoubleConstantNode node) => _t('doubleConst');
  @override
  void visitBoolConstantNode(BoolConstantNode node) => _t('boolConst');
  @override
  void visitLiteralNode(LiteralNode node) => _t('literal');
  @override
  void visitIdentifierNode(IdentifierNode node) => _t('ident');
  @override
  void visitConstListNode(ConstListNode node) => _t('constList');
  @override
  void visitConstMapNode(ConstMapNode node) => _t('constMap');
}
