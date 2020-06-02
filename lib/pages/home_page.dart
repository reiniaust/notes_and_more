import 'package:flutter/material.dart';
import 'package:notes_and_more/pages/edit_page.dart';
import '../services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/entry.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  HomePage(
      {Key key, this.auth, this.userId, this.userEmail, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final String userEmail;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Entry> _todoList;
  List<Entry> _searchList;
  final List<String> _eMailList = [];

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _searchEditingController = TextEditingController();
  //DateTime _dateInput;
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;

  Query _todoQuery;

  @override
  void initState() {
    super.initState();

    _todoList = new List();
    _todoQuery = _database
        .reference()
        .child("notesandmore-943e9"); //.orderByChild("date").equalTo();
    _onTodoAddedSubscription = _todoQuery.onChildAdded.listen(onEntryAdded);
    _onTodoChangedSubscription =
        _todoQuery.onChildChanged.listen(onEntryChanged);
  }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
  }

  onEntryChanged(Event event) {
    Entry e = Entry.fromSnapshot(event.snapshot);

    var oldEntry = _todoList.singleWhere((entry) {
      return entry.key == e.key;
    });

    if (oldEntry == null &&
        e.toUser.toUpperCase() == widget.userEmail.toUpperCase()) {
      _todoList.add(e);
    } else {
      _todoList[_todoList.indexOf(oldEntry)] =
          Entry.fromSnapshot(event.snapshot);
    }
    sortList();
  }

  onEntryAdded(Event event) {
    Entry e = Entry.fromSnapshot(event.snapshot);

    if (e.userId == widget.userId ||
        e.fromUser == widget.userEmail ||
        e.toUser.toUpperCase() == widget.userEmail.toUpperCase()) {
      _todoList.add(e);
      sortList();
    }
  }

  // Nach Unerledigt+Termin sortieren
  void sortList() {
    //_todoList = _todoList.where((e) => e?.fromUser == widget.userEmail || e.toUser.toUpperCase() == widget.userEmail.toUpperCase());
    _todoList.sort((a, b) => (a.completed.toString() + a.date + " " + a.subject)
        .compareTo(b.completed.toString() + b.date + " " + b.subject));
    setState(() {
      _searchList = _todoList;
    });
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  //addNewTodo(String subject, String date, String prio) {
  addNewEntry(Entry entry) {
    print("hallo");
    if (entry.subject.length > 0) {
      //Entry entry = new Entry(subject.toString(), widget.userId, false, date, prio);
      _database
          .reference()
          .child("notesandmore-943e9")
          .push()
          .set(entry.toJson());
    }
  }

  updateEntry(Entry entry) {
    //Toggle completed
    if (entry != null) {
      _database
          .reference()
          .child("notesandmore-943e9")
          .child(entry.key)
          .set(entry.toJson());
    }
  }

  deleteTodo(String entryId, int index) {
    _database
        .reference()
        .child("notesandmore-943e9")
        .child(entryId)
        .remove()
        .then((_) {
      print("$entryId gelöscht");
      setState(() {
        _todoList.removeAt(index);
        _searchList = _todoList;
      });
    });
  }


  Widget showTodoList() {
    if (_todoList.length > 0) {
      _todoList.forEach((e) {
        if (e.toUser != null && !_eMailList.contains(e.toUser)) {
          _eMailList.add(e.toUser);
        }
      });

      return ListView.builder(
          shrinkWrap: true,
          itemCount: _searchList.length,
          itemBuilder: (BuildContext context, int index) {
            Entry e = _searchList[index];
            return Dismissible(
              key: Key(e.key),
              background: Container(color: Colors.red),
              onDismissed: (direction) async {
                deleteTodo(e.key, index);
              },
              child: ListTile(
                title: Text(
                  e.subject,
                  style: TextStyle(
                      color: e.prio == 'hoch' ? Colors.red : Colors.black),
                ),
                subtitle: Text(
                    (e.fromUser != null && e.fromUser != widget.userEmail
                            ? "von: " + e.fromUser + "  "
                            : "") +
                        (e.toUser != "" && e.toUser != widget.userEmail
                            ? "an: " + e.toUser + "  "
                            : "") +
                        (e.date.isEmpty ? "" : "Termin: " + e.date + " ")),
                trailing: IconButton(
                    icon: (e.completed)
                        ? Icon(
                            Icons.done_outline,
                            color: Colors.green,
                          )
                        : Icon(Icons.done, color: Colors.grey),
                    onPressed: () {
                      e.completed = !e.completed;
                      updateEntry(e);
                    }),
                onTap: () {
                  // Zur Ändern-Seite
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EditPage(e, _eMailList, updateEntry)),
                  );
                  //showAddOrEditDialog(context, e, true);
                },
                /*
                onLongPress: () {
                  showAddOrEditDialog(context, e,
                      false); // Zuständige Person und Priorität eingeben
                },
                */
              ),
            );
          });
    } else {
      return Center(
          child: Text(
        "Willkommen",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new TextField( // Suchen
            controller: _searchEditingController,
            decoration: InputDecoration(
              labelText: 'Notes & More',
              prefixIcon: Icon(Icons.search),
              /*
              suffixIcon: IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    _searchEditingController.clear();
                  }),*/
            ),
            style: TextStyle(color: Colors.white),
            onChanged: (s) {
              setState(() {
                _searchList = _todoList
                    .where((e) =>
                        e.subject.toUpperCase().contains(s.toUpperCase()))
                    .toList();
              });
            },
          ), //
          actions: <Widget>[
            new FlatButton(
                child: new Text('Abmelden',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: signOut)
          ],
        ),
        body: showTodoList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Entry entry = Entry();
            entry.subject = "";
            entry.fromUser = widget.userEmail;
            entry.toUser = widget.userEmail;
            // zur Hinzufügen-Seite
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EditPage(entry, _eMailList, addNewEntry)),
            );
            //showAddOrEditDialog(context, null, true);
          },
          tooltip: 'Hinzufügen',
          child: Icon(Icons.add),
        ));
  }
}
