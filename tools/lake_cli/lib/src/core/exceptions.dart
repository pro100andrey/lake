import 'dart:convert';

import 'package:stack_trace/stack_trace.dart';

/// Base class for all exceptions thrown by the Lake CLI.
/// This class extends the [Exception] class and provides additional
/// functionality for handling exceptions in the Lake CLI.
/// It includes a message, a cause, and a stack trace.
/// The [CliException] class is used to represent exceptions that occur
/// during the execution of the Lake CLI.
class CliException implements Exception {
  /// Creates a new [CliException] with the given message and optional
  /// cause. If no cause is provided, the stack trace will be set to the current
  /// stack trace.
  CliException(this.message, [Trace? stackTrace])
    : cause = null,
      stackTrace = stackTrace ?? Trace.current(2);

  /// Creates a new [CliException] with the given message and cause.
  /// The stack trace will be set to the current stack trace.
  CliException.from(this.cause, this.stackTrace)
    : message = cause.toString();

  /// Creates a new [CliException] with the given cause.
  /// The message will be set to the string representation of the cause.
  /// The stack trace will be set to the current stack trace.
  /// This constructor is used when the cause is an exception.
  CliException.fromException(this.cause)
    : message = cause.toString(),
      stackTrace = Trace.current(2);

  CliException._(this.message, this.cause, [Trace? stackTrace])
    : stackTrace = stackTrace ?? Trace.current(2);

  /// Creates a new [CliException] from a JSON string.
  /// The JSON string should contain the following fields:
  /// - `message`: The error message.
  /// - `cause`: The cause of the error (optional).
  /// - `stackTrace`: The stack trace (optional).
  factory CliException.fromJson(String json) {
    final Map<String, dynamic> data = jsonDecode(json);

    final message = data['message'] as String;
    final cause = data['cause'] as String?;
    final stackTrace = Trace.parse(data['stackTrace'] as String);

    return CliException._(message, cause, stackTrace);
  }

  final String message;
  final Object? cause;
  final Trace stackTrace;

  @override
  String toString() => message;

  /// Converts the [CliException] to a JSON string.
  /// The JSON string contains the following fields:
  /// - `message`: The error message.
  /// - `cause`: The cause of the error (optional).
  /// - `stackTrace`: The stack trace (optional).
  Map<String, dynamic> toJson() => {
    'message': message,
    'cause': cause?.toString(),
    'stackTrace': stackTrace.toString(),
  };

  /// Converts the [CliException] to a JSON string.
  /// The JSON string contains the following fields:
  /// - `message`: The error message.
  /// - `cause`: The cause of the error (optional).
  /// - `stackTrace`: The stack trace (optional).
  String toJsonString() => jsonEncode(toJson());
}
