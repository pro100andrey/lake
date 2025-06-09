// ignore_for_file: avoid_print

import '../../ast_visitor.dart';
import '../../nodes/ast_nodes.dart';
import '../error_reporter.dart';
import '../rules/semantic_rule.dart';
import '../semantic_types.dart';
import '../symbol_table.dart';
import '../utils.dart';

class TypeCheckingVisitor implements AstVisitor<void> {
  TypeCheckingVisitor(this._symbolTable, this._reporter) {
    _addRule<ConstDefinitionNode>(
      ConstDefinitionNode,
      ConstTypeCheckRule(_reporter, _symbolTable),
    );

    _addRule<EnumValueNode>(
      EnumValueNode,
      EnumValueTypeRule(_reporter, _symbolTable),
    );

    _addRule<ServiceDefinitionNode>(
      ServiceDefinitionNode,
      ServiceInheritanceRule(_reporter, _symbolTable),
    );
  }

  final Map<Type, List<SemanticRule>> _ruleMap = {};

  final SymbolTable _symbolTable;
  final ErrorReporter _reporter;

  void _addRule<T extends AstNode>(Type nodeType, SemanticRule rule) {
    _ruleMap.putIfAbsent(nodeType, () => []).add(rule);
  }

  void _applyRules(AstNode node) {
    final rulesForNode = _ruleMap[node.runtimeType];
    if (rulesForNode != null) {
      for (final rule in rulesForNode) {
        rule.check(node);
      }
    }
  }

  /// Visits the root node of the AST.
  @override
  void visitDocumentNode(DocumentNode node) {
    _applyRules(node);

    for (final header in node.headers) {
      header.accept(this);
    }

    for (final definition in node.definitions) {
      definition.accept(this);
    }
  }

  @override
  void visitImportNode(ImportNode node) {
    _applyRules(node);
  }

  @override
  void visitNamespaceNode(NamespaceNode node) {
    _applyRules(node);
  }

  @override
  void visitConstDefinitionNode(ConstDefinitionNode node) {
    _applyRules(node);

    node.value.accept(this);
    node.value.accept(this);
  }

  @override
  void visitTypedefDefinitionNode(TypedefDefinitionNode node) {
    _applyRules(node);

    node.type.accept(this);

    final entry = _symbolTable.lookup(node.identifier.value, node.span);
    if (entry != null && entry.resolvedType is TypedefType) {
      final targetType = getSemanticType(node.type, _reporter, _symbolTable);

      if (targetType != null) {
        // entry.resolvedType.setTargetType(targetType);
      }
    }
  }

  @override
  void visitEnumDefinitionNode(EnumDefinitionNode node) {}

  @override
  void visitEnumValueNode(EnumValueNode node) {}

  @override
  void visitStructDefinitionNode(StructDefinitionNode node) {}

  @override
  void visitExceptionDefinitionNode(ExceptionDefinitionNode node) {}

  @override
  void visitServiceDefinitionNode(ServiceDefinitionNode node) {}

  @override
  void visitFieldRequirementNode(FieldRequirementNode node) {}

  @override
  void visitFieldNode(FieldNode node) {}

  @override
  void visitFunctionNode(FunctionNode node) {}

  // Type nodes

  @override
  void visitBaseTypeNode(BaseTypeNode node) {
    _applyRules(node);
  }

  @override
  void visitMapTypeNode(MapTypeNode node) {
    _applyRules(node);

    node.keyType.accept(this);
    node.valueType.accept(this);
  }

  @override
  void visitSetTypeNode(SetTypeNode node) {
    _applyRules(node);

    node.elementType.accept(this);
  }

  @override
  void visitListTypeNode(ListTypeNode node) {
    _applyRules(node);

    node.elementType.accept(this);
  }

  @override
  void visitStreamTypeNode(StreamTypeNode node) {
    _applyRules(node);

    node.elementType.accept(this);
  }

  @override
  void visitCustomTypeNode(CustomTypeNode node) {
    _applyRules(node);
  }

  @override
  void visitVoidTypeNode(VoidTypeNode node) {
    _applyRules(node);
  }

  // Constant value nodes

  @override
  void visitIntConstantNode(IntConstantNode node) {}

  @override
  void visitDoubleConstantNode(DoubleConstantNode node) {}

  @override
  void visitLiteralNode(LiteralNode node) {}

  @override
  void visitIdentifierNode(IdentifierNode node) {}

  @override
  void visitConstListNode(ConstListNode node) {}

  @override
  void visitConstMapNode(ConstMapNode node) {}
}
