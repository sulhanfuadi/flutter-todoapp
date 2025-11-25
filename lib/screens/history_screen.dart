import 'package:flutter/material.dart';
import 'package:pbp_project_flutter_speedrun/helpers/database_helper.dart';
import 'package:pbp_project_flutter_speedrun/models/task_model.dart';
import 'package:sqflite/sqflite.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Task>? taskList;
  int count = 0;

  @override
  void initState() {
    super.initState();
    updateListView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completed Tasks')),
      body: taskList == null || taskList!.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No completed tasks yet!',
                    style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: count,
              itemBuilder: (BuildContext context, int position) {
                return _buildTaskCard(taskList![position]);
              },
            ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: Text(
          task.title ?? '',
          style: const TextStyle(decoration: TextDecoration.lineThrough),
        ),
        subtitle: Text(task.date ?? ''),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            _deleteTask(task);
          },
        ),
      ),
    );
  }

  void _deleteTask(Task task) async {
    int result = await databaseHelper.deleteTask(task.id!);
    if (result != 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Task deleted')));
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Task>> taskListFuture = databaseHelper.getTaskList();
      taskListFuture.then((taskList) {
        setState(() {
          this.taskList = taskList.where((task) => task.status == 1).toList();
          count = this.taskList!.length;
        });
      });
    });
  }
}
