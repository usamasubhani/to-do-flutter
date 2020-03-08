import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'task.dart';
import 'package:http/http.dart' as http;



void main() {
  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
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
    handleResponse(response);
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
  Widget build(BuildContext context)  {
    return  Scaffold(
//      backgroundColor: Color(0xffEAECEF),
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Today', style: TextStyle(color: Color(0xff464D45))),
//          backgroundColor: Color(0xffEAECEF),
          backgroundColor: Colors.transparent,
          elevation: 0,
          brightness: Brightness.light,
        ),
        body: (tasks == null) ? Center(child: Text('Empty')) : ListView.builder(
            itemCount: tasks.tasks.length,
            itemBuilder: (context, index) {
              var item = tasks.tasks[index];
              return Dismissible(
                key: UniqueKey(),
                background: Container(
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
                  child: Container(

                      decoration: new BoxDecoration(
//                        color: Color(0xffEAECEF),
                      color: Colors.white,
                        boxShadow: [
                          new BoxShadow(
                            color: Color(0xffd9d9d9),
//                            color: Colors.red,
                            offset: new Offset(20.0, 20.0),
                            blurRadius: 60.0,
                          ),
                          new BoxShadow(
                            color: Color(0xffffffff),
                            offset: new Offset(-20.0, -20.0),
                            blurRadius: 60.0,
                          )
                        ],
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                    child: Row(
                        children: <Widget>[
                          Checkbox(
                              activeColor: Colors.black,
                              value: item.status,
                              onChanged: (bool val){
                                setState(() {
                                  item.status = val;
                                });
                                updateTask(item.id, jsonEncode(item));
                              }
                          ),
                          Text(item.title),
                          Expanded( // Empty widget to align edit button to right
                            flex: 2,
                            child: Text('')
                          ),
                          IconButton(
                            key: UniqueKey(),
                            icon: Icon(Icons.edit),
                            alignment: Alignment.centerRight,
                            onPressed: () {
                              showEditTaskDialog(context, item).then((onValue) {
                                if (onValue != null) {
                                  item.title = onValue['title'];
                                  item.description = onValue['description'];
                                  updateTask(item.id, jsonEncode(item));
                                }
                              });
                            },
                          )
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
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat
    );
  }

  Future<Map> showNewTaskDialog(BuildContext context) {
    TextEditingController newTaskTitle = TextEditingController();
    TextEditingController newTaskDesc = TextEditingController();
    return showDialog(context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(10.0),
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

  Future<Map> showEditTaskDialog(BuildContext context, Task task) {
    TextEditingController editTaskTitle = TextEditingController(text: task.title);
    TextEditingController editTaskDesc = TextEditingController(text: task.description);
    return showDialog(context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              children: <Widget>[
                TextField(
                  controller: editTaskTitle,
                  autofocus: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Task',
                  ),
                ),
                TextField(
                  controller: editTaskDesc,
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
                  if (editTaskTitle.text.toString().isEmpty)
                    Navigator.of(context).pop();
                  else {
                    Map task = {
                      'title': editTaskTitle.text.toString(),
                      'description': editTaskDesc.text.toString()
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
