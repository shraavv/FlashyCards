import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';
import '../db/database.dart';
import '../model/notes.dart';

class NotesPage extends StatefulWidget {
  final Subject subject;

  const NotesPage({required this.subject, Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  bool isLoading = false;
  late Map<String, List<String>> sectionNotes; // creating a list of contents
  late PageController _pageController; // to control (navigate) the pages in page view
  int currentPageIndex = 0; // this is for the the previous and next button

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    sectionNotes = {}; // initializing section notes
    refreshNotes();
  }

  void refreshNotes() async {
    setState(() => isLoading = true);

    // read notes(content) from the database
    final allNotes = await NotesDatabase.instance.readAllNotes();

    // to organize the notes by subjects
    sectionNotes = {};
    for (Note note in allNotes) { // iterates over each note allNotes
      if (!sectionNotes.containsKey(note.subject)) {
        sectionNotes[note.subject] = []; // empty list is added as value to the corresponding subject
      }
      sectionNotes[note.subject]!.add(note.content); // the content is added to the corresponding subject
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() { // this takes place when state object is permanently removed
    _pageController.dispose(); // important to dispose controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: size.height * 0.1,
        title: Text(
          "FlashyCards - ${widget.subject.subject}", // displays whatever subject was selected in home page
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.indigo[900],
        centerTitle: true,
        elevation: 0, // shadow beneath
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder( // used to create a scrollable list of widgets
              controller: _pageController, // to control the scrolling
              itemCount: sectionNotes[widget.subject.subject]?.length ?? 0, //specifies the number of items, if length is null then it defaults to 0
              onPageChanged: (index) {
                setState(() {
                  currentPageIndex = index; // changes the index to the new one after changes
                });
              },
              itemBuilder: (context, index) {
                String note = sectionNotes[widget.subject.subject]![index]; // retrieves the not of current index
                return cardFunc(note); // calls the card function, the note is then displayed there
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(56.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (currentPageIndex > 0) { // to navigate to previous pages
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 500), // speed at which the cards are swiped
                        curve: Curves.easeInOut, // basically an effect
                      );
                    }
                  },
                  child: const Text('Previous',
                  style:
                      TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      )
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (currentPageIndex < (sectionNotes[widget.subject.subject]?.length ?? 0) - 1) { // to navigate to next pages
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: const Text('Next',
                      style:
                      TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                          color: Colors.black
                      )
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.blueGrey[900],
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // allow the user to input content in the text field
          String? newNoteContent = await showDialog( // awaits user interaction with alert dialog
            context: context, // BuildContext is an object that holds information about the location of a widget
            builder: (BuildContext context) { // builder is used to construct various widgets
              TextEditingController controller = TextEditingController(); // to control the user input

              return AlertDialog(
                title: const Text('Enter Flashcard Content'),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Enter flashcard content...',
                  ),
                  maxLines: null,
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(null); // pop method is used to clos the dialog box
                    },
                    child: const Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Note newNote = Note(
                        content: controller.text,
                        subject: widget.subject.subject,
                      );
                      await NotesDatabase.instance.createNote(newNote);
                      refreshNotes(); // refresh the list of notes after creating a new note
                      setState(() {}); // trigger a widget rebuild
                      Navigator.of(context).pop(controller.text); // is used to close the current screen or dialog and return a result to the screen that initiated it
                    },
                    child: const Text('SAVE'),
                  ),
                ],
              );
            },
          );
          if (newNoteContent != null && newNoteContent.isNotEmpty) { // check if the user entered any content
            setState(() {
              sectionNotes[widget.subject.subject]?.add(newNoteContent); // create a new flashcard with the entered content
            });
          }
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget cardFunc(String note) {
    return Center(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
          side: const BorderSide(color: Colors.black, width: 5.0),
        ),
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: 350,
          height: 500,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isLatex(note)
                  ? TeXView(
                child: TeXViewDocument(note), // this method is for mathematical equations
                style: const TeXViewStyle.fromCSS(
                  'text-align: center; font-size: 27px;',
                ),
              )
                  : Text(
                note, // otherwise returns the text as it is
                style: const TextStyle(
                  fontSize: 27,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isLatex(String content) {
    return content.startsWith(r'\(') && content.endsWith(r'\)'); // checks whether the input is in latex form or not
  }
}
