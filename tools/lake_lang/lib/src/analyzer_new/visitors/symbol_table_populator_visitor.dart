import '../../analyzer/errors/error_reporter.dart';
import '../../ast/ast_visitor.dart';
import '../../ast/nodes/ast_nodes.dart';
import '../symbol_table/compilation_symbol_table.dart';
import '../symbol_table/symbol_table_builder.dart';

class SymbolTablePopulatorVisitor extends AstVisitor<void> {
  SymbolTablePopulatorVisitor({
    required CompilationSymbolTable compilationSymbolTable,
    required SymbolTableBuilder symbolTableBuilder,
    required ErrorReporter reporter,
  }) : _compilationSymbolTable = compilationSymbolTable,
       _symbolTableBuilder = symbolTableBuilder,
       _reporter = reporter;

  final CompilationSymbolTable _compilationSymbolTable;
  final SymbolTableBuilder _symbolTableBuilder;
  final ErrorReporter _reporter;

  @override
  void visitDocumentNode(DocumentNode node) {
    _compilationSymbolTable.setCurrentProcessingFile(
      _symbolTableBuilder.fileGlobalScope.ownerSymbol?.name ?? 'UnknownFile',
    ); // Needs actual file path or name.
    // Then process top-level definitions.
    for (final definition in node.definitions) {
      definition.accept(this);
    }
  }

  @override
  void visitImportNode(ImportNode node) {
    // Already handled in the InitialSymbolCollectorVisitor.
  }

  @override
  void visitNamespaceNode(NamespaceNode node) {}

  @override
  void visitConstDefinitionNode(ConstDefinitionNode node) {
    // Find the ConstSymbolEntry created in the first pass.
    final symbol = _symbolTableBuilder.lookupGlobal(node.identifier.value);

    if (symbol == null) {
      _reporter.reportGeneric(
        message:
            "Internal error: Constant '${node.identifier.value}' "
            'not found or is wrong type in symbol table during population.',
        span: node.span,
        filePath: _symbolTableBuilder.filePath,
      );
    }
  }

  @override
  void visitTypedefDefinitionNode(TypedefDefinitionNode node) {}

  @override
  void visitEnumDefinitionNode(EnumDefinitionNode node) {}

  @override
  void visitEnumMemberNode(EnumMemberNode node) {}

  @override
  void visitStructDefinitionNode(StructDefinitionNode node) {}

  @override
  void visitUnionDefinitionNode(UnionDefinitionNode node) {}

  @override
  void visitExceptionDefinitionNode(ExceptionDefinitionNode node) {}

  @override
  void visitServiceDefinitionNode(ServiceDefinitionNode node) {}

  @override
  void visitFieldRequirementNode(FieldRequirementNode node) {}

  @override
  void visitFieldNode(FieldNode node) {}

  @override
  void visitMethodNode(MethodNode node) {}

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
  void visitCustomTypeNode(CustomTypeNode node) {}

  @override
  void visitVoidTypeNode(VoidTypeNode node) {}

  @override
  void visitIntLiteralNode(IntLiteralNode node) {}

  @override
  void visitDoubleLiteralNode(DoubleLiteralNode node) {}

  @override
  void visitBoolLiteralNode(BoolLiteralNode node) {}

  @override
  void visitStringLiteralNode(StringLiteralNode node) {}

  @override
  void visitIdentifierNode(IdentifierNode node) {}

  @override
  void visitListLiteralNode(ListLiteralNode node) {}

  @override
  void visitMapLiteralNode(MapLiteralNode node) {}
}
