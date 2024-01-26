import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SettingsHelper {
  //操作getApplicationSupportDirectory()下settings.json文件
  static initSettings() async {
    Directory directory = await getApplicationSupportDirectory();
    File settingsFile  =File('${directory.path}/settings.json');

    Map<String, dynamic> settings = {
      'translation': 'disabled',
      'secretId': '',
      'secretKey': ''
    };

    await settingsFile.writeAsString(json.encode(settings));
  }

  static saveSettings(Map<String, dynamic> settings) async {
    Directory directory = await getApplicationSupportDirectory();
    File settingsFile  =File('${directory.path}/settings.json');
    IOSink isk = settingsFile.openWrite(mode: FileMode.append);
    await isk.close();

    Map<String, dynamic> settingsMap = {};
    try {
      String fileString = await settingsFile.readAsString();
      settingsMap = json.decode(fileString);
    } catch (e) {
      await initSettings();
      String fileString = await settingsFile.readAsString();
      settingsMap = json.decode(fileString);
    }

    settingsMap.addAll(settings);

    String settingsString = json.encode(settingsMap);
    await settingsFile.writeAsString(settingsString);
  }

  static loadSettings(String key) async {
    Directory directory = await getApplicationSupportDirectory();
    File settingsFile  =File('${directory.path}/settings.json');
    IOSink isk = settingsFile.openWrite(mode: FileMode.append);
    await isk.close();

    Map<String, dynamic> settingsMap = {};
    try {
      String fileString = await settingsFile.readAsString();
      settingsMap = json.decode(fileString);
    } catch (e) {
      await initSettings();
      String fileString = await settingsFile.readAsString();
      settingsMap = json.decode(fileString);
    }

    return settingsMap[key];
  }
}
