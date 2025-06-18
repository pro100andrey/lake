import '../../ast/ast_visitor.dart';
import '../../ast/nodes/ast_nodes.dart';
import '../errors/error_reporter.dart';
import '../rules/base_rule.dart';
import '../rules/type_checking/const_identifier_resolution_rule.dart';
import '../semantic_types.dart';
import '../symbols/symbol_table.dart';
import '../utils.dart';

class TypeCheckingVisitor implements AstVisitor<void> {
  TypeCheckingVisitor(this._symbolTable, this._reporter)
    : _ruleDispatcher = RuleDispatcher() {
    _ruleDispatcher.addRule<ConstDefinitionNode>(
      ConstIdentifierResolutionRule(
        reporter: _reporter,
        symbolTable: _symbolTable,
      ),
    );
  }

  final SymbolTable _symbolTable;
  final ErrorReporter _reporter;
  final RuleDispatcher _ruleDispatcher;

  /// Visits the root node of the AST.
  @override
  void visitDocumentNode(DocumentNode node) {
    _ruleDispatcher.applyRules(node);

    for (final header in node.headers) {
      header.accept(this);
    }

    for (final definition in node.definitions) {
      definition.accept(this);
    }
  }

  @override
  void visitImportNode(ImportNode node) {
    _ruleDispatcher.applyRules(node);
  }

  @override
  void visitNamespaceNode(NamespaceNode node) {
    _ruleDispatcher.applyRules(node);
  }

  @override
  void visitConstDefinitionNode(ConstDefinitionNode node) {
    node.type.accept(this);
    node.value.accept(this);

    _ruleDispatcher.applyRules(node);
  }

  @override
  void visitTypedefDefinitionNode(TypedefDefinitionNode node) {
    _ruleDispatcher.applyRules(node);

    node.type.accept(this);

    final entry = _symbolTable.lookup(node.identifier.value, node.span);

    if (entry != null && entry.resolvedType is TypedefType) {
      final typedefSemanticType = entry.resolvedType!.cast<TypedefType>();
      final targetType = getSemanticType(node.type, _reporter, _symbolTable);

      if (targetType != null) {
        typedefSemanticType.targetType = targetType;
      }
    }
  }

  @override
  void visitEnumDefinitionNode(EnumDefinitionNode node) {}

  @override
  void visitEnumMemberNode(EnumMemberNode node) {}

  @override
  void visitStructDefinitionNode(StructDefinitionNode node) {
    _ruleDispatcher.applyRules(node);

    for (final field in node.fields) {
      field.accept(this);
    }
  }

  @override
  void visitUnionDefinitionNode(UnionDefinitionNode node) {
    _ruleDispatcher.applyRules(node);
  }

  @override
  void visitExceptionDefinitionNode(ExceptionDefinitionNode node) {
    _ruleDispatcher.applyRules(node);
  }

  @override
  void visitServiceDefinitionNode(ServiceDefinitionNode node) {
    _ruleDispatcher.applyRules(node);
  }

  @override
  void visitFieldRequirementNode(FieldRequirementNode node) {
    _ruleDispatcher.applyRules(node);
  }

  @override
  void visitFieldNode(FieldNode node) {
    _ruleDispatcher.applyRules(node);

    final fieldSemanticType = getSemanticType(
      node.type,
      _reporter,
      _symbolTable,
    );

    if (node.defaultValue != null && fieldSemanticType != null) {
      final defaultValueSemanticType = getLiteralValueSemanticType(
        node.defaultValue!,
        _reporter,
        _symbolTable,
      );

      if (defaultValueSemanticType != null) {
        if (!defaultValueSemanticType.isAssignableTo(fieldSemanticType)) {
          _reporter.reportLiteralValueCannotBeAssigned(
            literalTypeName: fieldSemanticType.name,
            valueKindName: 'default value',
            valueTypeName: defaultValueSemanticType.name,
            valueSpan: node.defaultValue!.span,
            literalTypeSpan: node.type.span,
            filePath: '<file_path>',
          );
        }
      }
    }

    node.type.accept(this);
  }

  @override
  void visitMethodNode(MethodNode node) {
    _ruleDispatcher.applyRules(node);

    for (final parameter in node.parameters) {
      parameter.accept(this);
    }
  }

  // Type nodes

  @override
  void visitBaseTypeNode(BaseTypeNode node) {
    _ruleDispatcher.applyRules(node);
  }

  @override
  void visitMapTypeNode(MapTypeNode node) {
    _ruleDispatcher.applyRules(node);

    node.keyType.accept(this);
    node.valueType.accept(this);
  }

  @override
  void visitSetTypeNode(SetTypeNode node) {
    _ruleDispatcher.applyRules(node);

    node.elementType.accept(this);
  }

  @override
  void visitListTypeNode(ListTypeNode node) {
    _ruleDispatcher.applyRules(node);

    node.elementType.accept(this);
  }

  @override
  void visitStreamTypeNode(StreamTypeNode node) {
    _ruleDispatcher.applyRules(node);

    node.elementType.accept(this);
  }

  @override
  void visitCustomTypeNode(CustomTypeNode node) {
    _ruleDispatcher.applyRules(node);
  }

  @override
  void visitVoidTypeNode(VoidTypeNode node) {
    _ruleDispatcher.applyRules(node);
  }

  // Literal value nodes

  @override
  void visitIntLiteralNode(IntLiteralNode node) {
    _ruleDispatcher.applyRules(node);
  }

  @override
  void visitDoubleLiteralNode(DoubleLiteralNode node) {
    _ruleDispatcher.applyRules(node);
  }

  @override
  void visitBoolLiteralNode(BoolLiteralNode node) {
    _ruleDispatcher.applyRules(node);
  }

  @override
  void visitStringLiteralNode(StringLiteralNode node) {
    _ruleDispatcher.applyRules(node);
  }

  @override
  void visitIdentifierNode(IdentifierNode node) {
    _ruleDispatcher.applyRules(node);
  }

  @override
  void visitListLiteralNode(ListLiteralNode node) {
    _ruleDispatcher.applyRules(node);
  }

  @override
  void visitMapLiteralNode(MapLiteralNode node) {
    _ruleDispatcher.applyRules(node);

    for (final entry in node.entries) {
      entry.key.accept(this);
      entry.value.accept(this);
    }
  }
}
