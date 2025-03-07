import 'package:flutter/material.dart';
import 'package:flutter_sqlite_demo/models/dog.dart';
import 'package:flutter_sqlite_demo/services/database_service.dart';

class DogForm extends StatefulWidget {
  final Dog? dog;

  const DogForm({super.key, this.dog});

  @override
  State<DogForm> createState() => _DogFormState();
}

class _DogFormState extends State<DogForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late int _age;

  @override
  void initState() {
    super.initState();
    _name = widget.dog?.name ?? '';
    _age = widget.dog?.age ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dog == null ? 'Add Dog' : 'Edit Dog'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                initialValue: _age.toString(),
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _age = int.parse(value!);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (widget.dog == null) {
                      // Add new dog
                      await insertDog(Dog(name: _name, age: _age));
                    } else {
                      // Update existing dog
                      await updateDog(Dog(id: widget.dog!.id, name: _name, age: _age));
                    }
                    if (context.mounted) Navigator.pop(context, true);
                  }
                },
                child: Text(widget.dog == null ? 'Add' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
