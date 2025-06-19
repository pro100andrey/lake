import '../../ast/ast_visitor.dart';
import '../../ast/nodes/ast_nodes.dart';
import '../errors/error_reporter.dart';
import '../symbol_table/symbol_entry.dart';
import '../symbol_table/symbol_table_builder.dart';

/// The first pass AST visitor for semantic analysis.
///
/// This visitor's primary responsibility is to collect all top-level symbol
/// declarations and import statements within a single compilation unit (file).
/// It populates the [SymbolTableBuilder] with initial, un-resolved symbol
/// entries. Type resolution and detailed member collection are deferred to the
/// SymbolTablePopulatorVisitor (second pass).
class InitialSymbolCollectorVisitor extends AstVisitor<void> {
  const InitialSymbolCollectorVisitor({
    required SymbolTableBuilder symbolTableBuilder,
    required ErrorReporter reporter,
  }) : _symbolTableBuilder = symbolTableBuilder,
       _reporter = reporter;

  final SymbolTableBuilder _symbolTableBuilder;
  final ErrorReporter _reporter;

  @override
  void visitDocumentNode(DocumentNode node) {
    // Process headers (imports) first, as they declare dependencies.
    for (final header in node.headers) {
      header.accept(this);
    }
    // Then process top-level definitions.
    for (final definition in node.definitions) {
      definition.accept(this);
    }
  }

  @override
  void visitImportNode(ImportNode node) {
    _symbolTableBuilder.registerImport(node.path.value);
  }

  @override
  void visitNamespaceNode(NamespaceNode node) {}

  @override
  void visitConstDefinitionNode(ConstDefinitionNode node) {
    final symbol = ConstSymbolEntry(
      name: node.identifier.value,
      declaration: node,
      span: node.span,
    );

    _symbolTableBuilder.addSymbol(symbol);
  }

  @override
  void visitTypedefDefinitionNode(TypedefDefinitionNode node) {
    final symbol = TypedefSymbolEntry(
      name: node.identifier.value,
      declaration: node,
      span: node.span,
    );

    _symbolTableBuilder.addSymbol(symbol);
  }

  @override
  void visitEnumDefinitionNode(EnumDefinitionNode node) {
    final symbol = EnumSymbolEntry(
      name: node.identifier.value,
      declaration: node,
      span: node.span,
    );

    _symbolTableBuilder
      ..addSymbol(symbol)
      // Enter a new scope for enum members.
      // Members are immediately added to this scope as they are declarations.
      ..pushScope(ownerSymbol: symbol);

    for (final member in node.members) {
      member.accept(this); // Visit members to add them to the enum's scope
    }

    _symbolTableBuilder.popScope();
  }

  @override
  void visitEnumMemberNode(EnumMemberNode node) {
    final symbol = EnumMemberSymbolEntry(
      name: node.identifier.value,
      declaration: node,
      span: node.span,
    );

    _symbolTableBuilder.addSymbol(symbol);
  }

  @override
  void visitStructDefinitionNode(StructDefinitionNode node) {
    final symbol = StructSymbolEntry(
      name: node.identifier.value,
      declaration: node,
      span: node.span,
    );

    _symbolTableBuilder
      ..addSymbol(symbol)
      // Enter a new scope for struct fields.
      // We traverse fields to handle any potential nested declarations
      // (though unlikely for Lake IDL fields). FieldSymbolEntry creation
      // and type resolution will happen in the second pass.
      ..pushScope(ownerSymbol: symbol);

    for (final field in node.fields) {
      field.accept(this); // Visit fields to add them to the struct's scope
    }

    _symbolTableBuilder.popScope();
  }

  @override
  void visitUnionDefinitionNode(UnionDefinitionNode node) {
    final symbol = UnionSymbolEntry(
      name: node.identifier.value,
      declaration: node,
      span: node.span,
    );

    _symbolTableBuilder
      ..addSymbol(symbol)
      // Enter a new scope for union fields.
      // Fields are immediately added to this scope as they are declarations.
      ..pushScope(ownerSymbol: symbol);

    for (final field in node.fields) {
      field.accept(this); // Visit fields to add them to the union's scope
    }

    _symbolTableBuilder.popScope();
  }

  @override
  void visitExceptionDefinitionNode(ExceptionDefinitionNode node) {
    final symbol = ExceptionSymbolEntry(
      name: node.identifier.value,
      declaration: node,
      span: node.span,
    );

    _symbolTableBuilder
      ..addSymbol(symbol)
      // Enter a new scope for exception fields.
      // Fields are immediately added to this scope as they are declarations.
      ..pushScope(ownerSymbol: symbol);

    for (final field in node.fields) {
      field.accept(this); // Visit fields to add them to the exception's scope
    }

    _symbolTableBuilder.popScope();
  }

  @override
  void visitServiceDefinitionNode(ServiceDefinitionNode node) {
    final symbol = ServiceSymbolEntry(
      name: node.identifier.value,
      declaration: node,
      span: node.span,
    );

    _symbolTableBuilder
      ..addSymbol(symbol)
      // Enter a new scope for service methods.
      // Methods are immediately added to this scope as they are declarations.
      ..pushScope(ownerSymbol: symbol);

    for (final method in node.methods) {
      method.accept(this); // Visit methods to add them to the service's scope
    }

    _symbolTableBuilder.popScope();
  }

  @override
  void visitFieldRequirementNode(FieldRequirementNode node) {
    // This node itself doesn't declare a new symbol, it's part of a FieldNode.
    // Its presence (e.g., 'optional' or 'required') is semantically relevant
    // to the FieldSymbolEntry, which will be created in the 2nd pass.
  }

  @override
  void visitFieldNode(FieldNode node) {
    final symbol = FieldSymbolEntry(
      name: node.identifier.value,
      declaration: node,
      span: node.span,
    );

    _symbolTableBuilder.addSymbol(symbol);
  }

  @override
  void visitMethodNode(MethodNode node) {
    final symbol = MethodSymbolEntry(
      name: node.identifier.value,
      declaration: node,
      span: node.span,
    );

    _symbolTableBuilder
      ..addSymbol(symbol)
      ..pushScope(ownerSymbol: symbol);

    for (final param in node.parameters) {
      // These are FieldNodes, will create ParameterSymbolEntry (see below)
      param.accept(this);
    }

    for (final thr in node.throws) {
      // These are TypeNodes, will create TypeSymbolEntry (see below)
      thr.accept(this);
    }

    _symbolTableBuilder.popScope();
  }

  @override
  void visitBaseTypeNode(BaseTypeNode node) {
    // Base types (int, string, bool, double) are built-in and don't declare
    // new symbols.
  }

  @override
  void visitMapTypeNode(MapTypeNode node) {
    // Complex types that wrap other types. Traverse their inner types.
    node.keyType.accept(this);
    node.valueType.accept(this);
  }

  @override
  void visitSetTypeNode(SetTypeNode node) {
    // Complex types that wrap other types. Traverse their inner types.
    node.elementType.accept(this);
  }

  @override
  void visitListTypeNode(ListTypeNode node) {
    // Complex types that wrap other types. Traverse their inner types.
    node.elementType.accept(this);
  }

  @override
  void visitStreamTypeNode(StreamTypeNode node) {
    // Complex types that wrap other types. Traverse their inner types.
    node.elementType.accept(this);
  }

  @override
  void visitCustomTypeNode(CustomTypeNode node) {
    // Custom types like 'MyStruct' or 'com.example.MyService'.
    // These refer to symbols that should already be in the symbol table,
    // but their resolution happens in the 2nd pass.
  }

  @override
  void visitVoidTypeNode(VoidTypeNode node) {
    // 'void' is a special type and doesn't declare a new symbol.
  }

  @override
  void visitIntLiteralNode(IntLiteralNode node) {
    // Literal nodes do not declare symbols, they are values.
  }

  @override
  void visitDoubleLiteralNode(DoubleLiteralNode node) {
    // Literal nodes do not declare symbols, they are values.
  }

  @override
  void visitBoolLiteralNode(BoolLiteralNode node) {
    // Literal nodes do not declare symbols, they are values.
  }

  @override
  void visitStringLiteralNode(StringLiteralNode node) {
    // Literal nodes do not declare symbols, they are values.
  }

  @override
  void visitIdentifierNode(IdentifierNode node) {
    // Identifiers themselves are references, not declarations of new symbols.
    // They are handled as part of their parent declaration
    // (e.g., ConstDefinitionNode.identifier).
  }

  @override
  void visitListLiteralNode(ListLiteralNode node) {
    for (final element in node.elements) {
      element.accept(this);
    }
  }

  @override
  void visitMapLiteralNode(MapLiteralNode node) {
    // Traverse key-value pairs within the map literal.
    for (final entry in node.entries) {
      entry.key.accept(this);
      entry.value.accept(this);
    }
  }
}
