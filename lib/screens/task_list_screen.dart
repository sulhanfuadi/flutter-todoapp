import 'package:flutter/material.dart';
import 'package:pbp_project_flutter/models/task.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [
    Task(
      id: '1',
      title: 'Send an email to the team',
      date: DateTime(2021, 3, 14),
      priority: 'High',
    ),
    Task(
      id: '2',
      title: 'Buy tickets to Canada',
      date: DateTime(2021, 3, 14),
      priority: 'High',
    ),
    Task(
      id: '3',
      title: 'Talk with steve',
      date: DateTime(2021, 3, 15),
      priority: 'Low',
    ),
    Task(
      id: '4',
      title: 'Movie times',
      date: DateTime(2021, 3, 15),
      priority: 'Medium',
    ),
  ];

  int get pendingTasksCount => tasks.where((t) => !t.isCompleted).length;

  void _addTask(Task task) {
    setState(() {
      tasks.add(task);
    });
  }

  void _updateTask(Task updatedTask) {
    setState(() {
      int index = tasks.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        tasks[index] = updatedTask;
      }
    });
  }

  void _deleteTask(String id) {
    setState(() {
      tasks.removeWhere((t) => t.id == id);
    });
  }

  void _toggleTaskCompletion(String id) {
    setState(() {
      int index = tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        tasks[index].isCompleted = !tasks[index].isCompleted;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {},
        ),
        title: const Text(
          'Task Manager',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'You have [ $pendingTasksCount ] pending task out of [ ${tasks.length} ]',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskListItem(
                  task: task,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailsScreen(task: task),
                      ),
                    );
                    if (result != null) {
                      if (result['action'] == 'update') {
                        _updateTask(result['task']);
                      } else if (result['action'] == 'delete') {
                        _deleteTask(result['taskId']);
                      }
                    }
                  },
                  onCheckboxChanged: (value) {
                    _toggleTaskCompletion(task.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
          if (result != null) {
            _addTask(result);
          }
        },
        backgroundColor: Colors.red[400],
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final Function(bool?) onCheckboxChanged;

  const TaskListItem({
    Key? key,
    required this.task,
    required this.onTap,
    required this.onCheckboxChanged,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        title: Text(
          task.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${_formatDate(task.date)} - ${task.priority}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Checkbox(
          value: task.isCompleted,
          onChanged: onCheckboxChanged,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
