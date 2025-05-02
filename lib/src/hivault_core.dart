import 'package:hive_ce/hive.dart';

import 'hivault_box.dart';

const _sentinelKey = '__secure_box_check__';
const _sentinelValue = 'ok';

class Hivault {
  final HivaultBox box;
  final HivaultBox secure;

  Hivault._(this.box, this.secure);

  static Future<Hivault> init({
    required String boxName,
    required String secureBoxName,
    required List<int> secureKey,
    String hivePath = 'hive/',
  }) async {
    Hive.init(hivePath);

    final unsecureBox = await HivaultBox.open(boxName);
    final secureBox = await HivaultBox.open(
      secureBoxName,
      encryptionKey: secureKey,
    );

    // Ensure the sentinel exists
    final sentinel = secureBox.get<String>(_sentinelKey);
    if (sentinel != _sentinelValue) {
      await secureBox.set(_sentinelKey, _sentinelValue);
    }

    return Hivault._(unsecureBox, secureBox);
  }

  /// Closes all boxes managed by this instance.
  Future<void> close() async {
    await box.box.close();
    await secure.box.close();
  }

  /// Verifies if the secure key used can successfully decrypt the secure box.
  /// Returns true if the sentinel is correct, false otherwise.
  Future<bool> verifySecureKey() async {
    try {
      final value = secure.get<String>(_sentinelKey);
      return value == _sentinelValue;
    } catch (_) {
      return false;
    }
  }
}
