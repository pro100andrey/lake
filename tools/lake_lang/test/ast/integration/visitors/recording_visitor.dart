import 'package:lake_lang/src/ast/ast_visitor.dart';
import 'package:lake_lang/src/parser/ast/ast_base.dart';

/// A simple AST visitor that records the runtime type of every visited node.
class RecordingVisitor extends AstVisitor<void> {
  const RecordingVisitor(this.visitedTypes);

  final List<Type> visitedTypes;

  @override
  void visitDocumentNode(DocumentNode node) {
    visitedTypes.add(node.runtimeType);
    for (final h in node.headers) {
      h.accept(this);
    }
    for (final d in node.definitions) {
      d.accept(this);
    }
  }

  @override
  void visitImportNode(ImportNode node) {
    visitedTypes.add(node.runtimeType);
    node.path.accept(this);
  }

  @override
  void visitNamespaceNode(NamespaceNode node) {
    visitedTypes.add(node.runtimeType);
    node.scope.accept(this);
    node.identifier.accept(this);
  }

  @override
  void visitConstDefinitionNode(ConstDefinitionNode node) {
    visitedTypes.add(node.runtimeType);
    node.type.accept(this);
    node.identifier.accept(this);
    node.value.accept(this);
  }

  @override
  void visitTypedefDefinitionNode(TypedefDefinitionNode node) {
    visitedTypes.add(node.runtimeType);
    node.type.accept(this);
    node.identifier.accept(this);
  }

  @override
  void visitEnumDefinitionNode(EnumDefinitionNode node) {
    visitedTypes.add(node.runtimeType);
    node.identifier.accept(this);
    for (final m in node.members) {
      m.accept(this);
    }
  }

  @override
  void visitEnumValueNode(EnumValueNode node) {
    visitedTypes.add(node.runtimeType);
    node.identifier.accept(this);
    node.value?.accept(this);
  }

  @override
  void visitStructDefinitionNode(StructDefinitionNode node) {
    visitedTypes.add(node.runtimeType);
    node.identifier.accept(this);
    for (final f in node.fields) {
      f.accept(this);
    }
  }

  @override
  void visitUnionDefinitionNode(UnionDefinitionNode node) {
    visitedTypes.add(node.runtimeType);
    node.identifier.accept(this);
    for (final f in node.fields) {
      f.accept(this);
    }
  }

  @override
  void visitExceptionDefinitionNode(ExceptionDefinitionNode node) {
    visitedTypes.add(node.runtimeType);
    node.identifier.accept(this);
    for (final f in node.fields) {
      f.accept(this);
    }
  }

  @override
  void visitServiceDefinitionNode(ServiceDefinitionNode node) {
    visitedTypes.add(node.runtimeType);
    node.identifier.accept(this);
    node.extendsService?.accept(this);
    for (final f in node.methods) {
      f.accept(this);
    }
  }

  @override
  void visitFieldNode(FieldNode node) {
    visitedTypes.add(node.runtimeType);
    node.fieldId?.accept(this);
    node.type.accept(this);
    node.identifier.accept(this);
    node.defaultValue?.accept(this);
  }

  @override
  void visitMethodNode(MethodNode node) {
    visitedTypes.add(node.runtimeType);
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
  void visitBaseTypeNode(BaseTypeNode node) {
    visitedTypes.add(node.runtimeType);
  }

  @override
  void visitMapTypeNode(MapTypeNode node) {
    visitedTypes.add(node.runtimeType);
  }

  @override
  void visitSetTypeNode(SetTypeNode node) {
    visitedTypes.add(node.runtimeType);
  }

  @override
  void visitListTypeNode(ListTypeNode node) {
    visitedTypes.add(node.runtimeType);
  }

  @override
  void visitStreamTypeNode(StreamTypeNode node) {
    visitedTypes.add(node.runtimeType);
  }

  @override
  void visitCustomTypeNode(CustomTypeNode node) {
    visitedTypes.add(node.runtimeType);
  }

  @override
  void visitVoidTypeNode(VoidTypeNode node) {
    visitedTypes.add(node.runtimeType);
  }

  @override
  void visitIntLiteralNode(IntLiteralNode node) {
    visitedTypes.add(node.runtimeType);
  }

  @override
  void visitDoubleLiteralNode(DoubleLiteralNode node) {
    visitedTypes.add(node.runtimeType);
  }

  @override
  void visitBoolLiteralNode(BoolLiteralNode node) {
    visitedTypes.add(node.runtimeType);
  }

  @override
  void visitStringLiteralNode(StringLiteralNode node) {
    visitedTypes.add(node.runtimeType);
  }

  @override
  void visitIdentifierNode(IdentifierNode node) {
    visitedTypes.add(node.runtimeType);
  }

  @override
  void visitListLiteralNode(ListLiteralNode node) {
    visitedTypes.add(node.runtimeType);
  }

  @override
  void visitMapLiteralNode(MapLiteralNode node) {
    visitedTypes.add(node.runtimeType);
  }
}
