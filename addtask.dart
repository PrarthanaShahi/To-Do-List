import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'todomodel.dart';

class AddTaskPage extends StatefulWidget {
  final Todo? task;
  const AddTaskPage({super.key, this.task});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
       _controller.text = widget.task!.todo;
      _selectedDate = widget.task!.createdAt ?? DateTime.now();
    } else {
      _selectedDate = DateTime.now();
    }
  }

  String? taskValidator(String? value) {
    if (value == null || value.trim().isEmpty) return "Task cannot be empty";
    String trimmed = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (trimmed.length < 3) return "Task must have at least 3 letters";
    return null;
  }

  void submitTask() {
    setState(() {
      _submitted = true;
    });
    if (_formKey.currentState!.validate()) {
      if (widget.task == null) {
        Navigator.pop(context,
            _controller.text.trim().replaceAll(RegExp(r'\s+'), ' '));
      } else {
        final updatedTask = widget.task!.copyWith(
          todo: _controller.text.trim().replaceAll(RegExp(r'\s+'), ' '),
          createdAt: _selectedDate,
        );
        Navigator.pop(context, updatedTask);
      }
    }
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: _submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.task == null ? "Add Task" : "Edit Task",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    child: TextFormField(
                      controller: _controller,
                      validator: taskValidator,
                      decoration: const InputDecoration(
                        hintText: "Enter task (max 3 words)",
                        border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        errorStyle: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(widget.task == null ? Icons.add : Icons.check,
                          color: Colors.white),
                      onPressed: submitTask,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: pickDate,
                    child: Text(
                      "Selected: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: pickDate,
                      child: const Text(
                        "Pick Date",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
