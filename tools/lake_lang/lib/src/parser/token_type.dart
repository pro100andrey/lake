/// Represents the type of a token produced by the LakeLexer.
enum TokenType {
  // Keywords
  kwImport,
  kwNamespace,
  kwConst,
  kwTypedef,
  kwEnum,
  kwStruct,
  kwUnion,
  kwException,
  kwService,
  kwExtends,
  kwRequired,
  kwOptional,
  kwVoid,
  kwThrows,
  kwMap,
  kwSet,
  kwList,
  kwStream,
  kwTrue,
  kwFalse,

  // Base types
  kwBool,
  kwByte,
  kwI8,
  kwI16,
  kwI32,
  kwI64,
  kwDouble,
  kwString,
  kwBinary,
  kwUuid,

  // Punctuation
  braceLeft, // {
  braceRight, // }
  parenLeft, // (
  parenRight, // )
  bracketLeft, // [
  bracketRight, // ]
  angleLeft, // <
  angleRight, // >
  colon, // :
  equals, // =
  comma, // ,
  semicolon, // ;
  asterisk, // *
  // Literals and identifiers
  identifier,
  intLiteral,
  doubleLiteral,
  stringLiteral,

  // End of file
  eof,

  // Represents an unrecognized or malformed token
  error,
}

/// Helper extension to easily get a printable name for tokens in error
/// messages.
extension TokenTypeExtension on TokenType {
  String get displayName {
    switch (this) {
      case TokenType.kwImport:
        return "'import'";
      case TokenType.kwNamespace:
        return "'namespace'";
      case TokenType.kwConst:
        return "'const'";
      case TokenType.kwTypedef:
        return "'typedef'";
      case TokenType.kwEnum:
        return "'enum'";
      case TokenType.kwStruct:
        return "'struct'";
      case TokenType.kwUnion:
        return "'union'";
      case TokenType.kwException:
        return "'exception'";
      case TokenType.kwService:
        return "'service'";
      case TokenType.kwExtends:
        return "'extends'";
      case TokenType.kwRequired:
        return "'required'";
      case TokenType.kwOptional:
        return "'optional'";
      case TokenType.kwVoid:
        return "'void'";
      case TokenType.kwThrows:
        return "'throws'";
      case TokenType.kwMap:
        return "'map'";
      case TokenType.kwSet:
        return "'set'";
      case TokenType.kwList:
        return "'list'";
      case TokenType.kwStream:
        return "'stream'";
      case TokenType.kwTrue:
        return "'true'";
      case TokenType.kwFalse:
        return "'false'";
      case TokenType.kwBool:
        return "'bool'";
      case TokenType.kwByte:
        return "'byte'";
      case TokenType.kwI8:
        return "'i8'";
      case TokenType.kwI16:
        return "'i16'";
      case TokenType.kwI32:
        return "'i32'";
      case TokenType.kwI64:
        return "'i64'";
      case TokenType.kwDouble:
        return "'double'";
      case TokenType.kwString:
        return "'string'";
      case TokenType.kwBinary:
        return "'binary'";
      case TokenType.kwUuid:
        return "'uuid'";
      case TokenType.braceLeft:
        return "'{'";
      case TokenType.braceRight:
        return "'}'";
      case TokenType.parenLeft:
        return "'('";
      case TokenType.parenRight:
        return "')'";
      case TokenType.bracketLeft:
        return "'['";
      case TokenType.bracketRight:
        return "']'";
      case TokenType.angleLeft:
        return "'<'";
      case TokenType.angleRight:
        return "'>'";
      case TokenType.colon:
        return "':'";
      case TokenType.equals:
        return "'='";
      case TokenType.comma:
        return "','";
      case TokenType.semicolon:
        return "';'";
      case TokenType.asterisk:
        return "'*'";
      case TokenType.identifier:
        return 'identifier';
      case TokenType.intLiteral:
        return 'integer literal';
      case TokenType.doubleLiteral:
        return 'double literal';
      case TokenType.stringLiteral:
        return 'string literal';
      case TokenType.eof:
        return 'end of file';
      case TokenType.error:
        return 'error';
    }
  }
}
