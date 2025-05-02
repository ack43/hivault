import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:hivault/hivault.dart';
import 'package:test/test.dart';

class HivaultExtended extends Hivault {
  HivaultExtended._(super.box, super.secure) : super.protected();

  static Future<HivaultExtended> init({
    required String boxName,
    required String secureBoxName,
    required List<int> secureKey,
    String hivePath = 'hive/',
  }) {
    return Hivault.init<HivaultExtended>(
      boxName: boxName,
      secureBoxName: secureBoxName,
      secureKey: secureKey,
      hivePath: hivePath,
      builder: (box, secure) => HivaultExtended._(box, secure),
    );
  }

  String get theme => box.get<String>('theme') ?? 'light';
  set theme(String value) => box.set('theme', value);

  String get language => box.get<String>('language') ?? 'ru';
  set language(String value) => box.set('language', value);

  String get secretApiToken => secure.get<String>('secretApiToken') ?? '';
  set secretApiToken(String value) => secure.set('secretApiToken', value);
}

void main() {
  group('HivaultExtended Tests', () {
    late String hivePath;
    late String secureKeyPath;
    late String boxName;
    late String secureBoxName;
    late List<int> secureKey;
    late HivaultExtended settings;

    setUp(() async {
      hivePath = 'hive/';
      secureKeyPath = '$hivePath.testSecureKey';
      boxName = 'testBox';
      secureBoxName = 'secureTestBox';

      final secureKeyFile = File(secureKeyPath);

      if (!await secureKeyFile.exists()) {
        // Generate 32 random bytes and encode as Base64
        final random = Random.secure();
        final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
        final encoded = base64.encode(keyBytes);
        await secureKeyFile.create(recursive: true);
        await secureKeyFile.writeAsString(encoded);
      }

      // Read and decode Base64-encoded key
      final encodedKey = await secureKeyFile.readAsString();
      secureKey = base64.decode(encodedKey);
    });

    test('Hivault initialization with secure key', () async {
      settings = await HivaultExtended.init(
        boxName: boxName,
        secureBoxName: secureBoxName,
        secureKey: secureKey,
        hivePath: hivePath,
      );

      expect(settings.box.box.isOpen, true);
      expect(settings.secure.box.isOpen, true);
    });

    test('Access settings like properties', () async {
      settings = await HivaultExtended.init(
        boxName: boxName,
        secureBoxName: secureBoxName,
        secureKey: secureKey,
        hivePath: hivePath,
      );
      print('secureKey.before - $secureKey');

      settings.theme = 'dark';
      expect(settings.theme, 'dark');

      print('secure box keys: ${settings.secure.box.keys.length}');
      settings.secretApiToken = '1234';
      expect(settings.secretApiToken, '1234');

      settings.language = 'fr';
      expect(settings.language, 'fr');
    });

    test('Read saved data', () async {
      settings = await HivaultExtended.init(
        boxName: boxName,
        secureBoxName: secureBoxName,
        secureKey: secureKey,
        hivePath: hivePath,
      );
      print('secureKey.after - $secureKey');

      // settings.theme = 'dark';
      expect(settings.theme, 'dark');

      print('secure box keys: ${settings.secure.box.keys.length}');
      // settings.secretApiToken = '1234';
      expect(settings.secretApiToken, '1234');

      // settings.language = 'fr';
      expect(settings.language, 'fr');
    });

    test('Read saved data after broke secureKey', () async {
      final brokenSecureKey =
          secureKey.map((byte) => (byte * byte) % 256).toList();
      settings = await HivaultExtended.init(
        boxName: boxName,
        secureBoxName: secureBoxName,
        secureKey: brokenSecureKey,
        hivePath: hivePath,
      );
      print('secureKey.broken - $brokenSecureKey');

      // settings.theme = 'dark';
      expect(settings.theme, 'dark');

      print('secure box keys: ${settings.secure.box.keys.length}');
      // settings.secretApiToken = '1234';
      expect(settings.secretApiToken, '1234');

      // settings.language = 'fr';
      expect(settings.language, 'fr');
    });

    tearDown(() async {
      await settings.close();
    });

    tearDownAll(() async {
      await settings.close();

      // final secureKeyFile = File(secureKeyPath);
      // if (await secureKeyFile.exists()) {
      //   await secureKeyFile.delete();
      // }
    });
  });
}
