// ignore_for_file: avoid_print

class ExecutionTimer {
  final Map<String, int> _stepTimings = {};
  final Stopwatch _overallWatch = Stopwatch();

  /// Starts the overall timer for the entire process.
  void start() {
    _overallWatch.start();
  }

  /// Stops the overall timer.
  void stop() {
    _overallWatch.stop();
  }

  /// Resets the timer and clears all recorded step timings.
  void reset() {
    _stepTimings.clear();
    _overallWatch.reset();
  }

  /// Executes an operation and measures its time, storing it by description.
  /// Prints the individual step time.
  ///
  /// Returns the elapsed microseconds for the operation.
  int measure(String description, void Function() operation) {
    final watch = Stopwatch()..start();
    operation();
    watch.stop();
    final elapsed = watch.elapsedMicroseconds;
    _stepTimings[description] = elapsed;

    return elapsed;
  }

  /// Prints a summary of all measured step timings and the total overall time.
  void printSummary() {
    print('--- Total Timing Summary ---');
    _stepTimings.forEach(printElapsedTime);

    printElapsedTime(
      'Overall execution time',
      _overallWatch.elapsedMicroseconds,
    );

    print('----------------------------');
  }

  /// Prints the elapsed time for a specific step.
  /// If the elapsed time is greater than 1000 microseconds, it is printed in
  /// milliseconds; otherwise, it is printed in microseconds.
  void printElapsedTime(String description, int elapsedMicroseconds) {
    final elapsed = elapsedMicroseconds > 1000
        ? '${elapsedMicroseconds / 1000} ms'
        : '$elapsedMicroseconds μs';
    print('$description: $elapsed');
  }
}
