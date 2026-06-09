import 'token_type.dart';

final List<TokenType?> _asciiLookup = .filled(128, null)
  // '{'
  ..[123] = .braceLeft
  // '}'
  ..[125] = .braceRight
  // '('
  ..[40] = .parenLeft
  // ')'
  ..[41] = .parenRight
  // '['
  ..[91] = .bracketLeft
  // ']'
  ..[93] = .bracketRight
  // '<'
  ..[60] = .angleLeft
  // '>'
  ..[62] = .angleRight
  // ':'
  ..[58] = .colon
  // '='
  ..[61] = .equals
  // ','
  ..[44] = .comma
  // ';'
  ..[59] = .semicolon
  // '*'
  ..[42] = .asterisk;

class LakeLexer {
  LakeLexer(this._input) {
    advance();
  }

  int get currentStart => _currentStart;
  int get currentEnd => _currentEnd;
  TokenType get currentType => _currentType;

  final String _input;

  var _cursor = 0;
  var _currentStart = 0;
  var _currentEnd = 0;
  var _currentType = TokenType.eof;

  final List<String> _pendingDocComments = [];

  String? consumeDocComments() {
    if (_pendingDocComments.isEmpty) {
      return null;
    }

    final text = _pendingDocComments.join('\n');
    _pendingDocComments.clear();

    return text;
  }

  void advance() {
    _skipWhitespaceAndComments();

    _currentStart = _cursor;

    if (_cursor >= _input.length) {
      _currentType = .eof;
      _currentEnd = _cursor;
      return;
    }

    final codeUnit = _input.codeUnitAt(_cursor);

    if (codeUnit < 128) {
      final type = _asciiLookup[codeUnit];
      if (type != null) {
        _currentType = type;
        _cursor++;
        _currentEnd = _cursor;
        return;
      }
    }

    // String Literal
    if (codeUnit == 34 /* " */ || codeUnit == 39 /* ' */ ) {
      _cursor++;
      while (_cursor < _input.length &&
          _input.codeUnitAt(_cursor) != codeUnit) {
        _cursor++;
      }

      if (_cursor < _input.length) {
        _cursor++; // Consume closing quote
      }

      _currentType = .stringLiteral;
      _currentEnd = _cursor;

      return;
    }

    // Numbers (Int or Double)
    if (_isDigit(codeUnit) ||
        codeUnit == 43 /* + */ ||
        codeUnit == 45 /* - */ ) {
      final tempCursor = _cursor;
      final hasSign = codeUnit == 43 || codeUnit == 45;
      if (hasSign) {
        _cursor++;
      }

      if (_cursor < _input.length && _isDigit(_input.codeUnitAt(_cursor))) {
        while (_cursor < _input.length &&
            _isDigit(_input.codeUnitAt(_cursor))) {
          _cursor++;
        }

        var isDouble = false;
        // Check for decimal point
        if (_cursor < _input.length &&
            _input.codeUnitAt(_cursor) == 46 /* . */ ) {
          isDouble = true;
          _cursor++;
          while (_cursor < _input.length &&
              _isDigit(_input.codeUnitAt(_cursor))) {
            _cursor++;
          }
        }

        // Check for exponent
        if (_cursor < _input.length &&
            (_input.codeUnitAt(_cursor) == 69 /* E */ ||
                _input.codeUnitAt(_cursor) == 101 /* e */ )) {
          isDouble = true;
          _cursor++;
          if (_cursor < _input.length &&
              (_input.codeUnitAt(_cursor) == 43 /* + */ ||
                  _input.codeUnitAt(_cursor) == 45 /* - */ )) {
            _cursor++;
          }
          while (_cursor < _input.length &&
              _isDigit(_input.codeUnitAt(_cursor))) {
            _cursor++;
          }
        }

        _currentType = isDouble ? .doubleLiteral : .intLiteral;
        _currentEnd = _cursor;
        return;
      } else {
        // Just a sign alone, not followed by digits. This shouldn't be valid
        // in the language grammar, but we backtrack to let it be parsed as an
        //error or something else.
        _cursor = tempCursor;
      }
    }

    // Identifiers and Keywords
    if (_isLetter(codeUnit) || codeUnit == 95 /* _ */ ) {
      _cursor++;
      while (_cursor < _input.length) {
        final c = _input.codeUnitAt(_cursor);
        if (_isLetterOrDigitOrUnderscore(c)) {
          _cursor++;
        } else if (c == 46 /* . */ ) {
          // Qualified identifiers can have dots
          _cursor++;
        } else {
          break;
        }
      }

      // If the identifier ends with a dot, we need to backtrack it because dot
      // must be followed by a valid char
      // To keep it simple, if it ends with dot, we just step back.
      if (_input.codeUnitAt(_cursor - 1) == 46) {
        _cursor--;
      }

      _currentType = _getIdentifierOrKeyword(_currentStart, _cursor);
      _currentEnd = _cursor;
      return;
    }

    // If we reach here, unrecognized character
    _cursor++;
    _currentType = .error;
    _currentEnd = _cursor;
  }

  void _skipWhitespaceAndComments() {
    while (_cursor < _input.length) {
      final codeUnit = _input.codeUnitAt(_cursor);

      // Whitespace
      if (codeUnit == 32 ||
          codeUnit == 9 ||
          codeUnit == 10 ||
          codeUnit == 13 ||
          codeUnit == 12) {
        _cursor++;
        continue;
      }

      // Comments
      if (codeUnit == 47 /* / */ && _cursor + 1 < _input.length) {
        final nextCodeUnit = _input.codeUnitAt(_cursor + 1);

        // Single-line comment: //
        if (nextCodeUnit == 47 /* / */ ) {
          var isDocComment = false;
          if (_cursor + 2 < _input.length &&
              _input.codeUnitAt(_cursor + 2) == 47) {
            isDocComment = true;
          }
          final startComment = _cursor;
          _cursor += 2;
          while (_cursor < _input.length &&
              _input.codeUnitAt(_cursor) != 10 /* \n */ ) {
            _cursor++;
          }
          if (isDocComment) {
            final commentText = _input
                .substring(startComment + 3, _cursor)
                .trim();
            _pendingDocComments.add(commentText);
          }
          continue;
        }

        // Multi-line comment: /* ... */
        if (nextCodeUnit == 42 /* * */ ) {
          _cursor += 2;
          var depth = 1;
          while (_cursor < _input.length && depth > 0) {
            if (_input.codeUnitAt(_cursor) == 42 &&
                _cursor + 1 < _input.length &&
                _input.codeUnitAt(_cursor + 1) == 47) {
              depth--;
              _cursor += 2;
            } else if (_input.codeUnitAt(_cursor) == 47 &&
                _cursor + 1 < _input.length &&
                _input.codeUnitAt(_cursor + 1) == 42) {
              depth++;
              _cursor += 2;
            } else {
              _cursor++;
            }
          }
          continue;
        }
      }

      // Neither whitespace nor comment
      break;
    }
  }

  String getSlice() => _input.substring(_currentStart, _currentEnd);

  // Character class helpers
  bool _isDigit(int c) => c >= 48 && c <= 57;

  bool _isLetter(int c) => (c >= 65 && c <= 90) || (c >= 97 && c <= 122);

  bool _isLetterOrDigitOrUnderscore(int c) =>
      _isLetter(c) || _isDigit(c) || c == 95;

  TokenType _getIdentifierOrKeyword(int start, int end) {
    final len = end - start;
    if (len < 2 || len > 9) {
      return .identifier;
    }

    final c0 = _input.codeUnitAt(start);

    switch ((len, c0)) {
      case (2, 105 /* i */) when _input.codeUnitAt(start + 1) == 56:
        return .kwI8;

      case (3, 115 /* s */) when _input.startsWith('et', start + 1):
        return .kwSet;
      case (3, 109 /* m */) when _input.startsWith('ap', start + 1):
        return .kwMap;
      case (3, 105 /* i */):
        final c1 = _input.codeUnitAt(start + 1);
        final c2 = _input.codeUnitAt(start + 2);
        if (c1 == 51 && c2 == 50) {
          return .kwI32;
        }
        if (c1 == 49 && c2 == 54) {
          return .kwI16;
        }
        if (c1 == 54 && c2 == 52) {
          return .kwI64;
        }

      case (4, 101 /* e */) when _input.startsWith('num', start + 1):
        return .kwEnum;
      case (4, 118 /* v */) when _input.startsWith('oid', start + 1):
        return .kwVoid;
      case (4, 108 /* l */) when _input.startsWith('ist', start + 1):
        return .kwList;
      case (4, 116 /* t */) when _input.startsWith('rue', start + 1):
        return .kwTrue;
      case (4, 98 /* b */):
        if (_input.startsWith('ool', start + 1)) {
          return .kwBool;
        }
        if (_input.startsWith('yte', start + 1)) {
          return .kwByte;
        }
      case (4, 117 /* u */) when _input.startsWith('uid', start + 1):
        return .kwUuid;

      case (5, 99 /* c */) when _input.startsWith('onst', start + 1):
        return .kwConst;
      case (5, 117 /* u */) when _input.startsWith('nion', start + 1):
        return .kwUnion;
      case (5, 102 /* f */) when _input.startsWith('alse', start + 1):
        return .kwFalse;

      case (6, 105 /* i */) when _input.startsWith('mport', start + 1):
        return .kwImport;
      case (6, 115 /* s */):
        if (_input.startsWith('truct', start + 1)) {
          return .kwStruct;
        }
        if (_input.startsWith('tream', start + 1)) {
          return .kwStream;
        }
        if (_input.startsWith('tring', start + 1)) {
          return .kwString;
        }
      case (6, 116 /* t */) when _input.startsWith('hrows', start + 1):
        return .kwThrows;
      case (6, 100 /* d */) when _input.startsWith('ouble', start + 1):
        return .kwDouble;
      case (6, 98 /* b */) when _input.startsWith('inary', start + 1):
        return .kwBinary;

      case (7, 116 /* t */) when _input.startsWith('ypedef', start + 1):
        return .kwTypedef;
      case (7, 115 /* s */) when _input.startsWith('ervice', start + 1):
        return .kwService;
      case (7, 101 /* e */) when _input.startsWith('xtends', start + 1):
        return .kwExtends;

      case (8, 114 /* r */) when _input.startsWith('equired', start + 1):
        return .kwRequired;
      case (8, 111 /* o */) when _input.startsWith('ptional', start + 1):
        return .kwOptional;

      case (9, 110 /* n */) when _input.startsWith('amespace', start + 1):
        return .kwNamespace;
      case (9, 101 /* e */) when _input.startsWith('xception', start + 1):
        return .kwException;
    }

    return .identifier;
  }
}
