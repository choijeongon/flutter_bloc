import 'package:bloc_test/bloc/todo_bloc.dart';
import 'package:bloc_test/bloc/todo_event.dart';
import 'package:bloc_test/bloc/todo_state.dart';
import 'package:bloc_test/repository/todo_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TodoBloc(repository: TodoRepository()),
      child: const HomeWidget(),
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  String title = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // ListTodosEvent를 처음에 불러줌
    BlocProvider.of<TodoBloc>(context).add(
      ListTodoEvent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //BlocProvider.of<TodoBloc>(context).add랑 같은 문법
          context.read<TodoBloc>().add(
                CreateTodoEvent(
                  title: title,
                ),
              );
        },
        child: const Icon(
          Icons.edit,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              onChanged: ((value) {
                title = value;
              }),
            ),
            const SizedBox(
              height: 16.0,
            ),
            Expanded(
              //만들어진 TodoBloc을 사용하기 위해 BlocBuilder를 사용해야 한ㅏ.
              child: BlocBuilder<TodoBloc, TodoState>(
                builder: (_, state) {
                  if (state is Empty) {
                    return Container();
                  } else if (state is Error) {
                    return Text(state.message);
                  } else if (state is Loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is Loaded) {
                    final items = state.todos;

                    return ListView.separated(
                      itemBuilder: (_, index) {
                        final item = items[index];

                        return Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                BlocProvider.of<TodoBloc>(context).add(
                                  DeleteTodoEvent(todo: item),
                                );
                              },
                              icon: const Icon(
                                Icons.delete,
                              ),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (_, index) => const Divider(),
                      itemCount: items.length,
                    );
                  }

                  return Container();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
