import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'task.dart';
import 'addtask.dart';

class Todolist extends StatefulWidget {
  const Todolist({super.key});

  @override
  State<Todolist> createState() => _TodoListState();
}

class _TodoListState extends State<Todolist> {
  final List<Task> tasks = [];

  @override
  Widget build(BuildContext context) {
    int remainingTodos = tasks.where((task) => !task.isCompleted).length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              "Your To Do",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.black),
                  onPressed: () async {
                    final Task? newTask = await Navigator.push<Task>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddTaskPage(),
                      ),
                    );
                    if (newTask != null) {
                      setState(() {
                        tasks.add(newTask);
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(tasks.length, (index) {
                    return taskBox(tasks[index]);
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget taskBox(Task task) {
    return InkWell(
      onTap: () async {
        final Task? updatedTask = await Navigator.push<Task>(
          context,
          MaterialPageRoute(
            builder: (_) => AddTaskPage(task: task),
          ),
        );
        if (updatedTask != null) {
          setState(() {
            int index = tasks.indexWhere((t) => t.id == task.id);
            if (index != -1) {
              tasks[index] = updatedTask;
            }
          });
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
              value: task.isCompleted,
              activeColor: Colors.black,
              checkColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  int index = tasks.indexWhere((t) => t.id == task.id);
                  if (index != -1) {
                    tasks[index] = task.copyWith(isCompleted: value ?? false);
                  }
                });
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: task.isCompleted ? Colors.grey : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(task.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                setState(() {
                  tasks.removeWhere((t) => t.id == task.id);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
