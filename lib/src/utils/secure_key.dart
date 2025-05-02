import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Loads a secure key from the given [path] as a Base64 string, or generates and saves one if it doesn't exist.
/// Optionally, a [generateKey] function can be passed to customize key generation.
Future<List<int>> loadOrCreateSecureKey(
  String path, {
  List<int> Function()? generateKey,
}) async {
  final file = File(path);

  if (await file.exists()) {
    // Read the Base64 string from the file and decode it to bytes
    final content = await file.readAsString();
    return base64.decode(content);
  } else {
    // Generate a new key if the file doesn't exist
    final key = (generateKey ?? _defaultKeyGenerator)();
    final encoded = base64.encode(key); // Encode the key to Base64
    await file.writeAsString(encoded); // Store it as a Base64 string
    return key;
  }
}

/// Default key generator: 32 random bytes using secure random.
List<int> _defaultKeyGenerator() {
  final random = Random.secure();
  return List<int>.generate(32, (_) => random.nextInt(256));
}
