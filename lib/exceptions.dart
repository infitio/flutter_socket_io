/// An Exception thrown when a null value is encountered when it should not be
class InvalidNullException implements Exception {
  /// The cause of the exception
  String cause;

  /// Construct an exception for an invalid null situation.
  /// [cause] the reason for the exception.
  InvalidNullException(this.cause);
}
