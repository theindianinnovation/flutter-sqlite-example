import 'package:flutter/material.dart';
import 'package:flutter_sqlite/database_helper.dart';
import 'package:flutter_sqlite/model/dog.dart';
import 'add_dog_screen.dart';

class DogsListScreen extends StatefulWidget {
  @override
  State<DogsListScreen> createState() => _DogsListScreenState();
}

class _DogsListScreenState extends State<DogsListScreen> {
  late DatabaseHandler handler;
  late Future<List<Dog>> _dogs;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    handler.initializeDB().whenComplete(() async {
      setState(() {
        _dogs = getList();
      });
    });
  }

  Future<List<Dog>> getList() async {
    return await handler.dogs();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _dogs = getList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sqlite Example'),
      ),
      body: FutureBuilder<List<Dog>>(
          future: _dogs,
          builder: (BuildContext context, AsyncSnapshot<List<Dog>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return new Center(
                child: new CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return new Text('Error: ${snapshot.error}');
            } else {
              final items = snapshot.data ?? <Dog>[];
              return new Scrollbar(
                child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Dismissible(
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: const Icon(Icons.delete_forever),
                          ),
                          key: ValueKey<int>(items[index].id),
                          onDismissed: (DismissDirection direction) async {
                            await handler.deleteDog(items[index].id);
                            setState(() {
                              items.remove(items[index]);
                            });
                          },
                          child: Card(
                              child: ListTile(
                            contentPadding: const EdgeInsets.all(8.0),
                            title: Text(items[index].name),
                            subtitle: Text(items[index].age.toString()),
                          )),
                        );
                      },
                    )),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddDogScreen()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).backgroundColor,
      ),
    );
  }
}
