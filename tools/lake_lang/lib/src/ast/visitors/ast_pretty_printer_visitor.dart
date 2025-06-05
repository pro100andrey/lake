// ignore_for_file: avoid_print

import '../ast_visitor.dart';
import '../nodes/ast_nodes.dart';

/// An AST visitor that pretty-prints the Lake AST.
class AstPrettyPrinterVisitor implements AstVisitor<void> {
  int _indentationLevel = 0;
  String get _indent => '  ' * _indentationLevel;

  void _withIndentation(void Function() body) {
    _indentationLevel++;
    try {
      body();
    } finally {
      _indentationLevel--;
    }
  }

  void _printNode(String nodeName, [Map<String, dynamic>? properties]) {
    final propsString = properties != null && properties.isNotEmpty
        ? '(${properties.entries.map(
            (e) => '${e.key}: ${e.value}', //
          ).join(', ')})'
        : '';

    print('$_indent$nodeName$propsString');
  }

  void _visitNodeList<T extends AstNode>(List<T> nodes, String listName) {
    if (nodes.isEmpty) {
      _printNode('$listName: []');
      return;
    }
    _printNode('$listName:');
    _withIndentation(() {
      for (final node in nodes) {
        node.accept(this);
      }
    });
  }

  /// Visits the root node of the AST.
  @override
  void visitDocumentNode(DocumentNode node) {
    _printNode('DocumentNode');
    _withIndentation(() {
      _visitNodeList(node.headers, 'Headers');
      _visitNodeList(node.definitions, 'Definitions');
    });
  }

  @override
  void visitImportNode(ImportNode node) {
    _printNode('ImportNode', {'path': node.path});
  }

  @override
  void visitNamespaceNode(NamespaceNode node) {
    _printNode('NamespaceNode', {'scope': node.scope, 'name': node.name.value});
  }

  @override
  void visitConstDefinitionNode(ConstDefinitionNode node) {
    _printNode('ConstDefinitionNode');
    _withIndentation(() {
      _printNode('Type:');
      _withIndentation(() => node.type.accept(this));
      _printNode('Identifier:');
      _withIndentation(() => node.identifier.accept(this));
      _printNode('Value:');
      _withIndentation(() => node.value.accept(this));
    });
  }

  @override
  void visitTypedefDefinitionNode(TypedefDefinitionNode node) {
    _printNode('TypedefDefinitionNode');
    _withIndentation(() {
      _printNode('Type:');
      _withIndentation(() => node.type.accept(this));
      _printNode('Name:');
      _withIndentation(() => node.name.accept(this));
    });
  }

  @override
  void visitEnumDefinitionNode(EnumDefinitionNode node) {
    _printNode('EnumDefinitionNode');
    _withIndentation(() {
      _printNode('Name:');
      _withIndentation(() => node.name.accept(this));
      _visitNodeList(node.values, 'Values');
    });
  }

  @override
  void visitEnumValueNode(EnumValueNode node) {
    _printNode('EnumValueNode');
    _withIndentation(() {
      _printNode('MemberName:');
      _withIndentation(() => node.memberName.accept(this));
      if (node.value != null) {
        _printNode('Initializer:');
        _withIndentation(() => node.value!.accept(this));
      }
    });
  }

  @override
  void visitStructDefinitionNode(StructDefinitionNode node) {
    _printNode('StructDefinitionNode');
    _withIndentation(() {
      _printNode('Name:');
      _withIndentation(() => node.name.accept(this));
      _visitNodeList(node.fields, 'Fields');
    });
  }

  @override
  void visitExceptionDefinitionNode(ExceptionDefinitionNode node) {
    _printNode('ExceptionDefinitionNode');
    _withIndentation(() {
      _printNode('Name:');
      _withIndentation(() => node.name.accept(this));
      _visitNodeList(node.fields, 'Fields');
    });
  }

  @override
  void visitServiceDefinitionNode(ServiceDefinitionNode node) {
    _printNode('ServiceDefinitionNode');
    _withIndentation(() {
      _printNode('Name:');
      _withIndentation(() => node.name.accept(this));
      if (node.extendsService != null) {
        _printNode('Extends:');
        _withIndentation(() => node.extendsService!.accept(this));
      }
      _visitNodeList(node.functions, 'Functions');
    });
  }

  @override
  void visitFieldRequirementNode(FieldRequirementNode node) {
    _printNode('FieldRequirementNode', {'requirement': node.requirement});
  }

  @override
  void visitFieldNode(FieldNode node) {
    _printNode('FieldNode');
    _withIndentation(() {
      _printNode('ID:');
      _withIndentation(() => node.id.accept(this));
      if (node.requirement != null) {
        _printNode('Requirement:');
        _withIndentation(() => node.requirement!.accept(this));
      }
      _printNode('Type:');
      _withIndentation(() => node.type.accept(this));
      _printNode('Name:');
      _withIndentation(() => node.name.accept(this));
      if (node.defaultValue != null) {
        _printNode('DefaultValue:');
        _withIndentation(() => node.defaultValue!.accept(this));
      }
    });
  }

  @override
  void visitFunctionNode(FunctionNode node) {
    _printNode('FunctionNode');
    _withIndentation(() {
      _printNode('ReturnType:');
      _withIndentation(() => node.returnType.accept(this));
      _printNode('Name:');
      _withIndentation(() => node.name.accept(this));
      _visitNodeList(node.parameters, 'Parameters');
      if (node.throws.isNotEmpty) {
        _visitNodeList(node.throws, 'Throws');
      }
    });
  }

  // Type nodes

  @override
  void visitBaseTypeNode(BaseTypeNode node) {
    _printNode('BaseTypeNode', {'type': node.type});
  }

  @override
  void visitMapTypeNode(MapTypeNode node) {
    _printNode('MapTypeNode');
    _withIndentation(() {
      _printNode('KeyType:');
      _withIndentation(() => node.keyType.accept(this));
      _printNode('ValueType:');
      _withIndentation(() => node.valueType.accept(this));
    });
  }

  @override
  void visitSetTypeNode(SetTypeNode node) {
    _printNode('SetTypeNode');
    _withIndentation(() {
      _printNode('ItemType:');
      _withIndentation(() => node.itemType.accept(this));
    });
  }

  @override
  void visitListTypeNode(ListTypeNode node) {
    _printNode('ListTypeNode');
    _withIndentation(() {
      _printNode('elementType:');
      _withIndentation(() => node.elementType.accept(this));
    });
  }

  @override
  void visitStreamTypeNode(StreamTypeNode node) {
    _printNode('StreamTypeNode');
    _withIndentation(() {
      _printNode('type:');
      _withIndentation(() => node.type.accept(this));
    });
  }

  @override
  void visitCustomTypeNode(CustomTypeNode node) {
    _printNode('CustomTypeNode');
    _withIndentation(() {
      _printNode('Type:');
      _withIndentation(() => node.type.accept(this));
    });
  }

  @override
  void visitVoidTypeNode(VoidTypeNode node) {
    _printNode('VoidTypeNode');
  }

  // Constant value nodes

  @override
  void visitIntConstantNode(IntConstantNode node) {
    _printNode('IntConstantNode', {'value': node.value});
  }

  @override
  void visitDoubleConstantNode(DoubleConstantNode node) {
    _printNode('DoubleConstantNode', {'value': node.value});
  }

  @override
  void visitLiteralNode(LiteralNode node) {
    _printNode('LiteralNode', {'value': node.value});
  }

  @override
  void visitIdentifierNode(IdentifierNode node) {
    _printNode('IdentifierNode', {'value': node.value});
  }

  @override
  void visitConstListNode(ConstListNode node) {
    _printNode('ConstListNode');
    _withIndentation(() {
      _visitNodeList(node.elements, 'Elements');
    });
  }

  @override
  void visitConstMapNode(ConstMapNode node) {
    _printNode('ConstMapNode');
    _withIndentation(() {
      // For maps, print each entry as a pair
      if (node.entries.isEmpty) {
        _printNode('Entries: {}');
        return;
      }
      _printNode('Entries:');
      _withIndentation(() {
        for (final entry in node.entries) {
          _printNode('Entry:');
          _withIndentation(() {
            _printNode('Key:');
            _withIndentation(() => entry.key.accept(this));
            _printNode('Value:');
            _withIndentation(() => entry.value.accept(this));
          });
        }
      });
    });
  }
}
