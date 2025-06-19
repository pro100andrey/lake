import '../../analyzer/errors/error_reporter.dart';
import '../../analyzer/semantic_types.dart';
import '../../ast/ast_visitor.dart';
import '../../ast/nodes/ast_nodes.dart';
import '../symbol_table/compilation_symbol_table.dart';
import '../symbol_table/symbol_table_builder.dart';

/// A helper visitor specifically for resolving AST TypeNodes into
/// SemanticTypes. This visitor returns a SemanticType.
class TypeResolverVisitor extends AstVisitor<SemanticType> {
  const TypeResolverVisitor({
    required this.compilationSymbolTable,
    required this.symbolTableBuilder,
    required this.reporter,
    required this.currentFilePath,
  });

  final CompilationSymbolTable compilationSymbolTable;
  final SymbolTableBuilder symbolTableBuilder;
  final ErrorReporter reporter;
  final String currentFilePath;

  @override
  SemanticType visitBaseTypeNode(BaseTypeNode node) =>
      BaseType.byName[node.value]!;

  @override
  SemanticType visitBoolLiteralNode(BoolLiteralNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitConstDefinitionNode(ConstDefinitionNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitCustomTypeNode(CustomTypeNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitDocumentNode(DocumentNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitDoubleLiteralNode(DoubleLiteralNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitEnumDefinitionNode(EnumDefinitionNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitEnumMemberNode(EnumMemberNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitExceptionDefinitionNode(ExceptionDefinitionNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitFieldNode(FieldNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitFieldRequirementNode(FieldRequirementNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitIdentifierNode(IdentifierNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitImportNode(ImportNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitIntLiteralNode(IntLiteralNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitListLiteralNode(ListLiteralNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitListTypeNode(ListTypeNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitMapLiteralNode(MapLiteralNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitMapTypeNode(MapTypeNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitMethodNode(MethodNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitNamespaceNode(NamespaceNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitServiceDefinitionNode(ServiceDefinitionNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitSetTypeNode(SetTypeNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitStreamTypeNode(StreamTypeNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitStringLiteralNode(StringLiteralNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitStructDefinitionNode(StructDefinitionNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitTypedefDefinitionNode(TypedefDefinitionNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitUnionDefinitionNode(UnionDefinitionNode node) {
    throw UnimplementedError();
  }

  @override
  SemanticType visitVoidTypeNode(VoidTypeNode node) {
    throw UnimplementedError();
  }
}
