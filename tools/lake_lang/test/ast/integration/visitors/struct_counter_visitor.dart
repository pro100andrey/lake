import 'package:lake_lang/src/ast/ast_visitor.dart';
import 'package:lake_lang/src/ast/nodes/ast_nodes.dart';

/// A simple AST visitor to count the number of struct definitions.
class StructCounterVisitor extends AstVisitor<void> {
  int structCount = 0;

  @override
  void visitDocumentNode(DocumentNode node) {
    // You'd typically call super.visitNode(node) if you had a base
    // visitor that handles traversal. Since AstVisitor is abstract
    // and forces implementation, explicit traversal is needed.
    for (final h in node.headers) {
      h.accept(this);
    }
    for (final d in node.definitions) {
      d.accept(this);
    }
  }

  @override
  void visitStructDefinitionNode(StructDefinitionNode node) {
    structCount++;
    // Continue traversal for nested elements like fields if needed for other
    // counts
    node.identifier.accept(this);
    for (final f in node.fields) {
      f.accept(this);
    }
  }

  // --- Implementations for all other AstVisitor methods ---
  // If you don't need to visit these nodes, you can throw UnimplementedError
  // or define a base visitor with default traversal behavior.
  // For simplicity in this example, we'll assume a default visitor handles
  // traversal or that explicit calls like in visitDocumentNode are used.
  // For this test, only visitStructDefinitionNode is essential.
  // In a real scenario, you'd have a base AstVisitor that handles default
  // recursive calls.

  // Placeholder implementations for all other abstract methods in AstVisitor
  // For a real visitor, you would implement the necessary traversal logic
  // in a base visitor (e.g., SimpleRecursiveAstVisitor) that then calls
  // super.visit...() to continue the traversal.
  // For this specific test, as it only counts structs, the other methods
  // can be empty if the parent DocumentNode handles all top-level traversals.
  // If not, they would typically call node.accept(this) for their children.

  @override
  void visitImportNode(ImportNode node) => node.path.accept(this);
  @override
  void visitNamespaceNode(NamespaceNode node) {
    node.scope.accept(this);
    node.identifier.accept(this);
  }

  @override
  void visitConstDefinitionNode(ConstDefinitionNode node) {
    node.type.accept(this);
    node.identifier.accept(this);
    node.value.accept(this);
  }

  @override
  void visitTypedefDefinitionNode(TypedefDefinitionNode node) {
    node.type.accept(this);
    node.identifier.accept(this);
  }

  @override
  void visitEnumDefinitionNode(EnumDefinitionNode node) {
    node.identifier.accept(this);
    for (final m in node.members) {
      m.accept(this);
    }
  }

  @override
  void visitEnumValueNode(EnumValueNode node) {
    node.identifier.accept(this);
    node.value?.accept(this);
  }

  @override
  void visitUnionDefinitionNode(UnionDefinitionNode node) {
    node.identifier.accept(this);
    for (final f in node.fields) {
      f.accept(this);
    }
  }

  @override
  void visitExceptionDefinitionNode(ExceptionDefinitionNode node) {
    node.identifier.accept(this);
    for (final f in node.fields) {
      f.accept(this);
    }
  }

  @override
  void visitServiceDefinitionNode(ServiceDefinitionNode node) {
    node.identifier.accept(this);
    node.extendsService?.accept(this);
    for (final f in node.functions) {
      f.accept(this);
    }
  }

  @override
  void visitFieldRequirementNode(FieldRequirementNode node) {}

  @override
  void visitFieldNode(FieldNode node) {
    node.fieldId?.accept(this);
    node.requirement?.accept(this);
    node.type.accept(this);
    node.identifier.accept(this);
    node.defaultValue?.accept(this);
  }

  @override
  void visitFunctionNode(FunctionNode node) {
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
  void visitBaseTypeNode(BaseTypeNode node) {}

  @override
  void visitMapTypeNode(MapTypeNode node) {}

  @override
  void visitSetTypeNode(SetTypeNode node) {}

  @override
  void visitListTypeNode(ListTypeNode node) {}

  @override
  void visitStreamTypeNode(StreamTypeNode node) {}

  @override
  void visitCustomTypeNode(CustomTypeNode node) {}

  @override
  void visitVoidTypeNode(VoidTypeNode node) {}

  @override
  void visitIntConstantNode(IntConstantNode node) {}

  @override
  void visitDoubleConstantNode(DoubleConstantNode node) {}

  @override
  void visitBoolConstantNode(BoolConstantNode node) {}

  @override
  void visitLiteralNode(LiteralNode node) {}

  @override
  void visitIdentifierNode(IdentifierNode node) {}

  @override
  void visitConstListNode(ConstListNode node) {}

  @override
  void visitConstMapNode(ConstMapNode node) {}
}
