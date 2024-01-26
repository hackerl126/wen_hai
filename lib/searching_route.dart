import 'package:flutter/material.dart';
import 'package:wen_hai/http_helper.dart';
import 'package:wen_hai/words_helper.dart';

class SearchingRoute extends StatefulWidget {
  final String word;

  const SearchingRoute({super.key, required this.word});

  @override
  State<SearchingRoute> createState() => _SearchingState(word: word);
}

class _SearchingState extends State<SearchingRoute> {
  final String word;

  _SearchingState({required this.word});

  ListView _buildResult(List<MapEntry<String, String>> result) {
    List<Widget> widgets = [];

    for (MapEntry<String, String> entry in result) {
      switch (entry.key) {
        case 'empty':
          widgets.clear();
          widgets.add(const Text(
            '未找到要查的词',
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          ));
          break;
        case 'word':
          String word = entry.value;
          widgets.add(Text(word,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 50)));
          break;
        case 'pos':
          String pos = entry.value;
          widgets.add(Text(pos,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              style:
                  const TextStyle(fontSize: 20, fontStyle: FontStyle.italic)));
          break;
        case 'mean':
          String mean = entry.value;
          widgets.add(Text(mean,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)));
          break;
        case 'chn':
          String chn = entry.value;
          widgets.add(Text('$chn\n',
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              style: const TextStyle(
                  fontSize: 20, color: Color.fromARGB(255, 18, 134, 233))));
          break;
        case 'example':
          String example = entry.value;
          widgets.add(Text(example,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              style:
                  const TextStyle(fontSize: 20, fontStyle: FontStyle.italic)));
          break;
        case 'contains':
          String contains = entry.value;
          String word = result.first.value;
          if (contains == 'false') {
            try {
              ElevatedButton addWordButton = ElevatedButton(
                onPressed: () {
                  WordsHelper.addWord(word);
                  setState(() {});
                },
                child: Text('加入生词表：$word'),
              );
              widgets.add(addWordButton);
              widgets.add(const SizedBox(height: 20));
            } catch (e) {}
          } else {
            widgets.add(Text('已加入生词表：$word', textAlign: TextAlign.center));
            widgets.add(const SizedBox(height: 20));
          }
          break;
        default:
      }
    }

    ListView listView = ListView(children: widgets);
    return listView;
  }

  Future<List<MapEntry<String, String>>> _init() async {
    var result =  await HttpHelper.searchWord(word);
    if (result.first.key != 'empty') {
      String realWord = result.first.value;
      if (await WordsHelper.containsWord(realWord)) {
        result.add(const MapEntry('contains', 'true'));
      } else {
        result.add(const MapEntry('contains', 'false'));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('查词'),
      ),
      body: FutureBuilder(
        future: _init(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('发生错误: ${snapshot.error}'));
          }

          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.active:
            case ConnectionState.done:
              return Container(
                alignment: Alignment.topCenter,
                margin: const EdgeInsets.only(left: 15, right: 15),
                child: _buildResult(snapshot.data as List<MapEntry<String, String>>),
              );
            case ConnectionState.none:
            default:
              return const Center(
                child: Text('请求失败！'),
              );
          }
        },
      ),
    );
  }
}
