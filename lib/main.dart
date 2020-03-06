import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'task.dart';
import 'package:http/http.dart' as http;



void main() {
  runApp(MaterialApp(
      home: HomePage()
  ));
}


class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  TaskList tasks;
  String apiUrl = 'https://todo-rest-ms.herokuapp.com/todo/api/v1.0/tasks';

  Future<String> fetchTasks() async {

    var response = await http.get(apiUrl);
    print("Response");
    this.setState((){
      if (response.statusCode == 200) {
        var parsedJson = json.decode(response.body);
        tasks = TaskList.fromJson(parsedJson);
      }
      else {
        throw Exception('Non 200 response');
      }
    });
    return "SUCCESS";
  }

  void updateTask(int id, String json) async {
    print(json);
    var response = await http.put(
        apiUrl + '/' + id.toString(),
        headers: {"Content-type" : "application/json"},
        body: json
    );
    print(response.body);
  }

  Future<void> addTask(Map task) async {
    var response = await http.post(
      apiUrl,
      headers: {"Content-type" : "application/json"},
      body: jsonEncode(task)
    );
    this.setState((){
      if (response.statusCode == 200) {
        var parsedJson = json.decode(response.body);
        tasks = TaskList.fromJson(parsedJson);
      }
      else {
        throw Exception('Non 200 response');
      }
    });
  }

  Future<void> deleteTask(int id) async {
    var response = await http.delete(
      apiUrl + '/' + id.toString()
    );
    this.setState((){
      handleResponse(response);
    });
  }

  void handleResponse(var response) {
    this.setState((){
      if (response.statusCode == 200) {
        var parsedJson = json.decode(response.body);
        tasks = TaskList.fromJson(parsedJson);
      }
      else {
        throw Exception('Non 200 response');
      }
    });
  }


  @override
  void initState() {
    super.initState();
    this.fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: Text('Tasks'),
          backgroundColor: Colors.red,
        ),
        body: ListView.builder(
            itemCount: tasks.tasks.length,
            itemBuilder: (context, index) {
              var item = tasks.tasks[index];
              return Dismissible(
                key: UniqueKey(),
                background: Container(
//                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  alignment: AlignmentDirectional.centerStart,
                  child: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
                secondaryBackground: Container(
//                  color: Colors.amber[700],
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  alignment: AlignmentDirectional.centerEnd,
                  child: Icon(
                    Icons.done,
                    color: Colors.green,
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: Material(
                    color: Colors.white,
                    elevation: 10.0,
                    borderRadius: BorderRadius.circular(24.0),
                    child: Row(
                        children: <Widget>[
                          Checkbox(value: item.status,
                              onChanged: (bool val){
                                setState(() {
                                  item.status = val;
                                });
                                updateTask(item.id, jsonEncode(item));
                              }
                          ),
                          Text(item.title)
                        ],
                      )
                )
                ),
                onDismissed: (direction) {
                  if (direction == DismissDirection.startToEnd) {
                    deleteTask(item.id);
                  } else {
                    print("Complete Task (NOT IMPLEMENTED");
                  }

                },
              );
            }
        ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showNewTaskDialog(context).then((onValue) {
            if (onValue != null) {
              addTask(onValue);
            }
          });
        },
        child: Icon(Icons.print),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<Map> showNewTaskDialog(BuildContext context) {
    TextEditingController newTaskTitle = TextEditingController();
    TextEditingController newTaskDesc = TextEditingController();
    return showDialog(context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              children: <Widget>[
                TextField(
                  controller: newTaskTitle,
                  autofocus: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Task',
                  ),
                ),
                TextField(
                  controller: newTaskDesc,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Description',
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Add'),
                onPressed: () {
                  if (newTaskTitle.text.toString().isEmpty)
                    Navigator.of(context).pop();
                  else {
                    Map task = {
                      'title': newTaskTitle.text.toString(),
                      'description': newTaskDesc.text.toString()
                    };
                    Navigator.of(context).pop(task);
                  }
                },
              )
            ],
          );
        }
    );
  }

}
