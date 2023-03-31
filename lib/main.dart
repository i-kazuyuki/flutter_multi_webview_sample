import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    // Refetch once every 5 seconds.
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      await refetch();
    });

    super.initState();
  }

  Future<void> refetch() async {
    setState(() {
      // Add one item every five times. Otherwise, no item changes.
      if (_refetchCount % 5 == 0) {
        _items = [generateNewData(), ..._items];
        // If you want to validate changes to an item, comment out the above and comment in the below.
        // _items[0].title = _generateString();
      } else {
        _items = [..._items];
      }
      _refetchCount ++;
    });
  }

  int _refetchCount = 0;

  Item generateNewData() {
    return Item(id: UniqueKey(), title: _generateString());
  }

  List<Item> _items = [
    Item(id: UniqueKey(), title: "a"),
    Item(id: UniqueKey(), title: "b"),
    Item(id: UniqueKey(), title: "c"),
    Item(id: UniqueKey(), title: "d"),
    Item(id: UniqueKey(), title: "e"),
  ];

  void _addItem() {
    setState(() {
      _items = [
        Item(id: UniqueKey(), title: _generateString()),
        ..._items,
      ];
    });
  }

  void _removeItem(Key key) {
    setState(() {
      final index = _items.indexWhere((item) => item.id == key);
      _items[index] = Item(id: _items[index].id, title: '');
    });
  }

  String _generateString() {
    final Random random = Random();
    final int length = random.nextInt(10) + 1;
    return String.fromCharCodes(
        List.generate(length, (index) => random.nextInt(26) + 65));
  }

  int? _findChildIndexCallback(Key key) {
    for (int index = 0; index < _items.length; index++) {
      final Item item = _items[index];
      if (item.id == key) {
        return index;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        findChildIndexCallback: (Key key) => _findChildIndexCallback(key),
        cacheExtent: double.maxFinite,
        itemBuilder: (BuildContext context, int index) {
          if (_items[index].title == '') {
            return const SizedBox.shrink();
          }
          return ItemWidget(
            item: _items[index],
            onTap: () => _removeItem(_items[index].id),
            key: _items[index].id,
            index: index,
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

class Item {
  final Key id;
  late String title;

  Item({
    required this.id,
    required this.title,
  });
}

class ItemWidget extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  final int index;

  const ItemWidget({
    Key? key,
    required this.item,
    required this.onTap,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          key: item.id,
          title: Text("$index: ${item.title}"),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onTap,
          ),
        ),
        SizedBox(
          width: 500,
          height: 150,
          child: Card(
            key: item.id,
            child: WebView(
              key: item.id,
              initialUrl: "https://www.google.com/search?q=${item.title}",
            ),
          ),
        ),
      ],
    );
  }
}
