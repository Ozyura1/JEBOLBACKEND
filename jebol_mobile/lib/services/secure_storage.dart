// Conditional export: default to IO implementation; use web implementation when compiling for the web.
export 'secure_storage_io.dart' if (dart.library.html) 'secure_storage_web.dart';

// Both files export a `SecureStorage` class with the same API.
