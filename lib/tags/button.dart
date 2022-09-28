import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';

import "../config/method_config.dart";

///Tag:  code
InlineSpan getButtonSpan(m.Element node) =>
    WidgetSpan(child: ButtonWidget(node: node));

///the code widget
class ButtonWidget extends StatelessWidget {
  final m.Element node;

  const ButtonWidget({
    Key? key,
    required this.node,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: PWidget(
            parentNode: node,
            children: node.children,
            textStyle: defaultLinkStyle,
            selectable: false),
        onTap: MethodConfig().customerMethod);
  }
}
