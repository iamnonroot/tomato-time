import 'dart:convert';
import 'dart:developer';

import 'package:pomodoro/core/storage.dart' as storage;
import 'package:pomodoro/interface/pomodoro.dart';

String key = "pomodoro";

void endOfTime() {
  print("END OF TIME");
}

void endOfShortBreak() {}

void endOfLongBreak() {}

Future<void> start({
  required IPomodoro from,
  required int index,
  required DateTime start,
  required DateTime end,
}) async {
  try {
    Map<String, dynamic> data = {};
    data['start'] = start.millisecondsSinceEpoch;
    data['end'] = end.millisecondsSinceEpoch;
    data['from'] = from.toJSON();
    data['index'] = index;

    await storage.setItem(key, jsonEncode(data));

  } catch (e) {
    log("Start");
    log(e.toString());
  }
}

Future<void> stop() async {
  await storage.removeItem(key);
}

Future<bool> has() async {
  return await storage.getItem(key) != null;
}

Future<Map<String, dynamic>?> fetch() async {
  try {
    String? data = await storage.getItem(key);
    if (data == null)
      return null;
    else
      return jsonDecode(data);
  } catch (e) {
    log('Fetch');
    log(e.toString());
    return null;
  }
}

final String keys = 'pomodoros';

Future<bool> add(IPomodoro pomodoro) async {
  try {
    List<IPomodoro>? items = await load();
    if (items == null) items = [];
    items.add(pomodoro);
    await save(items);
    return true;
  } catch (e) {
    log("Add");
    log(e.toString());
    return false;
  }
}

Future<bool> update(IPomodoro pomodoro, {required int index}) async {
  try {
    List<IPomodoro>? items = await load();
    items![index] = pomodoro;
    await save(items);
    return true;
  } catch (e) {
    log("Update");
    log(e.toString());
    return false;
  }
}

Future<List<IPomodoro>?> load() async {
  try {
    String? value = await storage.getItem(keys);
    if (value == null)
      return null;
    else {
      List<dynamic> data = await json.decode(value);
      return List<IPomodoro>.from(data.map((item) => IPomodoro.fromJson(item)));
    }
  } catch (e) {
    log("Load");
    log(e.toString());
    return [];
  }
}

Future<bool> remove({required int index}) async {
  try {
    List<IPomodoro>? items = await load();
    items!.removeAt(index);
    await save(items);
    return true;
  } catch (e) {
    log("Remoe");
    log(e.toString());
    return false;
  }
}

Future<bool> save(List<IPomodoro> items) async {
  try {
    List<Map<String, dynamic>> values =
        List<Map<String, dynamic>>.from(items.map((e) => e.toJSON()));
    await storage.setItem(keys, jsonEncode(values));
    return true;
  } catch (e) {
    log("Save");
    log(e.toString());
    return false;
  }
}
