import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'todomodel.dart';
import 'addtask.dart';

class Todolist extends StatefulWidget {
  const Todolist({super.key});

  @override
  State<Todolist> createState() => _TodoListState();
}

class _TodoListState extends State<Todolist> {
  final List<Todo> tasks = [];
  final dio = Dio(BaseOptions(baseUrl: "https://dummyjson.com"));

  Future<void> fetch() async {
    final response = await dio.get("/todos");
    final model = Todomodel.fromJson(response.data);
    setState(() {
      tasks.clear();
      tasks.addAll(model.todos.map((t) => t.copyWith(
            createdAt: t.createdAt ?? DateTime.now(),
            isFromApi: true,
          )));
    });
  }

  Future<void> addTodo(String title) async {
    final response = await dio.post("/todos/add", data: {
      "todo": title,
      "completed": false,
      "userId": 5,
    });
    final newTask = Todo.fromJson(response.data).copyWith(
      isFromApi: false,
      id: DateTime.now().millisecondsSinceEpoch,
      createdAt: DateTime.now(),
    );
    setState(() {
      tasks.add(newTask);
    });
  }

  Future<void> updateTodo(Todo task, bool completed, [String? updatedTitle]) async {
    if (task.isFromApi) {
      final response = await dio.put("/todos/${task.id}", data: {
        "completed": completed,
        "todo": updatedTitle ?? task.todo,
      });
      final updatedTask = Todo.fromJson(response.data).copyWith(
        isFromApi: task.isFromApi,
        createdAt: task.createdAt,
      );
      setState(() {
        int index = tasks.indexWhere((t) => t.id == updatedTask.id);
        if (index != -1) {
          tasks[index] = updatedTask;
        }
      });
    } else {
      setState(() {
        int index = tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          tasks[index] = task.copyWith(
              completed: completed,
              todo: updatedTitle ?? task.todo,
              createdAt: task.createdAt);
        }
      });
    }
  }

  Future<void> deleteTodo(Todo task) async {
    if (task.isFromApi) {
      await dio.delete("/todos/${task.id}");
    }
    setState(() {
      tasks.removeWhere((t) => t.id == task.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    int remainingTodos = tasks.where((task) => !task.completed).length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Your To Do",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.black),
                  onPressed: () async {
                    final String? newTitle = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(builder: (_) => const AddTaskPage()),
                    );
                    if (newTitle != null && newTitle.isNotEmpty) {
                      addTodo(newTitle);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: tasks.isEmpty
                  ? const Center(child: Text("No tasks yet"))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) => taskBox(tasks[index]),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your remaining todos: $remainingTodos",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Doing what you love is the cornerstone of having abundance in your life. - Wayne Dyer",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: fetch,
              child: const Text(
                "Click me!",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget taskBox(Todo task) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddTaskPage(task: task)),
        );
        if (result != null) {
          if (result is String) {
            updateTodo(task, task.completed, result);
          } else if (result is Todo) {
            updateTodo(task, task.completed, result.todo);
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Checkbox(
              value: task.completed,
              activeColor: Colors.black,
              checkColor: Colors.white,
              onChanged: (value) =>
                  updateTodo(task, value ?? task.completed),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.todo,
                    style: TextStyle(
                      fontSize: 16,
                      decoration: task.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: task.completed ? Colors.grey : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy')
                        .format(task.createdAt ?? DateTime.now()),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text("User ID: ${task.userId}",
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text("Task ID: ${task.id}",
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => deleteTodo(task),
            ),
          ],
        ),
      ),
    );
  }
}
