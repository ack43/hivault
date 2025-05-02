import 'package:hive_ce/hive.dart';

class HivaultBox {
  final Box box;

  HivaultBox._(this.box);

  static Future<HivaultBox> open(
    String name, {
    List<int>? encryptionKey,
  }) async {
    final box = await Hive.openBox(
      name,
      encryptionCipher:
          encryptionKey != null ? HiveAesCipher(encryptionKey) : null,
    );
    return HivaultBox._(box);
  }

  T? get<T>(String key) => box.get(key);

  Future<void> set<T>(String key, T value) => box.put(key, value);

  bool containsKey(String key) => box.containsKey(key);

  Future<void> remove(String key) => box.delete(key);
}
