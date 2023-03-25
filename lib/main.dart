import 'package:flutter/material.dart';
import 'dart:math';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
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
  final PagingController<int, String> _pagingController =
  PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchData(pageKey);
    });
  }

  String _generateString() {
    final Random random = Random();
    final int length = random.nextInt(10) + 1;
    return String.fromCharCodes(
        List.generate(length, (index) => random.nextInt(26) + 65));
  }

  Future<void> _fetchData(int pageKey) async {
    try {
      final List<String> newData = [];
      for(var i=0; i<10; i++){
        newData.add(_generateString());
      }
      final isLastPage = newData.isEmpty;
      if (isLastPage) {
        _pagingController.appendLastPage([]);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newData, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PagedListView<int, String>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<String>(
          itemBuilder: (context, item, index) {
            return Column(
              children: [
                ListTile(
                  title: Text(item),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _pagingController.itemList?.removeAt(index);
                      _pagingController.refresh();
                    },
                  ),
                ),
                SizedBox(
                  width: 500,
                  height: 150,
                  child: Card(
                    child: InAppWebView(
                        initialUrlRequest: URLRequest(
                            url: Uri.parse("https://flutter.dev/"))),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
