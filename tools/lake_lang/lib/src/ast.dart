sealed class AstNode {
  const AstNode();
}

final class Document extends AstNode {
  const Document(this.headers, this.definitions);
  final List<Header> headers;
  final List<Definition> definitions;

  @override
  String toString() => 'Document(headers: $headers, definitions: $definitions)';
}

abstract class Header extends AstNode {
  const Header();
}

final class Import extends Header {
  const Import(this.literal);

  final String literal;

  @override
  String toString() => 'Import($literal)';
}

final class Namespace extends Header {
  const Namespace(this.scope, this.identifier);

  final String scope;
  final Identifier identifier;

  @override
  String toString() => 'Namespace(scope: $scope, name: $identifier)';
}

final class Identifier extends AstNode {
  const Identifier(this.name);

  final String name;

  @override
  String toString() => 'Identifier($name)';
}

abstract class Definition extends AstNode {}
