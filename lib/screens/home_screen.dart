import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pbp_project_flutter_speedrun/helpers/database_helper.dart';
import 'package:pbp_project_flutter_speedrun/models/task_model.dart';
import 'package:pbp_project_flutter_speedrun/screens/add_task_screen.dart';
import 'package:pbp_project_flutter_speedrun/screens/history_screen.dart';
import 'package:pbp_project_flutter_speedrun/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              ).then((_) => updateListView());
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: taskList == null || taskList!.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task, size: 100, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    'No tasks yet!',
                    style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap + to add a new task',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(task: Task()),
            ),
          ).then((_) => updateListView());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    Color priorityColor = _getPriorityColor(task.priority ?? 'Low');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: priorityColor,
          child: Text(
            task.priority?[0] ?? 'L',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          task.title ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: task.status == 1 ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.description ?? ''),
            const SizedBox(height: 4),
            Text(
              task.date ?? '',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Checkbox(
          value: task.status == 1,
          onChanged: (value) {
            task.status = value! ? 1 : 0;
            databaseHelper.updateTask(task);
            updateListView();
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen(task: task)),
          ).then((_) => updateListView());
        },
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Task>> taskListFuture = databaseHelper.getTaskList();
      taskListFuture.then((taskList) {
        setState(() {
          this.taskList = taskList.where((task) => task.status == 0).toList();
          count = this.taskList!.length;
        });
      });
    });
  }
}
