import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:tasking/core/constants/constants.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  StreamSubscription? _tasksSubscription;

  TaskBloc({required FirebaseFirestore firestore}) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);
    on<TasksUpdated>(_onTasksUpdated);
  }

  void _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) {
    _tasksSubscription?.cancel();
    _tasksSubscription = tasksCollection.snapshots().listen((
      QuerySnapshot snapshot,
    ) {
      add(TasksUpdated(snapshot.docs));
    });
  }

  void _onTasksUpdated(TasksUpdated event, Emitter<TaskState> emit) {
    emit(TasksLoaded(event.docs));
  }

  void _onToggleTaskCompletion(
    ToggleTaskCompletion event,
    Emitter<TaskState> emit,
  ) {
    tasksCollection.doc(event.taskId).update({'isDone': event.isCompleted});
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
