import 'package:flutter/material.dart';
import 'package:wen_hai/searching_route.dart';
import 'package:wen_hai/words_helper.dart';

class WordsRoute extends StatefulWidget {
  const WordsRoute({super.key});

  @override
  State<WordsRoute> createState() => _WordsRouteState();
}

class _WordsRouteState extends State<WordsRoute> {
  ListView _buildResult(List<String> words, BuildContext context) {
    return ListView.builder(
      itemCount: words.length,
      itemBuilder: (context, index) {
        return Column(children: [
          ListTile(
            title: Text(
              words[index],
              style: const TextStyle(fontSize: 22),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_rounded),
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text('删除单词'),
                          content: Text('确定要删除\'${words[index]}\'吗？'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('取消')),
                            TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await WordsHelper.removeWord(words[index]);
                                  setState(() {});
                                },
                                child: const Text('确定'))
                          ],
                        ));
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SearchingRoute(word: words[index])),
              );
            },
          ),
          Divider(
            color: Colors.grey[300],
            height: 0,
          )
        ]);
      },
    );
  }

  Future<List<String>> _init() async {
    return await WordsHelper.getWords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('生词表'),
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
              return _buildResult(snapshot.data as List<String>, context);
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
