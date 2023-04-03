import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

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
  final PagingController<int, Item> _pagingController = PagingController(firstPageKey: 0);

  List<Item>? get result => null;

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    // Refetch once every 5 seconds.
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      await refetch();
    });

    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final items = _generateNewDataList(pageKey, 10);
      final isLastPage = items.length < 10;
      if (isLastPage) {
        _pagingController.appendLastPage(items);
      } else {
        final nextPageKey = pageKey + items.length;
        _pagingController.appendPage(items, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<void> refetch() async {
    setState(() {
      final tmp = _pagingController.itemList;
      // Add one item every five times. Otherwise, no item changes.
      if (_refetchCount % 5 == 0) {
        var items = [generateNewData(), ...?tmp];
        _pagingController.itemList = items;
      } else {
        _pagingController.itemList = tmp;
      }
      _refetchCount ++;
    });
  }

  int _refetchCount = 0;

  Item generateNewData() {
    return Item(id: UniqueKey(), title: _generateString());
  }

  String _generateString() {
    final Random random = Random();
    final int length = random.nextInt(10) + 1;
    return String.fromCharCodes(
        List.generate(length, (index) => random.nextInt(26) + 65));
  }

  List<Item> _generateNewDataList(int startIndex, int count) {
    return List.generate(
      count,
      (index) => Item(
        id: UniqueKey(),
        title: _generateString()
      ),
    );
  }

  void _removeItem(Key key) {
    setState(() {
      final index = _pagingController.itemList!.indexWhere((item) => item.id == key);
      _pagingController.itemList![index] = Item(id: _pagingController.itemList![index].id, title: '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PagedListView<int, Item>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Item>(
          itemBuilder: (BuildContext context, Item item, int index) {
            if (item.title == '') {
              return const SizedBox.shrink();
            }
            return ItemWidget(
              item: item,
              onTap: () => _removeItem(item.id),
              key: item.id,
              index: index,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pagingController.refresh(),
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class Item {
  final Key id;
  String title;

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
