import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;

import 'config/html_support.dart';
import 'config/style_config.dart';
import 'config/widget_config.dart';
import 'markdown_helper.dart';
import 'markdown_toc.dart';

///use [MarkdownGenerator] to transform markdown data to [Widget] list, so you can render it by any type of [ListView]
class MarkdownGenerator {
  MarkdownGenerator(
      {required String data,
      WidgetConfig? widgetConfig,
      StyleConfig? styleConfig,
      EdgeInsetsGeometry? childMargin,
      String? buttonLabel}) {
    final m.Document document = m.Document(
        extensionSet: m.ExtensionSet.gitHubFlavored,
        encodeHtml: false,
        inlineSyntaxes: [TaskListSyntax()]);
    final List<String> lines = data.split(RegExp(r'(\r?\n)|(\r?\t)|(\r)'));
    List<m.Node> nodes = document.parseLines(lines);
    _tocList = LinkedHashMap();
    _helper = MarkdownHelper(wConfig: widgetConfig);
    _widgets = [];

    for (int i = 0; i < nodes.length; ++i) {
      if (i == nodes.length - 1) {
        m.Node node = nodes[i];

        if (buttonLabel != null) {
          if (node is m.Text) {
            _widgets!.add(_generatorWidget(
                m.Element(
                    p,
                    List<m.Node>.from([node])
                      ..addAll([
                        m.Element(button, [m.Text(buttonLabel)])
                      ])),
                childMargin));
          } else {
            _widgets!.add(_generatorWidget(
                m.Element(
                    (node as m.Element).tag,
                    List<m.Node>.from(node.children!)
                      ..addAll([
                        m.Element(button, [m.Text(buttonLabel)])
                      ])),
                childMargin));
          }
        } else {
          _widgets!.add(_generatorWidget(nodes[i], childMargin));
        }
      } else {
        _widgets!.add(_generatorWidget(nodes[i], childMargin));
      }
    }
  }

  List<m.Node> getNodes(m.Text textNode) {
    List<m.Node> nodes = <m.Node>[];

    RegExp regex = RegExp(
        r"([a-zA-Z0-9._]+\@[a-zA-Z0-9]+(\.[a-zA-Z]+){1,2}|[0-9]((\s{0,1}[0-9]){9}|(\.{0,1}[0-9]){9}))");
    RegExp emailRegex =
        RegExp(r"[a-zA-Z0-9._]+\@[a-zA-Z0-9]+(\.[a-zA-Z]+){1,2}");

    int index = 0;

    regex.allMatches(textNode.text).forEach((RegExpMatch regExpMatch) {
      m.Node node = m.Element("", []);

      bool isCorrect = false;

      if (regExpMatch.start == 0) {
        if (regExpMatch.end == textNode.text.length) {
          isCorrect = true;
        } else {
          if (textNode.text[regExpMatch.end] == " ") {
            isCorrect = true;
          }
        }
      } else {
        if (regExpMatch.end == textNode.text.length) {
          if (textNode.text[regExpMatch.start - 1] == "") {
            isCorrect = true;
          }
        } else {
          if (textNode.text[regExpMatch.start - 1] == " " &&
              textNode.text[regExpMatch.end] == " ") {
            isCorrect = true;
          }
        }
      }

      if (isCorrect) {
        if (index != regExpMatch.start) {
          node = m.Text(textNode.text.substring(index, regExpMatch.start));

          nodes.add(node);
        }

        m.Element matchedElement = m.Element(a, [m.Text(regExpMatch[0]!)]);

        if (emailRegex.hasMatch(regExpMatch[0]!)) {
          matchedElement.attributes["href"] =
              "mailto:" + regExpMatch[0]!.replaceAll(" ", "");
        } else {
          matchedElement.attributes["href"] =
              "tel:" + regExpMatch[0]!.replaceAll(" ", "");
        }

        nodes.add(matchedElement);
      } else {
        node = m.Text(textNode.text.substring(index, regExpMatch.end));

        nodes.add(node);
      }

      index = regExpMatch.end;
    });

    nodes.add(m.Text(textNode.text.substring(index)));

    return nodes;
  }

  List<Widget>? _widgets;
  LinkedHashMap<int, Toc>? _tocList;
  late MarkdownHelper _helper;

  List<Widget>? get widgets => _widgets;

  LinkedHashMap<int, Toc>? get tocList => _tocList;

  ///generator all widget from markdown data by this method
  Widget _generatorWidget(m.Node node, EdgeInsetsGeometry? childMargin) {
    if (node is m.Text) return _helper.getPWidget(m.Element(p, [node]));
    final tag = (node as m.Element).tag;
    Widget? result;
    switch (tag) {
      case h1:
        _tocList![_widgets!.length] = Toc(
            node.textContent.replaceAll(htmlRep, ''),
            tag,
            _widgets!.length,
            _tocList!.length,
            0);
        result = _helper.getTitleWidget(node, h1);
        break;
      case h2:
        _tocList![_widgets!.length] = Toc(
            node.textContent.replaceAll(htmlRep, ''),
            tag,
            _widgets!.length,
            _tocList!.length,
            1);
        result = _helper.getTitleWidget(node, h2);
        break;
      case h3:
        _tocList![_widgets!.length] = Toc(
            node.textContent.replaceAll(htmlRep, ''),
            tag,
            _widgets!.length,
            _tocList!.length,
            2);
        result = _helper.getTitleWidget(node, h3);
        break;
      case h4:
        _tocList![_widgets!.length] = Toc(
            node.textContent.replaceAll(htmlRep, ''),
            tag,
            _widgets!.length,
            _tocList!.length,
            3);
        result = _helper.getTitleWidget(node, h4);
        break;
      case h5:
        _tocList![_widgets!.length] = Toc(
            node.textContent.replaceAll(htmlRep, ''),
            tag,
            _widgets!.length,
            _tocList!.length,
            4);
        result = _helper.getTitleWidget(node, h5);
        break;
      case h6:
        _tocList![_widgets!.length] = Toc(
            node.textContent.replaceAll(htmlRep, ''),
            tag,
            _widgets!.length,
            _tocList!.length,
            5);
        result = _helper.getTitleWidget(node, h6);
        break;
      case p:
        List<m.Node> nodeList = <m.Node>[];

        node.children!.forEach((m.Node value) {
          if (value is m.Text) {
            nodeList.addAll(getNodes(value));
          } else {
            nodeList.add(value);
          }
        });

        result = _helper.getPWidget(m.Element(p, nodeList));
        break;
      case pre:
        result = _helper.getPreWidget(node);
        break;
      case ul:
        result = _helper.getUlWidget(node, 0);
        break;
      case ol:
        result = _helper.getOlWidget(node, 0);
        break;
      case hr:
        result = _helper.getHrWidget(node);
        break;
      case table:
        result = _helper.getTableWidget(node);
        break;
      case blockquote:
        result = _helper.getBlockQuote(node);
        break;
    }
    if (result == null)
      print('tag:$tag not catched! --- Text:${node.textContent} \n'
          'report bug:https://github.com/asjqkkkk/markdown_widget/issues/new/choose');
    return Container(
      child: result ?? Container(),
      margin: childMargin ??
          (result == null ? null : EdgeInsets.only(top: 5, bottom: 5)),
    );
  }

  void clear() {
    _tocList!.clear();
    _widgets!.clear();
  }
}

///Thanks for https://github.com/flutter/flutter_markdown/blob/4cc79569f6c0f150fc4e9496f594d1bfb3a3ff54/lib/src/widget.dart
class TaskListSyntax extends m.InlineSyntax {
  static final String _pattern = r'^ *\[([ xX])\] +';

  TaskListSyntax() : super(_pattern);

  @override
  bool onMatch(m.InlineParser parser, Match match) {
    m.Element el = m.Element.withTag('input');
    el.attributes['type'] = 'checkbox';
    el.attributes['disabled'] = 'true';
    el.attributes['checked'] = '${match[1]!.trim().isNotEmpty}';
    parser.addNode(el);
    return true;
  }
}
