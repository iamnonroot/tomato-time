import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> setItem(String key, String value) async {
  await FlutterSecureStorage().write(key: key, value: value);
}

Future<String?> getItem(String key) async {
  return await FlutterSecureStorage().read(key: key);
}

Future<void> removeItem(String key) async {
  await FlutterSecureStorage().delete(key: key);
}
