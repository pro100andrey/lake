import '../../ast/ast_visitor.dart';
import '../../parser/ast/ast_base.dart';
import '../errors/error_reporter.dart';
import '../rules/base_rule.dart';
import '../rules/declaration/keyword_as_identifier_rule.dart';
import '../rules/declaration/literal_assignment_type_rule.dart';
import '../rules/declaration/non_empty_enum_definition_rule.dart';
import '../rules/declaration/non_empty_struct_definition_rule.dart';
import '../rules/declaration/optional_field_rule.dart';
import '../rules/declaration/required_field_rule.dart';
import '../rules/declaration/union_field_modifiers_rule.dart';
import '../rules/declaration/unique_field_id_rule.dart';
import '../semantic_types.dart';
import '../symbols/symbol_entry.dart';
import '../symbols/symbol_table.dart';

class SymbolTableVisitor extends AstVisitor<void> {
  SymbolTableVisitor(this._symbolTable, this._reporter)
    : _ruleDispatcher = RuleDispatcher() {
    _ruleDispatcher
      ..addRule<ConstDefinitionNode>(
        LiteralAssignmentTypeRule(reporter: _reporter),
      )
      ..addRule<EnumDefinitionNode>(
        NonEmptyEnumDefinitionRule(reporter: _reporter),
      )
      ..addRule<StructDefinitionNode>(
        NonEmptyStructDefinitionRule(reporter: _reporter),
      )
      ..addRule<StructDefinitionNode>(
        UniqueFieldIdRule<StructDefinitionNode>(reporter: _reporter),
      )
      ..addRule<UnionDefinitionNode>(
        UniqueFieldIdRule<UnionDefinitionNode>(reporter: _reporter),
      )
      ..addRule<UnionDefinitionNode>(
        UnionFieldModifiersRule(reporter: _reporter),
      )
      ..addRule<ExceptionDefinitionNode>(
        UniqueFieldIdRule<ExceptionDefinitionNode>(reporter: _reporter),
      )
      ..addRule<MethodNode>(
        UniqueFieldIdRule<MethodNode>(reporter: _reporter),
      )
      ..addRule<IdentifierNode>(
        KeywordAsIdentifierRule(reporter: _reporter),
      )
      // Rules for field declarations
      ..addRule<FieldNode>(
        RequiredFieldRule(reporter: _reporter),
      )
      ..addRule<FieldNode>(
        OptionalFieldRule(reporter: _reporter),
      );
  }

  final SymbolTable _symbolTable;
  final ErrorReporter _reporter;
  final RuleDispatcher _ruleDispatcher;

  // --- Visit Methods ---
  // Each visit method:
  // 1. Adds declarations to the symbol table using the appropriate SymbolKind.
  // 2. Manages scope changes (push/pop scope) for nodes that introduce new
  // scopes.
  // 3. Recursively calls .accept(this) on child nodes to continue traversal.

  @override
  void visitDocumentNode(DocumentNode node) {
    // The top-level document usually represents the global scope.
    // The SymbolTable is typically initialized with a global scope.
    // So, no push/pop scope here for the document itself.
    for (final header in node.headers) {
      header.accept(this);
    }

    for (final definition in node.definitions) {
      definition.accept(this);
    }
  }

  @override
  void visitImportNode(ImportNode node) {
    // Imports themselves don't introduce symbols into the current scope.
    // Their resolution happens outside the SymbolTableVisitor's primary role.
  }

  @override
  void visitNamespaceNode(NamespaceNode node) {
    // For Lake, assuming namespaces are more for organization and don't
    // introduce distinct symbol table scopes by default, or that they are
    // handled by a higher-level module resolution. If they DO introduce
    // scopes, manage them here.
    // _symbolTable.pushScope(name: node.identifier.name);
    // node.identifier.accept(this); // Visit identifier if needed
    // _symbolTable.popScope();
  }

  @override
  void visitConstDefinitionNode(ConstDefinitionNode node) {
    _ruleDispatcher.applyRules(node);

    _symbolTable.addSymbol(
      name: node.identifier.name,
      kind: SymbolKind.constant,
      declaration: node,
      resolvedType: null, // Resolved in TypeCheckingVisitor
    );

    // Continue visiting children to ensure all parts of the AST are covered
    node.type.accept(this);
    node.value.accept(this);
  }

  @override
  void visitTypedefDefinitionNode(TypedefDefinitionNode node) {
    // Add the typedef identifier to the current scope.
    // Create the semantic type for the typedef itself.
    final typedefSemanticType = TypedefType(node);

    _symbolTable.addSymbol(
      name: node.identifier.name,
      kind: SymbolKind.type,
      declaration: node,
      resolvedType: typedefSemanticType,
    );

    // Visit the aliased type. Its resolution will happen in the
    // TypeCheckingVisitor.
    node.type.accept(this);
  }

  @override
  void visitEnumDefinitionNode(EnumDefinitionNode node) {
    // Apply rules for enum definitions, e.g., non-empty enum check.
    _ruleDispatcher.applyRules(node);

    // Create the semantic type for the enum itself.
    final enumSemanticType = EnumType(node);
    // Add the enum definition to the current scope.
    _symbolTable
      ..addSymbol(
        name: node.identifier.name,
        kind: SymbolKind.type,
        declaration: node,
        resolvedType: enumSemanticType, // Set the enum's own semantic type
      )
      // Enums introduce a new scope for their members.
      ..pushScope();

    for (final value in node.members) {
      value.accept(this);
    }

    // Pop the scope after processing all enum members.
    _symbolTable.popScope();
  }

  @override
  void visitEnumValueNode(EnumValueNode node) {
    // Add each enum value as an enum member within the enum's scope.
    _symbolTable.addSymbol(
      name: node.identifier.name,
      kind: SymbolKind.enumMember,
      declaration: node,
      //Type (parent EnumType) will be resolved by TypeCheckingVisitor
      resolvedType: null,
    );

    // Visit the optional literal value assigned to the enum member.
    node.value?.accept(this);
  }

  @override
  void visitStructDefinitionNode(StructDefinitionNode node) {
    // Apply rules for struct definitions, e.g., non-empty struct check.
    _ruleDispatcher.applyRules(node);
    // Create the semantic type for the struct itself.
    final structSemanticType = StructType(node);
    // Add the struct definition to the current scope.
    _symbolTable
      ..addSymbol(
        name: node.identifier.name,
        kind: SymbolKind.type,
        declaration: node,
        resolvedType: structSemanticType, // Set the struct's own semantic type
      )
      // Structs introduce a new scope for their fields.
      ..pushScope();

    for (final field in node.fields) {
      field.accept(this);
    }

    // Pop the scope after processing all struct fields.
    _symbolTable.popScope();
  }

  @override
  void visitUnionDefinitionNode(UnionDefinitionNode node) {
    // Create the semantic type for the union itself.
    final unionSemanticType = UnionType(node);
    // Add the union definition to the current scope.
    _symbolTable
      ..addSymbol(
        name: node.identifier.name,
        kind: SymbolKind.type,
        declaration: node,
        resolvedType: unionSemanticType,
      )
      // Unions introduce a new scope for their fields.
      ..pushScope();

    for (final field in node.fields) {
      field.accept(this);
    }

    // Pop the scope after processing all union fields.
    _symbolTable.popScope();
  }

  @override
  void visitExceptionDefinitionNode(ExceptionDefinitionNode node) {
    // Create the semantic type for the exception itself.
    final exceptionSemanticType = ExceptionType(node);
    // Add the exception definition to the current scope.
    _symbolTable
      ..addSymbol(
        name: node.identifier.name,
        kind: SymbolKind.type,
        declaration: node,
        // Set the exception's own semantic type
        resolvedType: exceptionSemanticType,
      )
      // Exceptions introduce a new scope for their fields.
      ..pushScope();

    for (final field in node.fields) {
      field.accept(this);
    }

    // Pop the scope after processing all exception fields.
    _symbolTable.popScope();
  }

  @override
  void visitServiceDefinitionNode(ServiceDefinitionNode node) {
    // Create the semantic type for the service itself.
    final serviceSemanticType = ServiceType(node);
    // Add the service definition to the current scope.
    _symbolTable
      ..addSymbol(
        name: node.identifier.name,
        kind: SymbolKind.service,
        declaration: node,
        resolvedType: serviceSemanticType,
      )
      // Services introduce a new scope for their methods.
      ..pushScope();

    // Visit the extended service identifier (if any)
    // This is an IdentifierNode, no symbol added for it here.
    node.extendsService?.accept(this);

    for (final method in node.methods) {
      method.accept(this);
    }

    // Pop the scope after processing all service methods.
    _symbolTable.popScope();
  }

  @override
  void visitFieldNode(FieldNode node) {
    // Apply rules for field declarations, e.g., field requirement checks.
    _ruleDispatcher.applyRules(node);
    // Add the field to the current (struct/exception/service) scope.

    _symbolTable.addSymbol(
      name: node.identifier.name,
      kind: SymbolKind.field,
      declaration: node,
      resolvedType: null, // Type will be resolved by TypeCheckingVisitor
    );

    // Visit the field's type, default value, and requirement (if any).
    node.type.accept(this);
    node.defaultValue?.accept(this);
  }

  @override
  void visitMethodNode(MethodNode node) {
    // Add the  to the current (service) scope.
    _symbolTable
      ..addSymbol(
        name: node.identifier.name,
        kind: SymbolKind.method,
        declaration: node,
        resolvedType: null, // A MethodType will be set by TypeCheckingVisitor
      )
      // Methods introduce a new scope for their parameters and throws.
      ..pushScope();

    // Visit the return type.
    node.returnType.accept(this);

    for (final param in node.parameters) {
      // Parameters are FieldNodes, but in method context, they are
      // parameters.
      _symbolTable.addSymbol(
        name: param.identifier.name,
        kind: SymbolKind.parameter,
        declaration: param,
        // Parameter type will be resolved by TypeCheckingVisitor
        resolvedType: null,
      );

      // Visit parameter types
      param.type.accept(this);
    }

    // Visit throw exception types (which are TypeNodes).
    for (final throwType in node.throws) {
      throwType.accept(this);
    }

    // Pop the scope after processing all method parameters and throws.
    _symbolTable.popScope();
  }

  // --- Type Nodes ---
  // These nodes define types but don't introduce new symbols *themselves*
  // into the current scope; rather, they are parts of declarations or usages.
  // Their inner structure might contain types that need to be visited.

  @override
  void visitBaseTypeNode(BaseTypeNode node) {}

  @override
  void visitMapTypeNode(MapTypeNode node) {
    node.keyType.accept(this);
    node.valueType.accept(this);
  }

  @override
  void visitSetTypeNode(SetTypeNode node) {
    node.elementType.accept(this);
  }

  @override
  void visitListTypeNode(ListTypeNode node) {
    node.elementType.accept(this);
  }

  @override
  void visitStreamTypeNode(StreamTypeNode node) {
    node.elementType.accept(this);
  }

  @override
  void visitCustomTypeNode(CustomTypeNode node) {
    // This node represents a *usage* of a type, not its definition.
    // Resolution (lookup in symbol table) happens in TypeCheckingVisitor.
  }

  @override
  void visitVoidTypeNode(VoidTypeNode node) {
    // No symbols to add for void type.
  }

  // --- Literal Value Nodes ---
  // These nodes represent literal values or expressions.
  // They don't introduce new symbols, but their components (e.g., identifiers
  // within a literal expression) might need to be visited.

  @override
  void visitIntLiteralNode(IntLiteralNode node) {}

  @override
  void visitDoubleLiteralNode(DoubleLiteralNode node) {}

  @override
  void visitBoolLiteralNode(BoolLiteralNode node) {}

  @override
  void visitStringLiteralNode(StringLiteralNode node) {}

  @override
  void visitIdentifierNode(IdentifierNode node) {
    // Apply rules for identifier usage, e.g., invalid identifier names.
    _ruleDispatcher.applyRules(node);
    // This node represents a *usage* of an identifier.
    // SymbolTableVisitor's job is primarily to *define* symbols.
    // Looking up uses of symbols is typically done in TypeCheckingVisitor
  }

  @override
  void visitListLiteralNode(ListLiteralNode node) {
    for (final element in node.elements) {
      element.accept(this);
    }
  }

  @override
  void visitMapLiteralNode(MapLiteralNode node) {
    for (final entry in node.entries) {
      entry.key.accept(this);
      entry.value.accept(this);
    }
  }
}
