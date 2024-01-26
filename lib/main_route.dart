import 'package:flutter/material.dart';
import 'package:wen_hai/http_helper.dart';
import 'package:wen_hai/reading_route.dart';
import 'package:wen_hai/settings_route.dart';
import 'package:wen_hai/words_route.dart';

class MainRoute extends StatelessWidget {
  const MainRoute({super.key});

  Container _buildResult(Map<String, dynamic> sentences, BuildContext context) {
    String eng = sentences['content'];
    String chn = sentences['translation'];
    return Container(
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.only(left: 20, top: 30, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            eng,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 5),
          Text(
            chn,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            child: const Text('开始阅读'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReadingRoute()),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _init(BuildContext context) async {
    await HttpHelper.updateUrls();
    return await HttpHelper.getDailySentence();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('文海'),
        actions: [IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SettingsRoute()),
              );
            },
            icon: const Icon(Icons.settings))],
      ),
      body: FutureBuilder(
        future: _init(context),
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
              return _buildResult(
                  snapshot.data as Map<String, dynamic>, context);
            case ConnectionState.none:
            default:
              return const Center(
                child: Text('请求失败！'),
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const WordsRoute()),
          );
        },
        tooltip: '生词表',
        child: const Icon(
          Icons.view_headline_rounded,
          size: 30,
        ),
      ),
    );
  }
}
