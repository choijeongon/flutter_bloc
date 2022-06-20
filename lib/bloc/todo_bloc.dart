import 'package:bloc_test/bloc/todo_event.dart';
import 'package:bloc_test/bloc/todo_state.dart';
import 'package:bloc_test/model/todo/todo.dart';
import 'package:bloc_test/repository/todo_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository repository;

  TodoBloc({required this.repository}) : super(Empty());

  @override
  Stream<TodoState> mapEventToState(TodoEvent event) async* {
    if (event is ListTodoEvent) {
      yield* _mapListTodoEvent(event);
    } else if (event is CreateTodoEvent) {
      yield* _mapCreateTodoEvent(event);
    } else if (event is DeleteTodoEvent) {
      yield* _mapDeleteTodoEvent(event);
    }
  }

  Stream<TodoState> _mapListTodoEvent(ListTodoEvent event) async* {
    try {
      yield Loading();
      final response = await repository.listTodo();
      final todos = response
          .map<Todo>(
            (e) => Todo.fromJson(e),
          )
          .toList();

      yield Loaded(todos: todos);
    } catch (e) {
      yield Error(message: e.toString());
    }
  }

  Stream<TodoState> _mapCreateTodoEvent(CreateTodoEvent event) async* {
    try {
      if (state is Loaded) {
        final parsedState = (state as Loaded);

        final newTodo = Todo(
          id: parsedState.todos[parsedState.todos.length - 1].id + 1,
          title: event.title,
          createdAt: DateTime.now().toString(),
        );

        //기존 상태를 저장
        final prevTodos = [
          ...parsedState.todos,
        ];

        //기존 상태 + 새로운 데이터
        final newTodos = [...prevTodos, newTodo];

        //아직 서버에 저장되지 않았지만 미리 보여주는 방식
        yield Loaded(todos: newTodos);

        final resp = await repository.createTodo(newTodo);

        //추후에 서버에 받은 데이터로 업데이트
        yield Loaded(
          todos: [
            ...prevTodos,
            Todo.fromJson(resp),
          ],
        );
      }
    } catch (e) {
      yield Error(message: e.toString());
    }
  }

  Stream<TodoState> _mapDeleteTodoEvent(DeleteTodoEvent event) async* {
    try {
      if (state is Loaded) {
        final newTodos = (state as Loaded)
            .todos
            .where((element) => element.id != event.todo.id)
            .toList();

        yield Loaded(todos: newTodos);

        await repository.deleteTodo(event.todo);
      }
    } catch (e) {
      yield Error(message: e.toString());
    }
  }
}
