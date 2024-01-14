import 'package:flutter/material.dart';
import 'package:flashcard/model/notes.dart';
import 'notes.dart';
import 'package:flashcard/db/database.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key); // represents the constructor for homepage

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;
  late List<Subject> subjects = []; // to maintain a list of subjects
  List<Widget> sliverLists = []; // to maintain a list of lists (cards basically)

  @override
  void initState() {
    super.initState();
    refreshSubject();
    // as soon as the widget is made, this is executed (ig)
  }

  Future refreshSubject() async {
    setState(() => isLoading = true); // when data is getting fetched, it's true

    // read all the subjects from the database
    final allSubjects = await NotesDatabase.instance.readAllSubjects();

    // exclude the default subjects
    subjects = allSubjects.where((subject) => subject.subject != 'New Subject' && subject.subject.isNotEmpty).toList();

    setState(() => isLoading = false); // when data data fetching is completed, it's false

    // this is used to update the subjects list (the async keyword is used which allows us to use await inside the function)
  }

  // build is responsible for constructing the UI of the widget based on its current configuration and state

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // used to obtain the size of the screen
    final widthPadding = size.width * 0.025;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: size.height * 0.1,
        title: const Text(
          "FlashyCards",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.indigo[900],
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.only(left: widthPadding, right: widthPadding),
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              floating: true,
              title: Text(
                "Welcome to FlashyCards :)",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                ),
              ),
              backgroundColor: Colors.black,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return Container(
                    height: 200,
                    margin:const EdgeInsets.only(top:6.0 ,bottom: 6.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      title: Text(
                        "SUBJECT: ${subjects.length > index ? subjects[index].subject : ''}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NotesPage(subject: subjects[index])),
                          // to redirect the page to flashcards and to pass in the subject name too
                        );
                      },
                    ),
                  );
                },
                childCount: subjects.length, // the number of sliver lists is equal to the number of elements in the list subject
              ),
            ),
            ...sliverLists, // to display the other sliver lists when created
          ],
        ),
      ),
      backgroundColor: Colors.blueGrey[900],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createList();
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void createList() {
    String newSubject = '';

    sliverLists.add(
      SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            return Container(
              height: 200,
              margin: const EdgeInsets.only(bottom: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // to align the children along the main axis of the container
                children: [
                  TextField(
                    onChanged: (value) {
                      newSubject = value; // to store the user input value
                    },
                    maxLength: 30,
                    decoration: const InputDecoration(
                      labelText: 'Type in a subject name.....',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  Text(
                    "SUBJECT: $newSubject",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await NotesDatabase.instance.createSubject(Subject(subject: newSubject),); // create a new subject in the database with the user input
                      await refreshSubject(); // to refresh the subjects
                      setState(() {}); // used to update the state of the widget
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.black), // the button will be black in color
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // the text inside the button will be white in color
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.all(10)),
                      textStyle: MaterialStateProperty.all<TextStyle>(
                        const TextStyle(fontSize: 18),
                      ),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // for rounded corners of sliver list
                        ),
                        // this is for the styling the button
                      ),
                    ),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          },
          childCount: 1,
        ),
      ),
    );
    setState(() {});
  }
}
