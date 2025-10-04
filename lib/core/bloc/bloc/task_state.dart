part of 'task_bloc.dart';

@immutable
abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<QueryDocumentSnapshot> docs;

  TasksLoaded(this.docs);
}

class TaskError extends TaskState {
  final String message;

  TaskError(this.message);
}