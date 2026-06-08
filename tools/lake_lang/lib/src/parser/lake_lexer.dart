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
          _cursor += 2;
          while (_cursor < _input.length &&
              _input.codeUnitAt(_cursor) != 10 /* \n */ ) {
            _cursor++;
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
    switch (len) {
      case 2:
        if (_input.startsWith('i8', start)) {
          return TokenType.kwI8;
        }
      case 3:
        if (_input.startsWith('set', start)) {
          return TokenType.kwSet;
        }
        if (_input.startsWith('map', start)) {
          return TokenType.kwMap;
        }
        if (_input.startsWith('i32', start)) {
          return TokenType.kwI32;
        }
        if (_input.startsWith('i16', start)) {
          return TokenType.kwI16;
        }
        if (_input.startsWith('i64', start)) {
          return TokenType.kwI64;
        }
      case 4:
        if (_input.startsWith('enum', start)) {
          return TokenType.kwEnum;
        }
        if (_input.startsWith('void', start)) {
          return TokenType.kwVoid;
        }
        if (_input.startsWith('list', start)) {
          return TokenType.kwList;
        }
        if (_input.startsWith('true', start)) {
          return TokenType.kwTrue;
        }
        if (_input.startsWith('bool', start)) {
          return TokenType.kwBool;
        }
        if (_input.startsWith('byte', start)) {
          return TokenType.kwByte;
        }
        if (_input.startsWith('uuid', start)) {
          return TokenType.kwUuid;
        }
      case 5:
        if (_input.startsWith('const', start)) {
          return TokenType.kwConst;
        }
        if (_input.startsWith('union', start)) {
          return TokenType.kwUnion;
        }
        if (_input.startsWith('false', start)) {
          return TokenType.kwFalse;
        }
      case 6:
        if (_input.startsWith('import', start)) {
          return TokenType.kwImport;
        }
        if (_input.startsWith('struct', start)) {
          return TokenType.kwStruct;
        }
        if (_input.startsWith('throws', start)) {
          return TokenType.kwThrows;
        }
        if (_input.startsWith('stream', start)) {
          return TokenType.kwStream;
        }
        if (_input.startsWith('double', start)) {
          return TokenType.kwDouble;
        }
        if (_input.startsWith('string', start)) {
          return TokenType.kwString;
        }
        if (_input.startsWith('binary', start)) {
          return TokenType.kwBinary;
        }
      case 7:
        if (_input.startsWith('typedef', start)) {
          return TokenType.kwTypedef;
        }
        if (_input.startsWith('service', start)) {
          return TokenType.kwService;
        }
        if (_input.startsWith('extends', start)) {
          return TokenType.kwExtends;
        }
      case 8:
        if (_input.startsWith('required', start)) {
          return TokenType.kwRequired;
        }
        if (_input.startsWith('optional', start)) {
          return TokenType.kwOptional;
        }
      case 9:
        if (_input.startsWith('namespace', start)) {
          return TokenType.kwNamespace;
        }
        if (_input.startsWith('exception', start)) {
          return TokenType.kwException;
        }
    }
    return TokenType.identifier;
  }
}
