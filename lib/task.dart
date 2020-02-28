class Task {
  int id;
  String title;
  String description;
  bool status;

  Task({
    this.id,
    this.title,
    this.description,
    this.status
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return new Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status']
    );
  }
}

class TaskList {
  List<Task> tasks;

  TaskList({
    this.tasks,
  });

  factory TaskList.fromJson(List<dynamic> parsedJson) {
    List<Task> t = new List<Task>();
    t = parsedJson.map((i) => Task.fromJson(i)).toList();

    return new TaskList(
      tasks: t,
    );
  }
}