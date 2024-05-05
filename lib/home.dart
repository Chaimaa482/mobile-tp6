import 'package:flutter/material.dart';
import 'package:notes_app/databse.dart';
import 'package:notes_app/notedeails.dart';

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  dynamic selectedNote;
  late int index;
  SqlDb sqlDb = SqlDb();
  List<Map> notes = [];

  @override
  initState() {
    print('app started');
    getNotes();
    super.initState();
  }

  Future<void> getNotes() async {
    List<Map> fetchedNotes = await sqlDb.readData("SELECT * FROM 'notes'");
    setState(() {
      notes = fetchedNotes;
    });
    print(notes);
  }

  @override
  Widget build(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final int maxCharacters = isLandscape ? 15 : 10;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 243, 231, 255),
        title: const Text('Notes'),
      ),
      body: isLandscape
          ? Row(
              children: [
                Expanded(
                  flex: 1,
                  child: notesListWidget(notes, maxCharacters, isLandscape),
                ),
                Expanded(
                  flex: 1,
                  child: selectedNote != null
                      ? NoteDetailsScreen(note: selectedNote!)
                      : const Text(''),
                ),
              ],
            )
          : notesListWidget(notes, maxCharacters, isLandscape),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              String noteContent = '';
              return AlertDialog(
                title: const Text('Add Note'),
                content: TextField(
                  onChanged: (value) {
                    noteContent = value;
                  },
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      print('gonna add');
                      if (noteContent.isNotEmpty) {
                        await sqlDb.insertData(
                            "INSERT INTO 'notes' ('content', 'dateTime') VALUES ('$noteContent', '${DateTime.now()}')");
                        Navigator.of(context).pop();
                      }
                      getNotes();
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, int id, bool isLandscape) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Note"),
          content: const Text("You really want to delete this note ?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                int response = await sqlDb
                    .deleteData("DELETE FROM 'notes' WHERE id = $id ");
                print(response);
                getNotes();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Note Deleted")),
                );
                if (isLandscape) {
                  selectedNote = null;
                }
              },
              child: const Text("Delele"),
            ),
          ],
        );
      },
    );
  }

  Widget notesListWidget(List<Map> notes, int maxCharacters, bool isLandscape) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            isLandscape
                ? setState(() {
                    selectedNote = notes[index];
                  })
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteDetailsScreen(
                        note: notes[index],
                      ),
                    ),
                  );
          },
          onLongPress: () {
            selectedNote = notes[index];
            print(selectedNote['id']);
            _showDeleteConfirmationDialog(
                context, selectedNote['id'], isLandscape);
            setState(() {});
          },
          leading: const Image(image: AssetImage('assets/girl.png')),
          title: const Text('Belbachir Chaimaa'),
          subtitle: Text(
            notes[index]['content'].length <= maxCharacters
                ? notes[index]['content']
                : '${notes[index]['content'].substring(0, maxCharacters)}...',
            style: const TextStyle(
                fontSize: 14, color: Color.fromARGB(255, 119, 119, 119)),
          ),
        );
      },
    );
  }
}
