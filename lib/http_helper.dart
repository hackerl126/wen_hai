import 'dart:convert';
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:path_provider/path_provider.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:crypto/crypto.dart';
import 'dart:io';
import 'dart:math';

import 'package:wen_hai/settings_helper.dart';

class HttpHelper {
  static Future<Map<String, dynamic>> getDailySentence() async {
    DateTime dateTime = DateTime.now();
    String date = '${dateTime.year}.${dateTime.month}.${dateTime.day}';
    final response = await http.get(Uri.parse(
        'https://apiv3.shanbay.com/weapps/dailyquote/quote/?date=$date'));
    String json;
    if (response.statusCode != 200) {
      json = '{"content": "", "translation": ""}';
      Map<String, dynamic> sentences = jsonDecode(json);
      return sentences;
    }
    json = response.body;
    Map<String, dynamic> sentences = jsonDecode(json);
    return sentences;
  }

  static Future<List<MapEntry<String, String>>> searchWord(String word) async {
    Map<String, String> headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0'
    };
    Uri url = Uri.parse(
        'https://dictionary.cambridge.org/dictionary/english-chinese-simplified/$word');
    http.Response response;

    try {
      response = await http.get(url, headers: headers);
    } catch (e) {
      var exception = e.toString();
      url = Uri.parse(exception.split('uri=')[1].trim());
      response = await http.get(url, headers: headers);
    }

    List<MapEntry<String, String>> result = [];

    var document = parser.parse(response.body);
    var elements = document.querySelectorAll('*');
    for (Element element in elements) {
      if (element.className.contains('hw dhw')) {
        result.add(MapEntry('word', element.innerHtml));
        continue;
      }

      if (element.className.contains('pos dpos')) {
        result.add(MapEntry('pos', element.innerHtml));
        continue;
      }

      if (element.className.contains('def ddef_d db')) {
        result.add(MapEntry(
            'mean',
            element.innerHtml
                .replaceAll(RegExp(r"<.*?>"), "")
                .replaceAll(RegExp(r'\s+'), ' ')));
        continue;
      }

      if (element.className.contains('trans dtrans dtrans-se')) {
        result.add(MapEntry(
            'chn',
            element.innerHtml
                .replaceAll(RegExp(r"<.*?>"), "")
                .replaceAll(RegExp(r'\s+'), ' ')));
        continue;
      }

      if (element.className.contains('eg deg')) {
        result.add(MapEntry(
            'example',
            element.innerHtml
                .replaceAll(RegExp(r"<.*?>"), "")
                .replaceAll(RegExp(r'\s+'), ' ')));
        continue;
      }
    }

    if (result.isEmpty) {
      return [const MapEntry('empty', 'empty')];
    }

    return result;
  }

  static updateUrls() async {
    final directory = await getApplicationCacheDirectory();
    String path = '${directory.path}/data.txt';

    DateTime now = DateTime.now();
    String date = '${now.year}-${now.month}-${now.day}';

    File file = File(path);
    IOSink isk = file.openWrite(mode: FileMode.append);
    await isk.close();
    String fileContent = await file.readAsString();
    List<String> lines = fileContent.split('\n');
    String fileDate = lines.first;

    if (fileDate == date && lines.length > 10) {
      return;
    } else {
      IOSink isk = file.openWrite(mode: FileMode.write);
      isk.writeln(date);
      await isk.close();
    }

    String url = 'https://www.chinadaily.com.cn';
    var headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0'
    };
    var response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      var document = parser.parse(response.body);

      document.querySelectorAll('.cmLBox r-watch').forEach((element) {
        element.remove();
      });
      document.querySelectorAll('.cmLBox pc-watch').forEach((element) {
        element.remove();
      });
      document.querySelectorAll('.scrBox').forEach((element) {
        element.remove();
      });
      document.querySelectorAll('.media_partner cmL').forEach((element) {
        element.remove();
      });
      document.querySelectorAll('.cmR').forEach((element) {
        element.remove();
      });
      document.querySelectorAll('.dibu-one').forEach((element) {
        element.remove();
      });
      document.querySelectorAll('.dibu-two').forEach((element) {
        element.remove();
      });
      document.querySelectorAll('.dibu-three').forEach((element) {
        element.remove();
      });

      final links = document.querySelectorAll('a[href]');
      List<String> hrefLinks = [];

      int year = now.year;
      int month = now.month;
      String yyyymm =
          '${year.toString().padLeft(4, '0')}${month.toString().padLeft(2, '0')}';

      for (var link in links) {
        var href = link.attributes['href'];
        if (href!.startsWith('//')) {
          href = 'https:$href';
        }
        if (href.length == 73 &&
            href.startsWith('https://www.chinadaily.com.cn/a/$yyyymm')) {
          try {
            var h = await http.get(Uri.parse(href), headers: headers);
            var document = parser.parse(h.body);

            //contents
            List<Element> contents = [];
            var contentElement = document.querySelector('div#Content');
            for (var element in contentElement!.children) {
              contents.add(element);
            }

            //开始筛
            //面包屑，是不是要找的类型？是就继续  class="breadcrumb res-m"
            //var breadcrumbElement = document.querySelector('.breadcrumb res-m');

            //有没有分页？没有就继续
            var currpageElement = document.querySelector('div#div_currpage');
            if (currpageElement != null) {
              continue;
            }

            //有没有视频或者<p>？
            List<Element> result = [];
            for (var element in contents) {
              if (element.localName == 'iframe') {
                throw Exception('有视频');
              }
              if (element.localName == 'p') {
                result.add(element);
              }
            }
            if (result.isEmpty) {
              continue;
            }

            //筛完了就加进去
            hrefLinks.add(href);
          } catch (e) {
            continue;
          }
        }
      }

      hrefLinks = hrefLinks.toSet().toList();

      IOSink isk = file.openWrite(mode: FileMode.append);

      for (String link in hrefLinks) {
        isk.writeln(link);
      }
      await isk.close();
    }
  }

  static Future<String> getArticleUrl() async {
    final directory = await getApplicationCacheDirectory();
    File file = File('${directory.path}/data.txt');
    List<String> fileContent = await file.readAsLines();
    Random random = Random();
    int randomIndex = random.nextInt(fileContent.length);
    while (randomIndex == 0) {
      randomIndex = random.nextInt(fileContent.length);
    }

    String url = fileContent[randomIndex];

    return url;
  }

  static Future<Map<String, List<String>>> getArticle() async {
    String url = await getArticleUrl();
    var headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0'
    };
    final response = await http.get(Uri.parse(url), headers: headers);

    List<String> articleText = [];

    var document = parser.parse(response.body);
    document.querySelectorAll('.email').forEach((element) {
      element.remove();
    });
    final contentElement = document.querySelector('div#Content');

    for (var element in contentElement!.children) {
      if (element.localName == 'p') {
        String p = element.innerHtml;
        var unescape = HtmlUnescape();
        p = unescape.convert(p);
        p = p.replaceAll(RegExp(r"<.*?>"), '');
        if (p.length > 4) {
          articleText.add(p);
        }
      }
    }

    if (articleText.isEmpty) {
      return await getArticle();
    }

    Map<String, List<String>> result = {};

    if (await SettingsHelper.loadSettings('translation')) {
      String secretId = await SettingsHelper.loadSettings('secretId');
      String secretKey = await SettingsHelper.loadSettings('secretKey');
      List<String> translatedText = await translate(articleText, secretId, secretKey);
      //List<String> translatedText = await fakeTranslate(articleText, secretId, secretKey);
      result = {
        'articleText': articleText,
        'translatedText': translatedText
      };
    } else {
      result = {
        'articleText': articleText,
      };
    }

    return result;
  }

  static Future<List<String>> fakeTranslate(List<String> article, String secretId, String secretKey) async {
    List<String> translatedArticle = [];
    for (var i = 0; i < article.length; i++) {
      translatedArticle.add('translated');
    }

    return translatedArticle;
  }

  static Future<List<String>> translate(List<String> article, String secretId, String secretKey) async {
    List<String> translatedArticle = [];

    const String service = 'tmt';
    const String host = 'tmt.tencentcloudapi.com';
    const String endpoint = 'https://$host';
    const String region = 'ap-beijing';
    const String action = 'TextTranslateBatch';
    const String version = '2018-03-21';
    const String algorithm = 'TC3-HMAC-SHA256';
    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    String date = DateTime.now().toUtc().toString().split(' ')[0];
    Map<String, dynamic> params = {
      'SourceTextList': article,
      'Source': 'en',
      'Target': 'zh',
      'ProjectId': 0
    };

    // ************* 步骤 1：拼接规范请求串 *************
    String httpRequestMethod = 'POST';
    String canonicalUri = '/';
    String canonicalQueryString = '';
    String ct = 'application/json; charset=utf-8';
    String payload = json.encode(params);
    String canonicalHeaders =
        'content-type:$ct\nhost:$host\nx-tc-action:${action.toLowerCase()}\n';
    String signedHeaders = 'content-type;host;x-tc-action';
    String hashedRequestPayload =
        sha256.convert(utf8.encode(payload)).toString();
    String canonicalRequest =
        '$httpRequestMethod\n$canonicalUri\n$canonicalQueryString\n$canonicalHeaders\n$signedHeaders\n$hashedRequestPayload';

    // ************* 步骤 2：拼接待签名字符串 *************
    String credentialScope = '$date/$service/tc3_request';
    String hashedCanonicalRequest =
        sha256.convert(utf8.encode(canonicalRequest)).toString();
    String stringToSign =
        '$algorithm\n$timestamp\n$credentialScope\n$hashedCanonicalRequest';

    // ************* 步骤 3：计算签名 *************

    Digest secretDate =
        Hmac(sha256, utf8.encode('TC3$secretKey')).convert(utf8.encode(date));
    Digest secretService =
        Hmac(sha256, secretDate.bytes).convert(utf8.encode(service));
    Digest secretSigning =
        Hmac(sha256, secretService.bytes).convert(utf8.encode('tc3_request'));
    String signature = Hmac(sha256, secretSigning.bytes)
        .convert(utf8.encode(stringToSign))
        .toString();

    // ************* 步骤 4：拼接 Authorization *************
    String authorization =
        '$algorithm Credential=$secretId/$credentialScope, SignedHeaders=$signedHeaders, Signature=$signature';

    // ************* 步骤 5: 发起请求 *************
    Map<String, String> headers = {
      'Authorization': authorization,
      'Content-Type': 'application/json; charset=utf-8',
      'Host': host,
      'X-TC-Action': action,
      'X-TC-Timestamp': timestamp.toString(),
      'X-TC-Version': version,
      'X-TC-Region': region
    };

    var response =
        await http.post(Uri.parse(endpoint), headers: headers, body: payload);

    var responseBody = utf8.decode(latin1.encode(response.body));
    var targetTextList =
        jsonDecode(responseBody)['Response']['TargetTextList'] as List;

    translatedArticle = targetTextList.map((item) => item.toString()).toList();

    return translatedArticle;
  }
}
