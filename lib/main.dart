import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/providers/todo_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'data/datasources/todo_local_data_source.dart';
import 'data/repositories/todo_repository_impl.dart';
import 'domain/usecases/get_todos.dart';
import 'domain/usecases/add_todo.dart';
import 'domain/usecases/update_todo.dart';
import 'domain/usecases/delete_todo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up data source, repository, and use cases
  final localDataSource = TodoLocalDataSource();
  final todoRepository = TodoRepositoryImpl(localDataSource);
  final getTodos = GetTodos(todoRepository);
  final addTodo = AddTodo(todoRepository);
  final updateTodo = UpdateTodo(todoRepository);
  final deleteTodo = DeleteTodo(todoRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TodoProvider(
            getTodosUseCase: getTodos,
            addTodoUseCase: addTodo,
            updateTodoUseCase: updateTodo,
            deleteTodoUseCase: deleteTodo,
          ),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Todo App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const HomeScreen(),
    );
  }
}
