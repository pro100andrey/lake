import 'package:source_span/source_span.dart';

import '../ast_visitor.dart';
import '../nodes/ast_nodes.dart';

/// An AST visitor that pretty-prints the Lake AST.
class AstPrettyPrinterVisitor implements AstVisitor<void> {
  AstPrettyPrinterVisitor(SourceFile sourceFile)
    : _sourceFile = sourceFile,
      _outputBuffer = StringBuffer(),
      _isLastNodeStack = [];

  final SourceFile _sourceFile;
  final List<bool> _isLastNodeStack;
  final StringBuffer _outputBuffer;

  String get output {
    final result = _outputBuffer.toString();
    _outputBuffer.clear();
    return result;
  }

  String get _indent {
    final level = _isLastNodeStack.length;

    final result = List.generate(level, (i) {
      final isLast = _isLastNodeStack[i];

      if (i == level - 1) {
        return isLast ? '└── ' : '├── ';
      } else {
        return isLast ? '    ' : '│   ';
      }
    });

    return result.join();
  }

  void _withNodeContext(bool isLast, void Function() body) {
    _isLastNodeStack.add(isLast);
    try {
      body();
    } finally {
      _isLastNodeStack.removeLast();
    }
  }

  void _writeResult(String message) {
    _outputBuffer.writeln('$_indent$message');
  }

  void _printNode(
    AstNode node, [
    Map<String, dynamic>? props,
  ]) {
    final nodeName = node.runtimeType;
    final propsStr = props?.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');

    final span = _sourceFile.span(node.span.start, node.span.end);
    final location = ' [${span.start.line + 1}:${span.start.column + 1}]';

    _writeResult('$nodeName${propsStr != null ? '($propsStr)' : ''}$location');
  }

  void _visit<T extends AstNode>(T? node, {bool isLast = false}) {
    if (node == null) {
      _writeResult('<null>');
      return;
    }

    _withNodeContext(isLast, () => node.accept(this));
  }

  void _visitList<T extends AstNode>(
    String listName,
    List<T> nodes, {
    bool isLast = false,
  }) {
    _withNodeContext(isLast, () => _visitNodeList(nodes, listName));
  }

  void _visitChildren(List<AstNode> children) {
    for (var i = 0; i < children.length; i++) {
      _visit(children[i], isLast: i == children.length - 1);
    }
  }

  void _visitNodeList<T extends AstNode>(List<T> nodes, String listName) {
    if (nodes.isEmpty) {
      _writeResult('$listName: []');
      return;
    }

    _writeResult('$listName:');

    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final isLast = (i == nodes.length - 1);
      _withNodeContext(isLast, () {
        node.accept(this);
      });
    }
  }

  /// Visits the root node of the AST.
  @override
  void visitDocumentNode(DocumentNode node) {
    _withNodeContext(true, () {
      _printNode(node);
      _visitList('Headers', node.headers);
      _visitList('Definitions', node.definitions, isLast: true);
    });
  }

  @override
  void visitImportNode(ImportNode node) {
    _printNode(node);

    _visit(node.path, isLast: true);
  }

  @override
  void visitNamespaceNode(NamespaceNode node) {
    _printNode(node);
    _visit(node.scope);
    _visit(node.identifier, isLast: true);
  }

  @override
  void visitConstDefinitionNode(ConstDefinitionNode node) {
    _printNode(node);
    _visitChildren([node.type, node.identifier, node.value]);
  }

  @override
  void visitTypedefDefinitionNode(TypedefDefinitionNode node) {
    _printNode(node);
    _visit(node.type);
    _visit(node.identifier, isLast: true);
  }

  @override
  void visitEnumDefinitionNode(EnumDefinitionNode node) {
    _printNode(node);
    _visit(node.identifier);
    _visitList('Members', node.members, isLast: true);
  }

  @override
  void visitEnumValueNode(EnumValueNode node) {
    _printNode(node);
    _visit(node.identifier, isLast: node.value == null);
    _visit(node.value, isLast: true);
  }

  @override
  void visitStructDefinitionNode(StructDefinitionNode node) {
    _printNode(node);
    _visit(node.identifier);
    _visitList('Fields', node.fields, isLast: true);
  }

  @override
  void visitUnionDefinitionNode(UnionDefinitionNode node) {
    _printNode(node);
    _visit(node.identifier);
    _visitList('Fields', node.fields, isLast: true);
  }

  @override
  void visitExceptionDefinitionNode(ExceptionDefinitionNode node) {
    _printNode(node);
    _visit(node.identifier);
    _visitList('Fields', node.fields, isLast: true);
  }

  @override
  void visitServiceDefinitionNode(ServiceDefinitionNode node) {
    _printNode(node);

    final hasExtends = node.extendsService != null;
    final hasMethods = node.methods.isNotEmpty;

    _visit(node.identifier, isLast: !hasExtends && !hasMethods);

    if (hasExtends) {
      _visit(node.extendsService, isLast: !hasMethods);
    }

    if (hasMethods) {
      _visitList('Methods', node.methods, isLast: true);
    }
  }

  @override
  void visitFieldRequirementNode(FieldRequirementNode node) {
    _printNode(node, {'value': node.value});
  }

  @override
  void visitFieldNode(FieldNode node) {
    _printNode(node);

    _visitChildren([
      ?node.fieldId,
      ?node.requirement,
      node.type,
      node.identifier,
      ?node.defaultValue,
    ]);
  }

  @override
  void visitMethodNode(MethodNode node) {
    _printNode(node);

    final hasParameters = node.parameters.isNotEmpty;
    final hasThrows = node.throws.isNotEmpty;

    _visit(node.returnType);
    _visit(node.identifier, isLast: !hasParameters && !hasThrows);

    if (hasParameters) {
      _visitList('Parameters', node.parameters, isLast: !hasThrows);

      if (hasThrows) {
        _visitList('Throws', node.throws, isLast: true);
      }
    }
  }

  // Type nodes

  @override
  void visitBaseTypeNode(BaseTypeNode node) {
    _printNode(node, {'value': node.value});
  }

  @override
  void visitMapTypeNode(MapTypeNode node) {
    _printNode(node);

    _visit(node.keyType);
    _visit(node.valueType, isLast: true);
  }

  @override
  void visitSetTypeNode(SetTypeNode node) {
    _printNode(node);
    _visit(node.elementType, isLast: true);
  }

  @override
  void visitListTypeNode(ListTypeNode node) {
    _printNode(node);
    _visit(node.elementType, isLast: true);
  }

  @override
  void visitStreamTypeNode(StreamTypeNode node) {
    _printNode(node);
    _visit(node.elementType, isLast: true);
  }

  @override
  void visitCustomTypeNode(CustomTypeNode node) {
    _printNode(node, {'value': node.value});
  }

  @override
  void visitVoidTypeNode(VoidTypeNode node) {
    _printNode(node);
  }

  // Literal value nodes

  @override
  void visitIntLiteralNode(IntLiteralNode node) {
    _printNode(node, {'value': node.value, 'rawValue': node.rawValue});
  }

  @override
  void visitDoubleLiteralNode(DoubleLiteralNode node) {
    _printNode(node, {'value': node.value, 'rawValue': node.rawValue});
  }

  @override
  void visitBoolLiteralNode(BoolLiteralNode node) {
    _printNode(node, {'value': node.value, 'rawValue': node.rawValue});
  }

  @override
  void visitStringLiteralNode(StringLiteralNode node) {
    _printNode(node, {'value': node.value, 'rawValue': node.rawValue});
  }

  @override
  void visitIdentifierNode(IdentifierNode node) {
    _printNode(node, {'value': node.value});
  }

  @override
  void visitListLiteralNode(ListLiteralNode node) {
    _printNode(node);
    _visitList('Elements', node.elements, isLast: true);
  }

  @override
  void visitMapLiteralNode(MapLiteralNode node) {
    _printNode(node);

    if (node.entries.isEmpty) {
      _writeResult('Entries: []');
      return;
    }

    _withNodeContext(true, () {
      _writeResult('Entries:');

      for (var i = 0; i < node.entries.length; i++) {
        final entry = node.entries[i];
        final isLast = (i == node.entries.length - 1);

        _withNodeContext(isLast, () {
          _writeResult('Entry:');

          _visit(entry.key);
          _visit(entry.value, isLast: true);
        });
      }
    });
  }
}
