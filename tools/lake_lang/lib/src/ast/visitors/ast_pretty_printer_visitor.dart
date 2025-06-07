// ignore_for_file: avoid_print

import '../ast_visitor.dart';
import '../nodes/ast_nodes.dart';

/// An AST visitor that pretty-prints the Lake AST.
class AstPrettyPrinterVisitor implements AstVisitor<void> {
  final List<bool> _isLastNodeStack = [];

  String get _indent {
    final buffer = StringBuffer();

    final level = _isLastNodeStack.length;

    for (var i = 0; i < level - 1; i++) {
      buffer.write(_isLastNodeStack[i] ? '    ' : '│   ');
    }

    if (level > 0) {
      buffer.write(_isLastNodeStack.last ? '└── ' : '├── ');
    }

    return buffer.toString();
  }

  void _withNodeContext(bool isLast, void Function() body) {
    _isLastNodeStack.add(isLast);
    try {
      body();
    } finally {
      _isLastNodeStack.removeLast();
    }
  }

  void _printNode(
    AstNode node, [
    Map<String, dynamic>? properties,
  ]) {
    final nodeName = node.runtimeType.toString();
    final propsString = properties != null && properties.isNotEmpty
        ? '(${properties.entries.map(
            (e) => '${e.key}: ${e.value}', //
          ).join(', ')})'
        : '';

    var location = '';
    final start = node.span.start;

    location = ' [${start.line + 1}:${start.column + 1}]';

    print('$_indent$nodeName$propsString$location');
  }

  void _visitNodeList<T extends AstNode>(List<T> nodes, String listName) {
    if (nodes.isEmpty) {
      print('$_indent$listName: []');
      return;
    }

    print('$_indent$listName:');

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
      _withNodeContext(false, () => _visitNodeList(node.headers, 'Headers'));
      _withNodeContext(
        true,
        () => _visitNodeList(node.definitions, 'Definitions'),
      );
    });
  }

  @override
  void visitImportNode(ImportNode node) {
    _printNode(node);
    _withNodeContext(true, () => node.path.accept(this));
  }

  @override
  void visitNamespaceNode(NamespaceNode node) {
    _printNode(node);
    _withNodeContext(false, () => node.scope.accept(this));
    _withNodeContext(true, () => node.identifier.accept(this));
  }

  @override
  void visitConstDefinitionNode(ConstDefinitionNode node) {
    _printNode(node);
    final children = [node.type, node.identifier, node.value];
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      final isLast = (i == children.length - 1);
      _withNodeContext(isLast, () => child.accept(this));
    }
  }

  @override
  void visitTypedefDefinitionNode(TypedefDefinitionNode node) {
    _printNode(node);
    _withNodeContext(false, () => node.type.accept(this));
    _withNodeContext(true, () => node.identifier.accept(this));
  }

  @override
  void visitEnumDefinitionNode(EnumDefinitionNode node) {
    _printNode(node);
    _withNodeContext(false, () => node.identifier.accept(this));
    _withNodeContext(true, () => _visitNodeList(node.values, 'Values'));
  }

  @override
  void visitEnumValueNode(EnumValueNode node) {
    _printNode(node);
    _withNodeContext(node.value == null, () => node.identifier.accept(this));
    if (node.value != null) {
      _withNodeContext(true, () => node.value!.accept(this));
    }
  }

  @override
  void visitStructDefinitionNode(StructDefinitionNode node) {
    _printNode(node);
    _withNodeContext(false, () => node.identifier.accept(this));
    _withNodeContext(true, () => _visitNodeList(node.fields, 'Fields'));
  }

  @override
  void visitExceptionDefinitionNode(ExceptionDefinitionNode node) {
    _printNode(node);
    _withNodeContext(false, () => node.identifier.accept(this));
    _withNodeContext(true, () => _visitNodeList(node.fields, 'Fields'));
  }

  @override
  void visitServiceDefinitionNode(ServiceDefinitionNode node) {
    _printNode(node);

    final hasExtends = node.extendsService != null;
    final hasFunctions = node.functions.isNotEmpty;

    _withNodeContext(
      !hasExtends && !hasFunctions,
      () => node.identifier.accept(this),
    );

    if (hasExtends) {
      _withNodeContext(!hasFunctions, () => node.extendsService!.accept(this));
    }

    if (hasFunctions) {
      _withNodeContext(true, () => _visitNodeList(node.functions, 'Functions'));
    }
  }

  @override
  void visitFieldRequirementNode(FieldRequirementNode node) {
    _printNode(node, {'value': node.value});
  }

  @override
  void visitFieldNode(FieldNode node) {
    _printNode(node);

    final children = [
      ?node.fieldId,
      ?node.requirement,
      node.type,
      node.identifier,
      ?node.defaultValue,
    ].toList(growable: false);

    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      final isLast = (i == children.length - 1);
      _withNodeContext(isLast, () => child.accept(this));
    }
  }

  @override
  void visitFunctionNode(FunctionNode node) {
    _printNode(node);

    final hasParameters = node.parameters.isNotEmpty;
    final hasThrows = node.throws.isNotEmpty;

    _withNodeContext(false, () => node.returnType.accept(this));
    _withNodeContext(
      !hasParameters && !hasThrows,
      () => node.identifier.accept(this),
    );

    if (hasParameters) {
      _withNodeContext(
        !hasThrows,
        () => _visitNodeList(node.parameters, 'Parameters'),
      );

      if (hasThrows) {
        _withNodeContext(true, () => _visitNodeList(node.throws, 'Throws'));
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
    _withNodeContext(false, () => node.keyType.accept(this));
    _withNodeContext(true, () => node.valueType.accept(this));
  }

  @override
  void visitSetTypeNode(SetTypeNode node) {
    _printNode(node);
    _withNodeContext(true, () => node.elementType.accept(this));
  }

  @override
  void visitListTypeNode(ListTypeNode node) {
    _printNode(node);
    _withNodeContext(true, () => node.elementType.accept(this));
  }

  @override
  void visitStreamTypeNode(StreamTypeNode node) {
    _printNode(node);
    _withNodeContext(true, () => node.type.accept(this));
  }

  @override
  void visitCustomTypeNode(CustomTypeNode node) {
    _printNode(node, {'value': node.value});
  }

  @override
  void visitVoidTypeNode(VoidTypeNode node) {
    _printNode(node);
  }

  // Constant value nodes

  @override
  void visitIntConstantNode(IntConstantNode node) {
    _printNode(node, {'value': node.value});
  }

  @override
  void visitDoubleConstantNode(DoubleConstantNode node) {
    _printNode(node, {'value': node.value});
  }

  @override
  void visitLiteralNode(LiteralNode node) {
    _printNode(node, {'value': node.value});
  }

  @override
  void visitIdentifierNode(IdentifierNode node) {
    _printNode(node, {'value': node.value});
  }

  @override
  void visitConstListNode(ConstListNode node) {
    _printNode(node);
    _withNodeContext(true, () => _visitNodeList(node.elements, 'Elements'));
  }

  @override
  void visitConstMapNode(ConstMapNode node) {
    _printNode(node);

    if (node.entries.isEmpty) {
      print('${_indent}Entries: []');
      return;
    }

    _withNodeContext(true, () {
      print('${_indent}Entries:');

      for (var i = 0; i < node.entries.length; i++) {
        final entry = node.entries[i];
        final isLast = (i == node.entries.length - 1);

        _withNodeContext(isLast, () {
          print('${_indent}Entry($i):');

          _withNodeContext(false, () => entry.key.accept(this));
          _withNodeContext(true, () => entry.value.accept(this));
        });
      }
    });
  }
}
