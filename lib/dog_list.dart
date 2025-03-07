import 'package:flutter/material.dart';
import 'package:flutter_sqlite_demo/dog_form.dart';
import 'package:flutter_sqlite_demo/models/dog.dart';
import 'package:flutter_sqlite_demo/services/database_service.dart';

class DogList extends StatefulWidget {
  const DogList({super.key});

  @override
  State<DogList> createState() => _DogListState();
}

class _DogListState extends State<DogList> {
  late Future<List<Dog>> dogs;
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    dogs = _databaseService.retrieveDogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dog List')),
      body: FutureBuilder<List<Dog>>(
        future: dogs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No dogs found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final dog = snapshot.data![index];
                return ListTile(
                  title: Text(dog.name),
                  subtitle: Text('Age: ${dog.age}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DogForm(dog: dog)),
                          ).then((value) {
                            if (value == true) {
                              // Refresh the list
                              setState(() {
                                dogs = _databaseService.retrieveDogs();  
                              });                            
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _databaseService.deleteDog(dog.id);
                            dogs = _databaseService.retrieveDogs();
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DogForm()),
          ).then((value) {
            if (value == true) {
              setState(() {
               dogs = _databaseService.retrieveDogs(); 
              });
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
