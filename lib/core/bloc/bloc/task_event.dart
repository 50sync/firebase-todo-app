part of 'task_bloc.dart';

@immutable
abstract class TaskEvent {}

class LoadTasks extends TaskEvent {}

class ToggleTaskCompletion extends TaskEvent {
  final String taskId;
  final bool isCompleted;

  ToggleTaskCompletion({required this.taskId, required this.isCompleted});
}

class TasksUpdated extends TaskEvent {
  final List<QueryDocumentSnapshot> docs;

  TasksUpdated(this.docs);
}