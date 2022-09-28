import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:markdown_widget/markdown_widget.dart";

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Flutter Demo",
        theme: ThemeData(primarySwatch: Colors.amber),
        home: const Demo());
  }
}

class Demo extends StatefulWidget {
  const Demo({Key? key}) : super(key: key);

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  String _data = "";

  @override
  void initState() {
    super.initState();

    rootBundle.loadString("assets/toannm (5).md").then((String value) {
      setState(() {
        _data = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("place")),
        body: Center(
            child:
                SizedBox(child: MarkdownWidget(data: _data, lineNumber: 5))));
  }
}
