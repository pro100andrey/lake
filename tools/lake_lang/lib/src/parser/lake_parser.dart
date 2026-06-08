import 'ast/ast_base.dart';
import 'lake_lexer.dart';
import 'token_type.dart';

class LakeParser {
  LakeParser(String input) : _lexer = LakeLexer(input), _input = input;

  final LakeLexer _lexer;
  final String _input;

  Never _reportError(String message) {
    var line = 1;
    var column = 1;
    for (var i = 0; i < _lexer.currentStart; i++) {
      if (_input.codeUnitAt(i) == 10) {
        line++;
        column = 1;
      } else {
        column++;
      }
    }

    throw FormatException(
      'Lake Parser Error at line $line, column $column: $message. '
      "Found: ${_lexer.currentType.displayName} ('${_lexer.getSlice()}')",
    );
  }

  void _expect(TokenType type, String errorMessage) {
    if (_lexer.currentType == type) {
      _lexer.advance();
    } else {
      _reportError(errorMessage);
    }
  }

  void _optionalListSeparator() {
    if (_lexer.currentType == TokenType.comma ||
        _lexer.currentType == TokenType.semicolon) {
      _lexer.advance();
    }
  }

  DocumentNode parseDocument() {
    final start = _lexer.currentStart;
    final headers = <HeaderNode>[];
    final definitions = <DefinitionNode>[];

    while (_lexer.currentType != TokenType.eof) {
      if (_lexer.currentType == TokenType.kwImport ||
          _lexer.currentType == TokenType.kwNamespace) {
        headers.add(_parseHeader());
      } else {
        definitions.add(_parseDefinition());
      }
    }

    return DocumentNode(
      headers: headers,
      definitions: definitions,
      startOffset: start,
      endOffset: _lexer.currentEnd,
    );
  }

  HeaderNode _parseHeader() {
    if (_lexer.currentType == TokenType.kwImport) {
      return _parseImport();
    } else if (_lexer.currentType == TokenType.kwNamespace) {
      return _parseNamespace();
    } else {
      _reportError("Expected 'import' or 'namespace'");
    }
  }

  ImportNode _parseImport() {
    final start = _lexer.currentStart;
    _expect(TokenType.kwImport, "Expected 'import'");
    final path = _parseStringLiteral();
    _optionalListSeparator();
    return ImportNode(
      path: path,
      startOffset: start,
      endOffset: _lexer.currentEnd,
    );
  }

  NamespaceNode _parseNamespace() {
    final start = _lexer.currentStart;
    _expect(TokenType.kwNamespace, "Expected 'namespace'");

    final scopeStart = _lexer.currentStart;
    String scopeName;
    if (_lexer.currentType == TokenType.asterisk) {
      scopeName = '*';
      _lexer.advance();
    } else if (_lexer.currentType == TokenType.identifier) {
      scopeName = _lexer.getSlice();
      _lexer.advance();
    } else {
      _reportError("Expected namespace scope ('*', 'js', 'dart', etc.)");
    }

    final scope = IdentifierNode(
      name: scopeName,
      startOffset: scopeStart,
      endOffset: _lexer.currentStart,
    ); // End of scope identifier
    final identifier = _parseIdentifier();
    _optionalListSeparator();
    return NamespaceNode(
      scope: scope,
      identifier: identifier,
      startOffset: start,
      endOffset: _lexer.currentEnd,
    );
  }

  DefinitionNode _parseDefinition() {
    switch (_lexer.currentType) {
      case TokenType.kwConst:
        return _parseConstDefinition();
      case TokenType.kwTypedef:
        return _parseTypedefDefinition();
      case TokenType.kwEnum:
        return _parseEnumDefinition();
      case TokenType.kwStruct:
        return _parseStructDefinition();
      case TokenType.kwUnion:
        return _parseUnionDefinition();
      case TokenType.kwException:
        return _parseExceptionDefinition();
      case TokenType.kwService:
        return _parseServiceDefinition();
      //
      // ignore: no_default_cases
      default:
        _reportError(
          'Expected a definition '
          '(const, typedef, enum, struct, union, exception, service)',
        );
    }
  }

  ConstDefinitionNode _parseConstDefinition() {
    final start = _lexer.currentStart;
    _expect(TokenType.kwConst, "Expected 'const'");
    final type = _parseType();
    final identifier = _parseIdentifier();
    _expect(TokenType.equals, "Expected '=' in const definition");
    final value = _parseLiteralValue();
    _optionalListSeparator();
    return ConstDefinitionNode(
      type: type,
      identifier: identifier,
      value: value,
      startOffset: start,
      endOffset: _lexer.currentEnd,
    );
  }

  TypedefDefinitionNode _parseTypedefDefinition() {
    final start = _lexer.currentStart;
    _expect(TokenType.kwTypedef, "Expected 'typedef'");
    // DefinitionType ::= ContainerType | BaseType
    final type = _parseType();
    if (type is CustomTypeNode || type is StreamTypeNode) {
      _reportError('typedef allows only base types or container types');
    }
    final identifier = _parseIdentifier();
    _optionalListSeparator();
    return TypedefDefinitionNode(
      type: type,
      identifier: identifier,
      startOffset: start,
      endOffset: _lexer.currentEnd,
    );
  }

  EnumDefinitionNode _parseEnumDefinition() {
    final start = _lexer.currentStart;
    _expect(TokenType.kwEnum, "Expected 'enum'");
    final identifier = _parseIdentifier();
    _expect(TokenType.braceLeft, "Expected '{' after enum name");

    final members = <EnumValueNode>[];
    while (_lexer.currentType != TokenType.braceRight &&
        _lexer.currentType != TokenType.eof) {
      final memberStart = _lexer.currentStart;
      final memberId = _parseIdentifier();
      IntLiteralNode? value;
      if (_lexer.currentType == TokenType.equals) {
        _lexer.advance();
        value = _parseIntLiteral();
      }
      _optionalListSeparator();
      members.add(
        EnumValueNode(
          identifier: memberId,
          value: value,
          startOffset: memberStart,
          endOffset: _lexer.currentEnd,
        ),
      );
    }
    _expect(TokenType.braceRight, "Expected '}' to close enum definition");
    return EnumDefinitionNode(
      identifier: identifier,
      members: members,
      startOffset: start,
      endOffset: _lexer.currentEnd,
    );
  }

  StructDefinitionNode _parseStructDefinition() {
    final start = _lexer.currentStart;
    _expect(TokenType.kwStruct, "Expected 'struct'");
    final identifier = _parseIdentifier();
    _expect(TokenType.braceLeft, "Expected '{' after struct name");
    final fields = _parseFields();
    _expect(TokenType.braceRight, "Expected '}' to close struct definition");
    return StructDefinitionNode(
      identifier: identifier,
      fields: fields,
      startOffset: start,
      endOffset: _lexer.currentEnd,
    );
  }

  UnionDefinitionNode _parseUnionDefinition() {
    final start = _lexer.currentStart;
    _expect(TokenType.kwUnion, "Expected 'union'");
    final identifier = _parseIdentifier();
    _expect(TokenType.braceLeft, "Expected '{' after union name");
    final fields = _parseFields();
    _expect(TokenType.braceRight, "Expected '}' to close union definition");
    return UnionDefinitionNode(
      identifier: identifier,
      fields: fields,
      startOffset: start,
      endOffset: _lexer.currentEnd,
    );
  }

  ExceptionDefinitionNode _parseExceptionDefinition() {
    final start = _lexer.currentStart;
    _expect(TokenType.kwException, "Expected 'exception'");
    final identifier = _parseIdentifier();
    _expect(TokenType.braceLeft, "Expected '{' after exception name");
    final fields = _parseFields();
    _expect(TokenType.braceRight, "Expected '}' to close exception definition");
    return ExceptionDefinitionNode(
      identifier: identifier,
      fields: fields,
      startOffset: start,
      endOffset: _lexer.currentEnd,
    );
  }

  ServiceDefinitionNode _parseServiceDefinition() {
    final start = _lexer.currentStart;
    _expect(TokenType.kwService, "Expected 'service'");
    final identifier = _parseIdentifier();

    IdentifierNode? extendsService;
    if (_lexer.currentType == TokenType.kwExtends) {
      _lexer.advance();
      extendsService = _parseIdentifier();
    }

    _expect(TokenType.braceLeft, "Expected '{' after service name");
    final methods = <MethodNode>[];
    while (_lexer.currentType != TokenType.braceRight &&
        _lexer.currentType != TokenType.eof) {
      methods.add(_parseMethod());
    }
    _expect(TokenType.braceRight, "Expected '}' to close service definition");
    return ServiceDefinitionNode(
      identifier: identifier,
      extendsService: extendsService,
      methods: methods,
      startOffset: start,
      endOffset: _lexer.currentEnd,
    );
  }

  List<FieldNode> _parseFields() {
    final fields = <FieldNode>[];
    while (_lexer.currentType != TokenType.braceRight &&
        _lexer.currentType != TokenType.eof) {
      fields.add(_parseField());
    }
    return fields;
  }

  FieldNode _parseField() {
    final start = _lexer.currentStart;
    IntLiteralNode? fieldId;
    var isRequired = false;

    // Optional field ID
    if (_lexer.currentType == TokenType.intLiteral) {
      final idNode = _parseIntLiteral();
      if (_lexer.currentType == TokenType.colon) {
        fieldId = idNode;
        _lexer.advance();
      } else {
        // Panic recovery: could be a missing colon, or this wasn't an ID at
        // all? In Lake grammar `1: type name` is standard, `1 type name` is
        // invalid
        _reportError("Expected ':' after field id");
      }
    }

    if (_lexer.currentType == TokenType.kwRequired) {
      isRequired = true;
      _lexer.advance();
    } else if (_lexer.currentType == TokenType.kwOptional) {
      isRequired = false;
      _lexer.advance();
    }

    final type = _parseType();

    // Panic mode: Ensure an identifier comes after type, otherwise throw a
    //clear error
    if (_lexer.currentType != TokenType.identifier) {
      _reportError('Expected field identifier name after its type');
    }
    final identifier = _parseIdentifier();

    LiteralValueNode? defaultValue;
    if (_lexer.currentType == TokenType.equals) {
      _lexer.advance();
      defaultValue = _parseLiteralValue();
    }

    _optionalListSeparator();

    return FieldNode(
      fieldId: fieldId,
      isRequired: isRequired,
      type: type,
      identifier: identifier,
      defaultValue: defaultValue,
      startOffset: start,
      endOffset: _lexer.currentEnd,
    );
  }

  MethodNode _parseMethod() {
    final start = _lexer.currentStart;
    final TypeNode returnType;
    if (_lexer.currentType == TokenType.kwVoid) {
      returnType = VoidTypeNode(
        startOffset: _lexer.currentStart,
        endOffset: _lexer.currentEnd,
      );
      _lexer.advance();
    } else {
      returnType = _parseType();
    }

    final identifier = _parseIdentifier();

    _expect(TokenType.parenLeft, "Expected '(' for method parameters");
    final parameters = <FieldNode>[];
    while (_lexer.currentType != TokenType.parenRight &&
        _lexer.currentType != TokenType.eof) {
      parameters.add(_parseField());
    }
    _expect(TokenType.parenRight, "Expected ')' to close method parameters");

    final throwsList = <FieldNode>[];
    if (_lexer.currentType == TokenType.kwThrows) {
      _lexer.advance();
      _expect(TokenType.parenLeft, "Expected '(' after throws");
      while (_lexer.currentType != TokenType.parenRight &&
          _lexer.currentType != TokenType.eof) {
        throwsList.add(_parseField());
      }
      _expect(TokenType.parenRight, "Expected ')' to close throws list");
    }

    _optionalListSeparator();

    return MethodNode(
      returnType: returnType,
      identifier: identifier,
      parameters: parameters,
      throws: throwsList,
      startOffset: start,
      endOffset: _lexer.currentEnd,
    );
  }

  TypeNode _parseType() {
    final start = _lexer.currentStart;

    switch (_lexer.currentType) {
      case TokenType.kwBool:
      case TokenType.kwByte:
      case TokenType.kwI8:
      case TokenType.kwI16:
      case TokenType.kwI32:
      case TokenType.kwI64:
      case TokenType.kwDouble:
      case TokenType.kwString:
      case TokenType.kwBinary:
      case TokenType.kwUuid:
        final name = _lexer.getSlice();
        _lexer.advance();
        return BaseTypeNode(
          name: name,
          startOffset: start,
          endOffset: _lexer.currentEnd,
        );

      case TokenType.kwMap:
        _lexer.advance();
        _expect(TokenType.angleLeft, "Expected '<' after map");
        final keyType = _parseType();
        _expect(TokenType.comma, "Expected ',' between map types");
        final valueType = _parseType();
        _expect(TokenType.angleRight, "Expected '>' to close map type");
        return MapTypeNode(
          keyType: keyType,
          valueType: valueType,
          startOffset: start,
          endOffset: _lexer.currentEnd,
        );

      case TokenType.kwSet:
        _lexer.advance();
        _expect(TokenType.angleLeft, "Expected '<' after set");
        final elementType = _parseType();
        _expect(TokenType.angleRight, "Expected '>' to close set type");

        return SetTypeNode(
          elementType: elementType,
          startOffset: start,
          endOffset: _lexer.currentEnd,
        );

      case TokenType.kwList:
        _lexer.advance();
        _expect(TokenType.angleLeft, "Expected '<' after list");
        final elementType = _parseType();
        _expect(TokenType.angleRight, "Expected '>' to close list type");

        return ListTypeNode(
          elementType: elementType,
          startOffset: start,
          endOffset: _lexer.currentEnd,
        );

      case TokenType.kwStream:
        _lexer.advance();
        _expect(TokenType.angleLeft, "Expected '<' after stream");
        final elementType = _parseType();
        _expect(TokenType.angleRight, "Expected '>' to close stream type");

        return StreamTypeNode(
          elementType: elementType,
          startOffset: start,
          endOffset: _lexer.currentEnd,
        );

      case TokenType.identifier:
        final name = _lexer.getSlice();
        _lexer.advance();

        return CustomTypeNode(
          name: name,
          startOffset: start,
          endOffset: _lexer.currentEnd,
        );

      case _:
        _reportError(
          'Expected a type (base type, container, stream, or identifier)',
        );
    }
  }

  LiteralValueNode _parseLiteralValue() {
    switch (_lexer.currentType) {
      case TokenType.bracketLeft:
        return _parseListLiteral();

      case TokenType.braceLeft:
        return _parseMapLiteral();

      case TokenType.intLiteral:
        return _parseIntLiteral();

      case TokenType.doubleLiteral:
        return _parseDoubleLiteral();

      case TokenType.kwTrue:
      case TokenType.kwFalse:
        final start = _lexer.currentStart;
        final val = _lexer.currentType == TokenType.kwTrue;
        _lexer.advance();

        return BoolLiteralNode(
          value: val,
          startOffset: start,
          endOffset: _lexer.currentEnd,
        );

      case TokenType.stringLiteral:
        return _parseStringLiteral();

      case TokenType.identifier:
        return _parseIdentifier();

      case _:
        _reportError(
          'Expected a literal value (number, string, true/false, list, map, or identifier)',
        );
    }
  }

  ListLiteralNode _parseListLiteral() {
    final start = _lexer.currentStart;
    _expect(TokenType.bracketLeft, "Expected '[' for list literal");
    final elements = <LiteralValueNode>[];
    while (_lexer.currentType != TokenType.bracketRight &&
        _lexer.currentType != TokenType.eof) {
      elements.add(_parseLiteralValue());
      _optionalListSeparator();
    }
    _expect(TokenType.bracketRight, "Expected ']' to close list literal");

    return ListLiteralNode(
      elements: elements,
      startOffset: start,
      endOffset: _lexer.currentEnd,
    );
  }

  MapLiteralNode _parseMapLiteral() {
    final start = _lexer.currentStart;
    _expect(TokenType.braceLeft, "Expected '{' for map literal");
    final entries = <MapLiteralEntry>[];
    while (_lexer.currentType != TokenType.braceRight &&
        _lexer.currentType != TokenType.eof) {
      final key = _parseLiteralValue();
      _expect(TokenType.colon, "Expected ':' in map literal entry");
      final value = _parseLiteralValue();
      _optionalListSeparator();
      entries.add((key: key, value: value));
    }
    _expect(TokenType.braceRight, "Expected '}' to close map literal");
    return MapLiteralNode(
      entries: entries,
      startOffset: start,
      endOffset: _lexer.currentEnd,
    );
  }

  IntLiteralNode _parseIntLiteral() {
    if (_lexer.currentType != TokenType.intLiteral) {
      _reportError('Expected integer literal');
    }

    final start = _lexer.currentStart;
    final value = int.parse(_lexer.getSlice());
    _lexer.advance();

    return IntLiteralNode(
      value: value,
      startOffset: start,
      endOffset: _lexer.currentEnd,
    );
  }

  DoubleLiteralNode _parseDoubleLiteral() {
    if (_lexer.currentType != TokenType.doubleLiteral) {
      _reportError('Expected double literal');
    }

    final start = _lexer.currentStart;
    final value = double.parse(_lexer.getSlice());
    _lexer.advance();

    return DoubleLiteralNode(
      value: value,
      startOffset: start,
      endOffset: _lexer.currentEnd,
    );
  }

  StringLiteralNode _parseStringLiteral() {
    if (_lexer.currentType != TokenType.stringLiteral) {
      _reportError('Expected string literal');
    }

    final start = _lexer.currentStart;
    final raw = _lexer.getSlice();
    final value = raw.substring(1, raw.length - 1);
    _lexer.advance();

    return StringLiteralNode(
      value: value,
      startOffset: start,
      endOffset: _lexer.currentEnd,
    );
  }

  IdentifierNode _parseIdentifier() {
    if (_lexer.currentType != TokenType.identifier) {
      _reportError('Expected identifier');
    }

    final start = _lexer.currentStart;
    final name = _lexer.getSlice();
    _lexer.advance();

    return IdentifierNode(
      name: name,
      startOffset: start,
      endOffset: _lexer.currentEnd,
    );
  }
}
