import 'dart:io';
import 'package:path_provider/path_provider.dart';

class WordsHelper {
  static addWord(String word) async {
    final directory = await getApplicationSupportDirectory();
    File file = File('${directory.path}/words.txt');
    IOSink isk = file.openWrite(mode: FileMode.append);
    await isk.close();
    List<String> words = await file.readAsLines();
    words.add(word);
    words = words.toSet().toList();
    await file.writeAsString(words.join('\n'));
  }

  static removeWord(String word) async {
    final directory = await getApplicationSupportDirectory();
    File file = File('${directory.path}/words.txt');
    IOSink isk = file.openWrite(mode: FileMode.append);
    await isk.close();
    List<String> words = await file.readAsLines();
    words.remove(word);
    words = words.toSet().toList();
    await file.writeAsString(words.join('\n'), flush: true);
  }

  static Future<bool> containsWord(String word) async {
    final directory = await getApplicationSupportDirectory();
    File file = File('${directory.path}/words.txt');
    IOSink isk = file.openWrite(mode: FileMode.append);
    await isk.close();
    List<String> words = await file.readAsLines();
    return words.contains(word);
  }

  static Future<List<String>> getWords() async {
    final directory = await getApplicationSupportDirectory();
    File file = File('${directory.path}/words.txt');
    IOSink isk = file.openWrite(mode: FileMode.append);
    await isk.close();
    List<String> words = await file.readAsLines();
    return words;
  }
}
