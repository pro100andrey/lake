/// Represents the type of a token produced by the LakeLexer.
enum TokenType {
  // Keywords
  kwImport("'import'"),
  kwNamespace("'namespace'"),
  kwConst("'const'"),
  kwTypedef("'typedef'"),
  kwEnum("'enum'"),
  kwStruct("'struct'"),
  kwUnion("'union'"),
  kwException("'exception'"),
  kwService("'service'"),
  kwExtends("'extends'"),
  kwRequired("'required'"),
  kwOptional("'optional'"),
  kwVoid("'void'"),
  kwThrows("'throws'"),
  kwMap("'map'"),
  kwSet("'set'"),
  kwList("'list'"),
  kwStream("'stream'"),
  kwTrue("'true'"),
  kwFalse("'false'"),

  // Base types
  kwBool("'bool'"),
  kwByte("'byte'"),
  kwI8("'i8'"),
  kwI16("'i16'"),
  kwI32("'i32'"),
  kwI64("'i64'"),
  kwDouble("'double'"),
  kwString("'string'"),
  kwBinary("'binary'"),
  kwUuid("'uuid'"),

  // Punctuation
  braceLeft("'{'"), // {
  braceRight("'}'"), // }
  parenLeft("'('"), // (
  parenRight("')'"), // )
  bracketLeft("'['"), // [
  bracketRight("']'"), // ]
  angleLeft("'<'"), // <
  angleRight("'>'"), // >
  colon("':'"), // :
  equals("'='"), // =
  comma("','"), // ,
  semicolon("';'"), // ;
  asterisk("'*'"), // *

  // Literals and identifiers
  identifier('identifier'),
  intLiteral('integer literal'),
  doubleLiteral('double literal'),
  stringLiteral('string literal'),

  // End of file
  eof('end of file'),

  // Represents an unrecognized or malformed token
  error('error');

  const TokenType(this.displayName);

  final String displayName;
}
