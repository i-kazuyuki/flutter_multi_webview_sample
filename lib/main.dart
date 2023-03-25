import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _items = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"];

  void _addItem() {
    var newItemList = [..._items, _generateString()];
    setState(() {
      _items = newItemList;
    });
  }

  void _removeItem(int index) {
    var tmp = _items;
    tmp.removeAt(index);
    setState(() {
      _items = tmp;
    });
  }

  String _generateString() {
    final Random random = Random();
    final int length = random.nextInt(10) + 1;
    return String.fromCharCodes(
        List.generate(length, (index) => random.nextInt(26) + 65));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              ListTile(
                title: Text(_items[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeItem(index),
                ),
              ),
              SizedBox(
                width: 500,
                height: 150,
                child: Card(
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(url: Uri.parse("https://flutter.dev/"))
                  )
                )
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
