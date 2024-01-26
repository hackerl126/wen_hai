import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wen_hai/http_helper.dart';
import 'package:wen_hai/searching_route.dart';

class ReadingRoute extends StatelessWidget {
  const ReadingRoute({super.key});

  Text _buildTextButton(String text, BuildContext context) {
    List<TextSpan> textSpans = [];

    List<String> words = text.split(RegExp(r'[,\s;|]+'));

    for (String word in words) {
      TextSpan textSpan = TextSpan(
          text: '$word ',
          style: const TextStyle(fontSize: 20),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (word.isNotEmpty) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SearchingRoute(word: word)));
              }
            });
      textSpans.add(textSpan);
    }
    textSpans.add(const TextSpan(text: '\n', style: TextStyle(fontSize: 20)));

    TextSpan spans = TextSpan(children: textSpans);
    return Text.rich(spans);
  }

  ListView _buildResult(Map<String, List<String>> result, BuildContext context) {
    List<Widget> widgets = [];

    List<String> articleText = result['articleText']!;
    List<String>? translatedText = result['translatedText'];

    if (translatedText== null) {
      for (int i = 0; i < articleText.length; i++) {
        widgets.add(_buildTextButton(articleText[i], context));
      }
    } else {
      for (int i = 0; i < articleText.length; i++) {
        widgets.add(_buildTextButton(articleText[i], context));
        widgets.add(
            Text('${translatedText[i]}\n', style: const TextStyle(fontSize: 20)));
      }
    }

    ElevatedButton nextArticle = ElevatedButton(
      child: const Text('换一篇'),
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ReadingRoute()),
        );
      },
    );

    widgets.add(nextArticle);
    widgets.add(const SizedBox(height: 25));

    ListView listView = ListView(children: widgets);
    return listView;
  }

  Future<Map<String, List<String>>> _init() async {
    return await HttpHelper.getArticle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('阅读'),
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
                child: _buildResult(
                    snapshot.data as Map<String, List<String>>, context),
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
