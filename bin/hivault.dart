import 'dart:math';
import 'package:hivault/hivault.dart';

Future<void> main() async {
  final secureKey = await loadOrCreateSecureKey('hive/.secureKey');
  // // or
  // final secureKey = await loadOrCreateSecureKey(
  //   '.secureKey',
  //   generateKey: () => List<int>.filled(32, 42), // Example: constant key (for testing)
  // );

  // Initialize Hivault
  final hivault = await Hivault.init(
    boxName: 'settings',
    secureBoxName: 'secure_settings',
    secureKey: secureKey,
  );
  if (await hivault.verifySecureKey()) {
    print('Secure key is valid!');
  } else {
    print('Secure key is invalid or corrupted!');
  }

  // // Unsecure usage
  // await hivault.box.set('language', 'en');
  final lang = hivault.box.get<String>('language');
  print('Language: $lang');

  // // Secure usage
  // await hivault.secure.set('token', 'abc123secure');
  final token = hivault.secure.get<String>('token');
  print('Token: $token');

  hivault.close();
}
