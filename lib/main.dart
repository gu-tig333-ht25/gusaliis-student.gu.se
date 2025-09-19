// Importerar Flutter-paketet som innehåller allt man behöver för att bygga UI
import 'package:flutter/material.dart';

// Startar appen och kör MyApp
void main() => runApp(const MyApp());

// Detta är roten av appen, allt börjar här
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp är skal för hela appen, den hanterar tema, titlar, navigation m.m.
    return MaterialApp(
      title: 'TIG333 TODO', // Visas i systemet ibland (inte på skärmen)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 0, 0, 0)),
        useMaterial3: true, // Använder nya designprinciper
      ),
      home: const TodoListPage(), // Den första sidan som visas, att-göra-listan
      debugShowCheckedModeBanner: false, // Tar bort debug-bannern uppe i hörnet
    );
  }
}

// En modellklass som beskriver en Todo (titel och om den är klar eller inte)
class Todo {
  final String title; // Vad uppgiften heter
  final bool done;    // Om den är avklarad eller inte

  const Todo(this.title, {this.done = false}); // done = false som standard
}

// Själva vyn (sidan) som visar listan
class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
    // En lista med att-göra-uppgifter
  final List<Todo> _todos = [
    Todo('Write a book'),
    Todo('Do homework'),
    Todo('Tidy room', done: true),
    Todo('Watch TV'),
    Todo('Nap'),
    Todo('Shop groceries'),
    Todo('Have fun'),
    Todo('Meditate'),
  ];

  final TextEditingController _controller = TextEditingController(); // För att läsa text från textfältet

  void _addTodo() {
    final text = _controller.text.trim(); // läs texten från fältet, ta bort ellanslag 
    if (text.isEmpty) return; // gör ingenting om fältet är tot

    setState(() { // UI ska ritas om när vi ändrar listan
      _todos.add(Todo(text)); // lägg till en ny todo i listan 
      _controller.clear(); // töm textfältet efter vi lagt till
    });
    
    FocusScope.of(context).unfocus(); // stänger tangentbordet 
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold = sidlayout: appbar, body, floating button m.m.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 252, 182, 234), // Ljusgrå bakgrund på toppen
        centerTitle: true, // Centrerar texten
        title: const Text(
          'TIG333 TODO',
          style: TextStyle(fontWeight: FontWeight.bold), // Fet stil
        ),
        actions: const [
          // Ikon uppe till höger (de tre prickarna)
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.more_vert, color: Colors.black54),
          ),
        ],
      ),

      // Kroppen (huvuddelen) av sidan
      body: Padding(
        padding: const EdgeInsets.all(16), // Yttre marginal runt hela innehållet
        child: Column(
          children: [
            // Sökrutan
            Row(
              children: [
                Expanded(
                  child: TextField( 
                    controller: _controller, // kopplar textfältet till _controller
                    onSubmitted: (_) => _addTodo(), // Gör så att Enter också funkar
                    decoration: const InputDecoration(
                      hintText: 'What are you going to do?',
                      prefixIcon: Icon(Icons.edit),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8), // Lite luft mellan fältet och knappen
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 250, 201, 238),
                  ),
                  onPressed: _addTodo, // Använder din hjälpfunktion
                  icon: const Icon(Icons.add),
                  tooltip: 'Add',
                ),
              ],
            ),
            const SizedBox(height: 16), // Avstånd ner till knapparna

            // All, done, undone knapparna (fungerar inte just nu)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: null, // Går inte att klicka
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black), // Svart kant
                    foregroundColor: Colors.black, // Svart text
                  ),
                  child: const Text('All'),
                ),
                OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Done'),
                ),
                OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Undone'),
                ),
              ],
            ),
            const SizedBox(height: 16), 

            // Listan med todos
            Expanded(
              child: ListView.separated(
                itemCount: _todos.length,
                separatorBuilder: (_, __) => const Divider(height: 1), // En tunn linje mellan varje
                itemBuilder: (context, index) {
                  final todo = _todos[index]; // Hämtar en todo i listan
                  return IgnorePointer(
                    child: ListTile(
                      leading: Icon(
                        todo.done
                            ? Icons.check_box // Ikon om klar
                            : Icons.check_box_outline_blank, // Ikon om inte klar
                      ),
                      title: Text(
                        todo.title,
                        style: TextStyle(
                          decoration: todo.done
                              ? TextDecoration.lineThrough // Överstruken om klar
                              : TextDecoration.none,
                          color: todo.done ? Colors.black54 : null,
                          fontSize: 18,
                        ),
                      ),
                      trailing: const Icon(Icons.close), // X-ikon till höger
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
