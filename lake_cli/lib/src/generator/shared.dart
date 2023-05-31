/// The import url of the main serverpod package.
String serverpodUrl({required bool serverCode}) => serverCode
    ? 'package:serverpod/serverpod.dart'
    : 'package:serverpod_client/serverpod_client.dart';

/// The import url of the serverpod protocol.
String serverpodProtocolUrl({required bool serverCode}) => serverCode
    ? 'package:serverpod/protocol.dart'
    : 'package:serverpod_client/serverpod_client.dart';
