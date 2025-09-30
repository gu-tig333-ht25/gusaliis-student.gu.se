// Importerar Flutter-paketet som innehåller allt man behöver för att bygga UI osv
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Startar appen och kör MyApp
void main() {
  runApp(
    ChangeNotifierProvider(
      // Hämtar todos direkt
      create: (_) => TodoProvider()..fetchTodos(),
      child: const MyApp(),
    ),
  );
}
// Detta är roten av appen, allt börjar här
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TIG333 TODO',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 0, 0),
        ),
        useMaterial3: true, // Använder nya designprinciper
      ),
      home: const TodoListPage(), // Den första sidan som visas, att-göra-listan
      debugShowCheckedModeBanner: false, // Tar bort debug-bannern uppe i hörnet
    );
  }
}

// Modell
class Todo {
  final String id; // en unik ID för varje todo
  final String title; // själva texten
  final bool done; // Om den är klar eller ej

  const Todo({
    required this.id,
    required this.title,
    required this.done,
  });

  // Skapar ett todo-objekt från json (API)
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      done: json['done'],
    );
  }

  Map<String, dynamic> toJson() { // Omvandlar ett todo-objekt till JSON när vi skickar till API
    return {
      'title': title,
      'done': done,
    };
  }
}

// Provider
class TodoProvider with ChangeNotifier {
  final String _key = '3b2d1770-6f15-4259-bdfd-9a69c21e5ed4'; // API-nyckelkn
  final List<Todo> _todos = []; // lista som innehåller alla todos

  List<Todo> get todos => _todos; // Getter för att läsa todos 

  // Hämtar todos från APIn
  Future<void> fetchTodos() async {
    final url = Uri.parse('https://todoapp-api.apps.k8s.gu.se/todos?key=$_key');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _todos.clear();
      _todos.addAll(data.map((json) => Todo.fromJson(json)).toList());
      notifyListeners();
    } else {
      print('Could not get todos: ${response.statusCode}');
    }
  }

  // Lägger till en todo genom API 
  Future<void> addTodo(String title) async {
    final url = Uri.parse('https://todoapp-api.apps.k8s.gu.se/todos?key=$_key');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = jsonDecode(response.body);
      final newTodo = Todo.fromJson(data.last); // Tar den nyaste todon
      _todos.add(newTodo);
      notifyListeners();
    } else {
      print('Could not add todo: ${response.statusCode}');
    }
  }

  // Växlar todo till klar/inte klar, uppdaterar via API
  Future<void> toggleDone(Todo todo) async {
    final url = Uri.parse('https://todoapp-api.apps.k8s.gu.se/todos/${todo.id}?key=$_key');
    final updatedTodo = Todo(id: todo.id, title: todo.title, done: !todo.done);

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedTodo.toJson()),
    );

    if (response.statusCode == 200) {
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = updatedTodo;
        notifyListeners();
      }
    } else {
      print('Could not update todo: ${response.statusCode}');
    }
  }

  // tar bort en todo!
  Future<void> removeTodo(String id) async {
    final url = Uri.parse('https://todoapp-api.apps.k8s.gu.se/todos/$id?key=$_key');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      _todos.removeWhere((t) => t.id == id);
      notifyListeners();
    } else {
      print('Could not delete todo: ${response.statusCode}');
    }
  }
}

// Filter för hela listan 
enum Filter { all, done, undone }

// Huvudsidan
class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  Filter _filter = Filter.all; // standardfilter, visa alla

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();
    
    // filtrerar beroende på valt filter 
    final todos = provider.todos.where((todo) {
      switch (_filter) {
        case Filter.done:
          return todo.done;
        case Filter.undone:
          return !todo.done;
        case Filter.all:
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 251, 218, 243),
        title: const Text('TIG333 TODO'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // tre filter-knappar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _filter == Filter.all,
                onSelected: (_) => setState(() => _filter = Filter.all),
              ),
              FilterChip(
                label: const Text('Done'),
                selected: _filter == Filter.done,
                onSelected: (_) => setState(() => _filter = Filter.done),
              ),
              FilterChip(
                label: const Text('Undone'),
                selected: _filter == Filter.undone,
                onSelected: (_) => setState(() => _filter = Filter.undone),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // lista med todos 
          Expanded(
            child: todos.isEmpty
                ? const Center(child: Text('No todos yet!'))
                : ListView.separated(
                    itemCount: todos.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return ListTile(
                        leading: Icon(
                          todo.done
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                        ),
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            decoration: todo.done
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        onTap: () => provider.toggleDone(todo),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => provider.removeTodo(todo.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      // knapp för att lägga till en ny todo
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddTodoPage()),
            );
          },
          backgroundColor: const Color.fromARGB(255, 251, 218, 243),
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add,
            size: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// Lägg till-sida
class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isLoading = true);
    await context.read<TodoProvider>().addTodo(text);
    setState(() => _isLoading = false);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Todo'),
        backgroundColor: const Color.fromARGB(255, 251, 218, 243),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'What do you need to do?',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[200],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
