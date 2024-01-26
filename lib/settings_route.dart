import 'package:flutter/material.dart';
import 'package:wen_hai/http_helper.dart';
import 'package:wen_hai/settings_helper.dart';

class SettingsRoute extends StatelessWidget {
  const SettingsRoute({super.key});

  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, Function>> actions = _getActions(context);

    return Scaffold(
        appBar: AppBar(title: const Text('设置')),
        body: ListView.separated(
            itemCount: actions.length,
            itemBuilder: (context, index) {
              return ListTile(
                  title: Text(actions[index].key),
                  trailing: const Icon(Icons.keyboard_arrow_right_outlined),
                  onTap: () {
                    actions[index].value();
                  });
            },
            separatorBuilder: (context, index) => const Divider(height: 0)));
  }

  List<MapEntry<String, Function>> _getActions(BuildContext context) {
    List<MapEntry<String, Function>> actions = [];

    actions.add(MapEntry('翻译', () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const _TranslationSettings()));
    }));
    // ...添加其他设置选项

    return actions;
  }
}

class _TranslationSettings extends StatefulWidget {
  const _TranslationSettings({super.key});

  @override
  State<_TranslationSettings> createState() => _TranslationSettingsState();
}

class _TranslationSettingsState extends State<_TranslationSettings> {
  bool light = false;
  TextEditingController _idController = TextEditingController();
  TextEditingController _keyController = TextEditingController();
  String secretId = '';
  String secretKey = '';

  initTranslationSettings() async {
    light = await SettingsHelper.loadSettings('translation');
    secretId = await SettingsHelper.loadSettings('secretId');
    secretKey = await SettingsHelper.loadSettings('secretKey');
    _idController = TextEditingController(
        text: secretId);
    _keyController = TextEditingController(
        text: secretKey);
    setState(() {
    });
  }

  @override
  void initState() {
    super.initState();
    initTranslationSettings();
  }

  @override
  void dispose() {
    _idController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('翻译')),
        body: ListView(
          children: [
            ListTile(
              title: const Text('文章翻译'),
              trailing: Switch(
                value: light,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (bool value) async {
                  try {
                    await HttpHelper.translate(
                        ['article'], secretId, secretKey);
                    Map<String, dynamic> translationSettings = {
                      'translation': value ? true : false,
                      'secretId': secretId,
                      'secretKey': secretKey
                    };
                    await SettingsHelper.saveSettings(translationSettings);

                    setState(() {
                      light = value;
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('secretId或secretKey设置不正确！'),
                        duration: Duration(milliseconds: 1000),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.only(left: 16, right:16),
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'SecretId',
                ),
                controller: _idController,
                onChanged: (String value) {
                  setState(() {
                    light = false;
                    secretId = _idController.value.text;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16),
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'SecretKey',
                ),
                controller: _keyController,
                onChanged: (String value) {
                  setState(() {
                    light = false;
                    secretKey = _keyController.value.text;
                  });
                },
              ),
            ),
          ],
        ));
  }
}
