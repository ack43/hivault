import 'dart:io';
import 'package:hivault/hivault.dart';
import 'package:test/test.dart';

void main() {
  group('Hivault Tests', () {
    late String hivePath;
    late String secureKeyPath;
    late String boxName;
    late String secureBoxName;
    late Hivault hivault;

    setUp(() {
      // Set up paths and names for boxes and secure key file
      hivePath = 'hive/';
      secureKeyPath = '$hivePath.testSecureKey';
      boxName = 'testBox';
      secureBoxName = 'secureTestBox';
    });

    test('Hivault initialization with secure key', () async {
      final secureKey = await loadOrCreateSecureKey(secureKeyPath);

      // Initialize Hivault with the secure key and paths
      hivault = await Hivault.init(
        boxName: boxName,
        secureBoxName: secureBoxName,
        secureKey: secureKey,
        hivePath: hivePath,
      );

      // Assert that boxes are correctly initialized
      expect(hivault.box.box.isOpen, true);
      expect(hivault.secure.box.isOpen, true);
    });

    test('Store and retrieve value from unsecure box', () async {
      final secureKey = await loadOrCreateSecureKey(secureKeyPath);

      // Initialize Hivault with the secure key and paths
      hivault = await Hivault.init(
        boxName: boxName,
        secureBoxName: secureBoxName,
        secureKey: secureKey,
        hivePath: hivePath,
      );

      // Store a value in the unsecure box
      await hivault.box.set('key', 'value');

      // Retrieve the value from the unsecure box
      final storedValue = hivault.box.get<String>('key');
      expect(storedValue, 'value');
    });

    test('Verify secure key functionality', () async {
      final secureKey = await loadOrCreateSecureKey(secureKeyPath);

      // Initialize Hivault with the secure key and paths
      hivault = await Hivault.init(
        boxName: boxName,
        secureBoxName: secureBoxName,
        secureKey: secureKey,
        hivePath: hivePath,
      );

      // Check if the secure key can decrypt the box
      final isKeyValid = await hivault.verifySecureKey();
      expect(isKeyValid, true);
    });

    tearDown(() async {
      // Clean up by closing the Hivault boxes
      await hivault.close();

      // Optionally, delete the secure key file after tests
      final secureKeyFile = File(secureKeyPath);
      if (await secureKeyFile.exists()) {
        await secureKeyFile.delete();
      }
    });
  });
}
