import 'package:flutter/material.dart';
import 'package:pbp_project_flutter_speedrun/helpers/database_helper.dart';
import 'package:pbp_project_flutter_speedrun/models/task_model.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  final Task task;

  const AddTaskScreen({super.key, required this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  String _priority = 'Low';
  List<String> _priorities = ['High', 'Medium', 'Low'];

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.task.title ?? '';
    descriptionController.text = widget.task.description ?? '';
    _priority = widget.task.priority ?? 'Low';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.id == null ? 'Add Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Priority'),
              trailing: DropdownButton<String>(
                value: _priority,
                items: _priorities.map((String priority) {
                  return DropdownMenuItem<String>(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _priority = newValue!;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _save();
                    },
                    child: const Text('Save'),
                  ),
                ),
                if (widget.task.id != null) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        _delete();
                      },
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _save() async {
    widget.task.title = titleController.text;
    widget.task.description = descriptionController.text;
    widget.task.priority = _priority;
    widget.task.date = DateFormat.yMMMd().format(DateTime.now());
    widget.task.status = widget.task.status ?? 0;

    int result;
    if (widget.task.id != null) {
      result = await databaseHelper.updateTask(widget.task);
    } else {
      result = await databaseHelper.insertTask(widget.task);
    }

    if (result != 0) {
      _showSnackBar('Task saved successfully');
      Navigator.pop(context);
    } else {
      _showSnackBar('Problem saving task');
    }
  }

  void _delete() async {
    if (widget.task.id == null) {
      _showSnackBar('No task to delete');
      return;
    }

    int result = await databaseHelper.deleteTask(widget.task.id!);
    if (result != 0) {
      _showSnackBar('Task deleted successfully');
      Navigator.pop(context);
    } else {
      _showSnackBar('Error deleting task');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
