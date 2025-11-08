import 'dart:convert';

Todomodel todomodelFromJson(String str) => Todomodel.fromJson(json.decode(str));
String todomodelToJson(Todomodel data) => json.encode(data.toJson());

class Todomodel {
  final List<Todo> todos;
  final int total;
  final int skip;
  final int limit;

  Todomodel({
    required this.todos,
    required this.total,
    required this.skip,
    required this.limit,
  });

  Todomodel copyWith({
    List<Todo>? todos,
    int? total,
    int? skip,
    int? limit,
  }) =>
      Todomodel(
        todos: todos ?? this.todos,
        total: total ?? this.total,
        skip: skip ?? this.skip,
        limit: limit ?? this.limit,
      );

  factory Todomodel.fromJson(Map<String, dynamic> json) => Todomodel(
        todos: List<Todo>.from(json["todos"].map((x) => Todo.fromJson(x))),
        total: json["total"],
        skip: json["skip"],
        limit: json["limit"],
      );

  Map<String, dynamic> toJson() => {
        "todos": List<dynamic>.from(todos.map((x) => x.toJson())),
        "total": total,
        "skip": skip,
        "limit": limit,
      };
}

class Todo {
  final int id;
  final String todo;
  final bool completed;
  final int userId;
  final DateTime? createdAt;
  final bool isFromApi;

  Todo({
    required this.id,
    required this.todo,
    required this.completed,
    required this.userId,
    this.createdAt,
    this.isFromApi = true,
  });

  Todo copyWith({
    int? id,
    String? todo,
    bool? completed,
    int? userId,
    DateTime? createdAt,
    bool? isFromApi,
  }) =>
      Todo(
        id: id ?? this.id,
        todo: todo ?? this.todo,
        completed: completed ?? this.completed,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
        isFromApi: isFromApi ?? this.isFromApi,
      );

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        id: json["id"],
        todo: json["todo"],
        completed: json["completed"],
        userId: json["userId"],
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"])
            : null,
        isFromApi: true,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "todo": todo,
        "completed": completed,
        "userId": userId,
        "createdAt": createdAt?.toIso8601String(),
      };
}
