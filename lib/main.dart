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

  Future<String> fetchTasks() async {
    String apiUrl = 'https://todo-rest-ms.herokuapp.com/todo/api/v1.0/tasks';
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
          backgroundColor: Colors.green,
        ),
        body: Column(
            children: <Widget>[
              for (var t in tasks.tasks) Row(
                children: <Widget>[
                  Checkbox(value: t.status),
                  Text(t.title)
                ],
              )
            ]
        )
    );
  }

}