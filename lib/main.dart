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
        body: Column(
            children: <Widget>[
              if (tasks != null) for (var t in tasks.tasks) Row(
                children: <Widget>[
                  Checkbox(value: t.status,
                  onChanged: (bool val){
                    setState(() {
                      t.status = val;
                    });
                    updateTask(t.id, jsonEncode(t));
                  }
                  ),
                  Text(t.title)
                ],
              )
            ]
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          for (var t in tasks.tasks)
            print(t.status);
        },
        child: Icon(Icons.print),
        backgroundColor: Colors.red,
      ),
    );
  }

}