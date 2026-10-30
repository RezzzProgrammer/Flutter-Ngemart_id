/// Domain-level error surfaced to the UI with a user-friendly message.
class AppException implements Exception {
  const AppException(this.message) : isCancelled = false;

  const AppException.cancelled()
      : message = 'Permintaan dibatalkan.',
        isCancelled = true;

  final String message;
  final bool isCancelled;

  @override
  String toString() => message;
}
