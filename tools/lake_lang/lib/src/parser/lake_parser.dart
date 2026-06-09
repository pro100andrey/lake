import '../analyzer/errors/error_reporter.dart';
import 'ast/ast_base.dart';
import 'lake_lexer.dart';
import 'token_type.dart';

class _ParseException implements Exception {
  const _ParseException();
}

class LakeParser {
  LakeParser(String input, [ErrorReporter? reporter])
    : _lexer = LakeLexer(input),
      _reporter = reporter ?? ErrorReporter();

  final LakeLexer _lexer;

  final ErrorReporter _reporter;

  Never _reportError(String message) {
    // We no longer need line/column calculation because ErrorReporter handles offsets directly.
    _reporter.reportGeneric(
      message:
          'Lake Parser Error: $message. '
          "Found: ${_lexer.currentType.displayName} ('${_lexer.getSlice()}')",
      startOffset: _lexer.currentStart,
      endOffset: _lexer.currentEnd,
    );

    throw const _ParseException();
  }

  void _expect(TokenType type, [String? errorMessage]) {
    if (_lexer.currentType == type) {
      _lexer.advance();
    } else {
      _reportError(errorMessage ?? 'Expected ${type.displayName}');
    }
  }

  void _optionalListSeparator() {
    if (_lexer.currentType case .comma || .semicolon) {
      _lexer.advance();
    }
  }

  DocumentNode parseDocument() {
    final start = _lexer.currentStart;
    final headers = <HeaderNode>[];
    final definitions = <DefinitionNode>[];

    while (_lexer.currentType != .eof) {
      try {
        if (_lexer.currentType case .kwImport || .kwNamespace) {
          headers.add(_parseHeader());
        } else {
          definitions.add(_parseDefinition());
        }
      } on _ParseException {
        _synchronizeDeclaration();
      }
    }

    return DocumentNode(
      headers: headers,
      definitions: definitions,
      startOffset: start,
      endOffset: _lexer.currentEnd,
    );
  }

  void _synchronizeDeclaration() {
    while (_lexer.currentType != .eof) {
      switch (_lexer.currentType) {
        case .kwImport:
        case .kwNamespace:
        case .kwStruct:
        case .kwEnum:
        case .kwUnion:
        case .kwException:
        case .kwService:
        case .kwConst:
        case .kwTypedef:
          return;
        case _:
          _lexer.advance();
      }
    }
  }

  HeaderNode _parseHeader() {
    switch (_lexer.currentType) {
      case .kwImport:
        return _parseImport();
      case .kwNamespace:
        return _parseNamespace();
      case _:
        _reportError("Expected 'import' or 'namespace'");
    }
  }

  ImportNode _parseImport() {
    final start = _lexer.currentStart;
    _expect(.kwImport);

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
    _expect(.kwNamespace);

    final scopeStart = _lexer.currentStart;
    String scopeName;
    switch (_lexer.currentType) {
      case .asterisk:
        scopeName = '*';
        _lexer.advance();
      case .identifier:
        scopeName = _lexer.getSlice();
        _lexer.advance();
      case _:
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
    final docComment = _lexer.consumeDocComments();
    switch (_lexer.currentType) {
      case .kwConst:
        return _parseConstDefinition(docComment);
      case .kwTypedef:
        return _parseTypedefDefinition(docComment);
      case .kwEnum:
        return _parseEnumDefinition(docComment);
      case .kwStruct:
        return _parseStructDefinition(docComment);
      case .kwUnion:
        return _parseUnionDefinition(docComment);
      case .kwException:
        return _parseExceptionDefinition(docComment);
      case .kwService:
        return _parseServiceDefinition(docComment);
      case _:
        _reportError(
          'Expected a definition '
          '(const, typedef, enum, struct, union, exception, service)',
        );
    }
  }

  ConstDefinitionNode _parseConstDefinition(String? docComment) {
    final start = _lexer.currentStart;
    _expect(.kwConst);
    final type = _parseType();
    final identifier = _parseIdentifier();
    _expect(.equals, "Expected '=' in const definition");

    final value = _parseLiteralValue();
    _optionalListSeparator();

    return ConstDefinitionNode(
      type: type,
      identifier: identifier,
      value: value,
      startOffset: start,
      endOffset: _lexer.currentEnd,
      docComment: docComment,
    );
  }

  TypedefDefinitionNode _parseTypedefDefinition(String? docComment) {
    final start = _lexer.currentStart;
    _expect(.kwTypedef);
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
      docComment: docComment,
    );
  }

  EnumDefinitionNode _parseEnumDefinition(String? docComment) {
    final start = _lexer.currentStart;
    _expect(.kwEnum);
    final identifier = _parseIdentifier();
    _expect(.braceLeft, "Expected '{' after enum name");

    final members = <EnumValueNode>[];
    while (_lexer.currentType != .braceRight && _lexer.currentType != .eof) {
      final docComment = _lexer.consumeDocComments();
      final memberStart = _lexer.currentStart;
      final memberId = _parseIdentifier();

      IntLiteralNode? value;
      if (_lexer.currentType == .equals) {
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
          docComment: docComment,
        ),
      );
    }

    _expect(TokenType.braceRight, "Expected '}' to close enum definition");

    return EnumDefinitionNode(
      identifier: identifier,
      members: members,
      startOffset: start,
      endOffset: _lexer.currentEnd,
      docComment: docComment,
    );
  }

  StructDefinitionNode _parseStructDefinition(String? docComment) {
    final start = _lexer.currentStart;
    _expect(.kwStruct);
    final identifier = _parseIdentifier();
    _expect(.braceLeft, "Expected '{' after struct name");
    final fields = _parseFields();
    _expect(.braceRight, "Expected '}' to close struct definition");

    return StructDefinitionNode(
      identifier: identifier,
      fields: fields,
      startOffset: start,
      endOffset: _lexer.currentEnd,
      docComment: docComment,
    );
  }

  UnionDefinitionNode _parseUnionDefinition(String? docComment) {
    final start = _lexer.currentStart;
    _expect(.kwUnion);
    final identifier = _parseIdentifier();
    _expect(.braceLeft, "Expected '{' after union name");
    final fields = _parseFields();
    _expect(.braceRight, "Expected '}' to close union definition");

    return UnionDefinitionNode(
      identifier: identifier,
      fields: fields,
      startOffset: start,
      endOffset: _lexer.currentEnd,
      docComment: docComment,
    );
  }

  ExceptionDefinitionNode _parseExceptionDefinition(String? docComment) {
    final start = _lexer.currentStart;
    _expect(.kwException);
    final identifier = _parseIdentifier();
    _expect(.braceLeft, "Expected '{' after exception name");
    final fields = _parseFields();
    _expect(.braceRight, "Expected '}' to close exception definition");

    return ExceptionDefinitionNode(
      identifier: identifier,
      fields: fields,
      startOffset: start,
      endOffset: _lexer.currentEnd,
      docComment: docComment,
    );
  }

  ServiceDefinitionNode _parseServiceDefinition(String? docComment) {
    final start = _lexer.currentStart;
    _expect(.kwService);
    final identifier = _parseIdentifier();

    IdentifierNode? extendsService;
    if (_lexer.currentType == .kwExtends) {
      _lexer.advance();
      extendsService = _parseIdentifier();
    }

    _expect(.braceLeft, "Expected '{' after service name");
    final methods = <MethodNode>[];
    while (_lexer.currentType != .braceRight && _lexer.currentType != .eof) {
      try {
        methods.add(_parseMethod());
      } on _ParseException {
        _synchronizeMethod();
      }
    }
    _expect(.braceRight, "Expected '}' to close service definition");

    return ServiceDefinitionNode(
      identifier: identifier,
      extendsService: extendsService,
      methods: methods,
      startOffset: start,
      endOffset: _lexer.currentEnd,
      docComment: docComment,
    );
  }

  List<FieldNode> _parseFields() {
    final fields = <FieldNode>[];
    while (_lexer.currentType != .braceRight && _lexer.currentType != .eof) {
      try {
        fields.add(_parseField());
      } on _ParseException {
        _synchronizeField();
      }
    }

    return fields;
  }

  void _synchronizeField() {
    while (_lexer.currentType != .eof) {
      switch (_lexer.currentType) {
        case .kwRequired:
        case .kwOptional:
        case .identifier:
        case .braceRight:
        case .intLiteral:
        case .kwBool:
        case .kwByte:
        case .kwI8:
        case .kwI16:
        case .kwI32:
        case .kwI64:
        case .kwDouble:
        case .kwString:
        case .kwBinary:
        case .kwList:
        case .kwMap:
        case .kwSet:
        case .kwStream:
        case .kwUuid:
          return;
        case _:
          _lexer.advance();
      }
    }
  }

  void _synchronizeMethod() {
    while (_lexer.currentType != .eof) {
      switch (_lexer.currentType) {
        case .identifier:
        case .braceRight:
        case .kwVoid:
        case .kwBool:
        case .kwByte:
        case .kwI8:
        case .kwI16:
        case .kwI32:
        case .kwI64:
        case .kwDouble:
        case .kwString:
        case .kwBinary:
        case .kwList:
        case .kwMap:
        case .kwSet:
        case .kwStream:
        case .kwUuid:
          return;
        case _:
          _lexer.advance();
      }
    }
  }

  FieldNode _parseField() {
    final docComment = _lexer.consumeDocComments();
    final start = _lexer.currentStart;
    IntLiteralNode? fieldId;
    var isRequired = false;

    // Optional field ID
    if (_lexer.currentType == .intLiteral) {
      final idNode = _parseIntLiteral();
      if (_lexer.currentType == .colon) {
        fieldId = idNode;
        _lexer.advance();
      } else {
        // Panic recovery: could be a missing colon, or this wasn't an ID at
        // all? In Lake grammar `1: type name` is standard, `1 type name` is
        // invalid
        _reportError("Expected ':' after field id");
      }
    }

    switch (_lexer.currentType) {
      case .kwRequired:
        isRequired = true;
        _lexer.advance();
      case .kwOptional:
        isRequired = false;
        _lexer.advance();
      case _:
        break;
    }

    final type = _parseType();

    // Panic mode: Ensure an identifier comes after type, otherwise throw a
    //clear error
    if (_lexer.currentType != .identifier) {
      _reportError('Expected field identifier name after its type');
    }
    final identifier = _parseIdentifier();

    LiteralValueNode? defaultValue;
    if (_lexer.currentType == .equals) {
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
      docComment: docComment,
    );
  }

  MethodNode _parseMethod() {
    final docComment = _lexer.consumeDocComments();
    final start = _lexer.currentStart;
    final TypeNode returnType;
    if (_lexer.currentType == .kwVoid) {
      returnType = VoidTypeNode(
        startOffset: _lexer.currentStart,
        endOffset: _lexer.currentEnd,
      );
      _lexer.advance();
    } else {
      returnType = _parseType();
    }

    final identifier = _parseIdentifier();

    _expect(.parenLeft, "Expected '(' for method parameters");
    final parameters = <FieldNode>[];
    while (_lexer.currentType != .parenRight && _lexer.currentType != .eof) {
      parameters.add(_parseField());
    }

    _expect(.parenRight, "Expected ')' to close method parameters");

    final throwsList = <FieldNode>[];
    if (_lexer.currentType == .kwThrows) {
      _lexer.advance();
      _expect(.parenLeft, "Expected '(' after throws");
      while (_lexer.currentType != .parenRight && _lexer.currentType != .eof) {
        throwsList.add(_parseField());
      }
      _expect(.parenRight, "Expected ')' to close throws list");
    }

    _optionalListSeparator();

    return MethodNode(
      returnType: returnType,
      identifier: identifier,
      parameters: parameters,
      throws: throwsList,
      startOffset: start,
      endOffset: _lexer.currentEnd,
      docComment: docComment,
    );
  }

  TypeNode _parseType() {
    final start = _lexer.currentStart;

    switch (_lexer.currentType) {
      case .kwBool:
      case .kwByte:
      case .kwI8:
      case .kwI16:
      case .kwI32:
      case .kwI64:
      case .kwDouble:
      case .kwString:
      case .kwBinary:
      case .kwUuid:
        final name = _lexer.getSlice();
        _lexer.advance();
        return BaseTypeNode(
          name: name,
          startOffset: start,
          endOffset: _lexer.currentEnd,
        );

      case .kwMap:
        _lexer.advance();
        _expect(.angleLeft, "Expected '<' after map");
        final keyType = _parseType();
        _expect(.comma, "Expected ',' between map types");
        final valueType = _parseType();
        _expect(.angleRight, "Expected '>' to close map type");

        return MapTypeNode(
          keyType: keyType,
          valueType: valueType,
          startOffset: start,
          endOffset: _lexer.currentEnd,
        );

      case .kwSet:
        _lexer.advance();
        _expect(.angleLeft, "Expected '<' after set");
        final elementType = _parseType();
        _expect(.angleRight, "Expected '>' to close set type");

        return SetTypeNode(
          elementType: elementType,
          startOffset: start,
          endOffset: _lexer.currentEnd,
        );

      case .kwList:
        _lexer.advance();
        _expect(.angleLeft, "Expected '<' after list");
        final elementType = _parseType();
        _expect(.angleRight, "Expected '>' to close list type");

        return ListTypeNode(
          elementType: elementType,
          startOffset: start,
          endOffset: _lexer.currentEnd,
        );

      case .kwStream:
        _lexer.advance();
        _expect(.angleLeft, "Expected '<' after stream");
        final elementType = _parseType();
        _expect(.angleRight, "Expected '>' to close stream type");

        return StreamTypeNode(
          elementType: elementType,
          startOffset: start,
          endOffset: _lexer.currentEnd,
        );

      case .identifier:
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
      case .bracketLeft:
        return _parseListLiteral();

      case .braceLeft:
        return _parseMapLiteral();

      case .intLiteral:
        return _parseIntLiteral();

      case .doubleLiteral:
        return _parseDoubleLiteral();

      case .kwTrue:
      case .kwFalse:
        final start = _lexer.currentStart;
        final val = _lexer.currentType == .kwTrue;
        _lexer.advance();

        return BoolLiteralNode(
          value: val,
          startOffset: start,
          endOffset: _lexer.currentEnd,
        );

      case .stringLiteral:
        return _parseStringLiteral();

      case .identifier:
        return _parseIdentifier();

      case _:
        _reportError(
          'Expected a literal value (number, string, true/false, list, map, or identifier)',
        );
    }
  }

  ListLiteralNode _parseListLiteral() {
    final start = _lexer.currentStart;
    _expect(.bracketLeft, "Expected '[' for list literal");

    final elements = <LiteralValueNode>[];
    while (_lexer.currentType != .bracketRight && _lexer.currentType != .eof) {
      elements.add(_parseLiteralValue());
      _optionalListSeparator();
    }

    _expect(.bracketRight, "Expected ']' to close list literal");

    return ListLiteralNode(
      elements: elements,
      startOffset: start,
      endOffset: _lexer.currentEnd,
    );
  }

  MapLiteralNode _parseMapLiteral() {
    final start = _lexer.currentStart;
    _expect(.braceLeft, "Expected '{' for map literal");

    final entries = <MapLiteralEntry>[];
    while (_lexer.currentType != .braceRight && _lexer.currentType != .eof) {
      final key = _parseLiteralValue();
      _expect(.colon, "Expected ':' in map literal entry");

      final value = _parseLiteralValue();
      _optionalListSeparator();
      entries.add((key: key, value: value));
    }

    _expect(.braceRight, "Expected '}' to close map literal");

    return MapLiteralNode(
      entries: entries,
      startOffset: start,
      endOffset: _lexer.currentEnd,
    );
  }

  IntLiteralNode _parseIntLiteral() {
    if (_lexer.currentType != .intLiteral) {
      _reportError('Expected integer literal');
    }

    final start = _lexer.currentStart;
    final value = _lexer.currentIntValue;
    _lexer.advance();

    return IntLiteralNode(
      value: value,
      startOffset: start,
      endOffset: _lexer.currentEnd,
    );
  }

  DoubleLiteralNode _parseDoubleLiteral() {
    if (_lexer.currentType != .doubleLiteral) {
      _reportError('Expected double literal');
    }

    final start = _lexer.currentStart;
    final value = _lexer.currentDoubleValue;
    _lexer.advance();

    return DoubleLiteralNode(
      value: value,
      startOffset: start,
      endOffset: _lexer.currentEnd,
    );
  }

  StringLiteralNode _parseStringLiteral() {
    if (_lexer.currentType != .stringLiteral) {
      _reportError('Expected string literal');
    }

    final start = _lexer.currentStart;
    final value = _lexer.currentStringValue;
    _lexer.advance();

    return StringLiteralNode(
      value: value,
      startOffset: start,
      endOffset: _lexer.currentEnd,
    );
  }

  IdentifierNode _parseIdentifier() {
    if (_lexer.currentType != .identifier) {
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
