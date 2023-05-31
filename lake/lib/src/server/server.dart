import 'dart:io';

import '../extensions/http_request.dart';
import 'endpoint_dispatch.dart';
import 'protocol/server.dart';

final class Server implements ServerProtocol {
  Server({
    required this.port,
    required this.securityContext,
    required this.endpoints,
  });

  /// Port the server is listening on.
  final int port;

  final SecurityContext? securityContext;

  final EndpointDispatch endpoints;

  late final HttpServer _httpServer;

  @override
  Future<void> start() async {
    try {
      final server = await switch (securityContext) {
        SecurityContext() => HttpServer.bindSecure(
            InternetAddress.anyIPv6,
            port,
            securityContext!,
          ),
        null => HttpServer.bind(InternetAddress.anyIPv6, port)
      };

      _httpServer = server;
      _httpServer.autoCompress = true;

      await for (final request in _httpServer) {
        try {
          await _handleRequest(request);
        } on Exception catch (e, trace) {
          printError(error: e, trace: trace, message: '_handleRequest failed.');
        }
      }
    } on Exception catch (e, trace) {
      printError(error: e, trace: trace, message: 'Failed to bind socket.');
    }
  }

  Future<void> _handleRequest(HttpRequest request) async {
    final _ = request.requestedUri;
    const maxSize = 100;

    switch (request.headers.contentType?.mimeType) {
      case 'application/octet-stream':
        final _ = request.readBytes(maxSize: maxSize);
      case 'application/json':
        final _ = await request.readString(maxSize: maxSize);
      case null:
    }
  }

  void printError({
    required Object error,
    StackTrace? trace,
    String? message,
  }) {
    stderr
      ..writeln(
        '${DateTime.now().toUtc()} Internal server error. $message',
      )
      ..writeln('$error')
      ..writeln('$trace');
  }

  @override
  Future<void> stop() async {
    throw UnimplementedError();
  }
}
