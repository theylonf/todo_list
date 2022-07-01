import 'package:flutter/material.dart';
import 'package:todo_list/models/Todo.dart';
import 'package:todo_list/repositories/todo_repository.dart';
import 'package:todo_list/wigets/todo_list_item.dart';

class TodoListPAGE extends StatefulWidget {
  const TodoListPAGE({Key? key}) : super(key: key);

  @override
  State<TodoListPAGE> createState() => _TodoListPAGEState();
}

class _TodoListPAGEState extends State<TodoListPAGE> {
  final TextEditingController todoController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  List<Todo> todos = [];
  Todo? deletedTodo;
  int? deletedTodoPos;

  String? errorText;

  @override
  void initState() {
    super.initState();
    todoRepository.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: todoController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Ex. Estudar Flutter",
                            labelText: "Adicionar uma tarefa",
                            errorText: errorText),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        String text = todoController.text;

                        if(text.isEmpty){
                          setState(() {
                            errorText = "O titulo não pode ser vazio";
                          });
                          return;
                        }

                        setState(() {
                          Todo newTodo =
                              Todo(title: text, dateTime: DateTime.now());
                          todos.add(newTodo);
                          errorText = null;
                        });
                        todoController.clear();
                        todoRepository.saveTodoList(todos);
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Color(0xff00d7f3),
                          padding: EdgeInsets.all(14)),
                      child: Icon(
                        Icons.add,
                        size: 30,
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 16),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (Todo todo in todos)
                        TodoListItem(
                          todo: todo,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: Text("Voce possui ${todos.length} tarefas")),
                    ElevatedButton(
                      onPressed: showDeleteAllTodosDialog,
                      style: ElevatedButton.styleFrom(
                          primary: Color(0xff00d7f3),
                          padding: EdgeInsets.all(14)),
                      child: Text("Limpar tudo"),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showDeleteAllTodosDialog() {
    showDialog(
      context: context,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Limpar tudo?'),
          content: Text('Voce tem certeza que quer apagar todas as tarefas?'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancelar',
                style: TextStyle(color: Color(0xff00d7f3)),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss alert dialog
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setState(() {
                  todos.clear();
                  todoRepository.saveTodoList(todos);
                });
              },
              child: Text(
                'Limpar tudo',
                style: TextStyle(color: Colors.red),
              ),
            )
          ],
        );
      },
    );
  }

  void onDelete(Todo todo, BuildContext context) {
    deletedTodo = todo;
    deletedTodoPos = todos.indexOf(todo);

    setState(() {
      todos.remove(todo);
      todoRepository.saveTodoList(todos);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        "Tarefa ${todo.title} foi removido com sucesso.",
        style: TextStyle(color: Color(0xff00d7f3)),
      ),
      backgroundColor: Colors.white,
      action: SnackBarAction(
        label: "Desfazer",
        onPressed: () => setState(() {
          todos.insert(deletedTodoPos!, deletedTodo!);
          todoRepository.saveTodoList(todos);
        }),
      ),
      duration: const Duration(seconds: 5),
    ));
  }
}
