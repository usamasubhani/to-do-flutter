import 'package:flutter/material.dart';
import 'dart:convert';

void main() {

  var tasks = ['do that', 'do this'];
  bool _status = false;
  void _statusChange(bool value) => _status = value;

  runApp(MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('My first app'),
            backgroundColor: Colors.green,
          ),
          body: getTasks()
      )
  ));
}
//  runApp(MaterialApp(
//      home: Scaffold(
//        appBar: AppBar(
//          title: Text('My first app'),
//          backgroundColor: Colors.green,
//        ),
//        body: Container(
//          child: Center(
//            child: Column(
//              children: <Widget>[
//                Row(
//                  children: <Widget>[
//                    Checkbox(value: _status, onChanged: _statusChange),
//                    Text('task')
//                  ],
//                )
//              ],
//            ),
//          ),
//        )
//      )
//  ));
//}

Widget getTasks() {
  List<String> list = ['nice', 'wow'];

  String tasksJson = '''
  [{"title": "Now this", "status": false, "description": "", "id": 2}]
  ''';

  var parsedTasks = json.decode(tasksJson);
  return Column(
    children: <Widget>[
      for (var task in parsedTasks) Row(
        children: <Widget>[
          Checkbox(value: task['status']),
          Text(task['title'])
        ]
      )
    ],
  );
}
