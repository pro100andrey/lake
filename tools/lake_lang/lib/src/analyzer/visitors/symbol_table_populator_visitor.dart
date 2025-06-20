import '../../ast/ast_visitor.dart';
import '../../ast/nodes/ast_nodes.dart';
import '../diagnostics/diagnostic_system.dart';
import '../diagnostics/diagnostics.dart';
import '../semantic_types.dart';
import '../symbol_table/compilation_symbol_table.dart';
import '../symbol_table/symbol_entry.dart';
import '../symbol_table/symbol_table_builder.dart';
import 'type_resolver_visitor.dart';

class SymbolTablePopulatorVisitor extends AstVisitor<void> {
  SymbolTablePopulatorVisitor({
    required CompilationSymbolTable compilationSymbolTable,
    required SymbolTableBuilder symbolTableBuilder,
    required DiagnosticSystem diagnosticSystem,
  }) : _compilationSymbolTable = compilationSymbolTable,
       _symbolTableBuilder = symbolTableBuilder,
       _diagnosticSystem = diagnosticSystem,
       _typeResolver = TypeResolverVisitor(
         compilationSymbolTable: compilationSymbolTable,
         symbolTableBuilder: symbolTableBuilder,
         diagnosticSystem: diagnosticSystem,
         currentFilePath: symbolTableBuilder.filePath,
       );

  // ignore: unused_field
  final CompilationSymbolTable _compilationSymbolTable;
  final SymbolTableBuilder _symbolTableBuilder;
  final DiagnosticSystem _diagnosticSystem;
  final TypeResolverVisitor _typeResolver;

  @override
  void visitDocumentNode(DocumentNode node) {
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

    if (symbol == null && symbol is! ConstSymbolEntry) {
      _diagnosticSystem.report(
        GenericDiagnostic(
          message:
              "Internal error: Constant '${node.identifier.value}' "
              'not found or is wrong type in symbol table during population.',
          span: node.span,
          filePath: _symbolTableBuilder.filePath,
        ),
      );
    }

    final constSymbol = symbol!.cast<ConstSymbolEntry>();
    if (constSymbol.resolvedType != const SemanticUnresolvedType()) {
      throw StateError(
        'Expected unresolved type for constant symbol "${constSymbol.name}" '
        'before resolution, but found ${constSymbol.resolvedType}.',
      );
    }

    final resolvedConstantType = node.type.accept(_typeResolver);
    final updatedSymbol = symbol.cast<ConstSymbolEntry>().copyWith(
      resolvedType: resolvedConstantType,
      declaration: node,
    );

    _symbolTableBuilder.updateSymbol(updatedSymbol);
  }

  @override
  void visitTypedefDefinitionNode(TypedefDefinitionNode node) {
    final symbol = _symbolTableBuilder.lookupGlobal(node.identifier.value);

    if (symbol == null || symbol is! TypedefSymbolEntry) {
      _diagnosticSystem.report(
        GenericDiagnostic(
          message:
              "Internal error: Typedef '${node.identifier.value}' not found "
              'or is of wrong type in symbol table during population.',
          span: node.span,
          filePath: _symbolTableBuilder.filePath,
        ),
      );
      return;
    }

    final typedefSymbol = symbol.cast<TypedefSymbolEntry>();
    if (typedefSymbol.resolvedType != const SemanticUnresolvedType()) {
      throw StateError(
        'Expected unresolved type for typedef symbol "${typedefSymbol.name}" '
        'before resolution, but found ${typedefSymbol.resolvedType}.',
      );
    }

    final resolvedUnderlyingType = node.type.accept(_typeResolver);
    final updatedTypedefSymbol = typedefSymbol.copyWith(
      resolvedType: TypedefType(node, resolvedUnderlyingType),
      declaration: node,
    );

    _symbolTableBuilder.updateSymbol(updatedTypedefSymbol);
  }

  @override
  void visitEnumDefinitionNode(EnumDefinitionNode node) {
    final enumSymbol = _symbolTableBuilder.lookupGlobal(node.identifier.value);
    if (enumSymbol == null || enumSymbol is! EnumSymbolEntry) {
      _diagnosticSystem.report(
        GenericDiagnostic(
          message:
              "Internal error: Enum '${node.identifier.value}' not found "
              'or is of wrong type in symbol table during population.',
          span: node.span,
          filePath: _symbolTableBuilder.filePath,
        ),
      );
      return;
    }

    // Push scope for enum members
    _symbolTableBuilder.pushScope(ownerSymbol: enumSymbol);

    // No need to create SemanticEnumType here, as it was done in the first
    // pass. We just need to update it with fully resolved details if any.
    // For now, EnumType simply wraps the AST node.

    for (final member in node.members) {
      member.accept(this); // Visit members to ensure they are processed
    }

    _symbolTableBuilder.popScope();
  }

  @override
  void visitEnumMemberNode(EnumMemberNode node) {
    // Enum members are already added as SymbolEntry in the first pass.
    // No additional resolution needed unless they had associated types/values,
    // which is not defined in Lake's IDL for now.
    // We might need to update their resolvedType to be the parent enum's type.
    final memberSymbol = _symbolTableBuilder.lookupLocal(node.identifier.value);

    if (memberSymbol == null || memberSymbol is! EnumMemberSymbolEntry) {
      _diagnosticSystem.report(
        GenericDiagnostic(
          message:
              "Internal error: Enum member '${node.identifier.value}' not "
              'found or is of wrong type in symbol table during population.',
          span: node.span,
          filePath: _symbolTableBuilder.filePath,
        ),
      );

      return;
    }

    final parentEnumScope = _symbolTableBuilder.fileGlobalScope.parent;

    if (parentEnumScope != null &&
        parentEnumScope.ownerSymbol is EnumSymbolEntry) {
      return;
    }
  }

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
