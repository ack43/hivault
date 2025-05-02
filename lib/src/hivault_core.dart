import 'package:hive_ce/hive.dart';
import 'hivault_box.dart';

const _sentinelKey = '__secure_box_check__';
const _sentinelValue = 'ok';

class Hivault {
  final HivaultBox box;
  final HivaultBox secure;

  // Protected-like constructor (internal use only)
  // Hivault._(this.box, this.secure);
  Hivault.protected(this.box, this.secure);

  static Future<T> init<T extends Hivault>({
    required String boxName,
    required String secureBoxName,
    required List<int> secureKey,
    String hivePath = 'hive/',
    T Function(HivaultBox box, HivaultBox secure)? builder,
  }) async {
    Hive.init(hivePath);

    final unsecureBox = await HivaultBox.open(boxName);
    final secureBox = await HivaultBox.open(
      secureBoxName,
      encryptionKey: secureKey,
    );

    final sentinel = secureBox.get<String>(_sentinelKey);
    if (sentinel != _sentinelValue) {
      await secureBox.set(_sentinelKey, _sentinelValue);
    }

    if (builder != null) {
      return builder(unsecureBox, secureBox);
    }

    return Hivault.protected(unsecureBox, secureBox) as T;
  }

  Future<void> close() async {
    await box.box.close();
    await secure.box.close();
  }

  Future<bool> verifySecureKey() async {
    try {
      final value = secure.get<String>(_sentinelKey);
      return value == _sentinelValue;
    } catch (_) {
      return false;
    }
  }
}
