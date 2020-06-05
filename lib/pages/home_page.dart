import 'package:flutter/material.dart';
import '../services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/entry.dart';
import 'dart:async';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

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
<<<<<<< HEAD
  final List<String> _eMailList = [];
  final List<String> _stateList = ["Ungelesen", "Offen", "Erledigt", "Verworfen"];
=======
>>>>>>> parent of f607099... Extra Seite zum Editieren (Hinzufügen und Ändern)

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _searchEditingController = TextEditingController();
  final _textEditingController = TextEditingController();
  final _dateEditingController = TextEditingController();
  final _prioEditingController = TextEditingController();
  final _toUserEditingController = TextEditingController();
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

<<<<<<< HEAD
  addNewEntry(Entry entry) {
    print("hallo");
=======
  //addNewTodo(String subject, String date, String prio) {
  addNewTodo(Entry entry) {
>>>>>>> parent of f607099... Extra Seite zum Editieren (Hinzufügen und Ändern)
    if (entry.subject.length > 0) {
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

  showAddOrEditDialog(
      BuildContext context, Entry entry, bool titleAndDate) async {
    if (entry == null) {
      // wenn neuer Eintrag
      entry = Entry();
      /*
      if (_textEditingController.text.contains(":")) {
        entry.subject = _textEditingController.text.split(":")[0] + ": ";
      }
      */
      entry.fromUser = widget.userEmail;
      entry.toUser = widget.userEmail;
    }
    _textEditingController.text = entry.subject;
    _dateEditingController.text = entry.date;
    _prioEditingController.text = entry.prio;
    _toUserEditingController.text = entry.toUser;

    final List<String> eMailList = [];
    _todoList.forEach((e) {
      if (e.toUser != null && !eMailList.contains(e.toUser)) {
        eMailList.add(e.toUser);
      }
    });

    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: titleAndDate
                ? Column(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _textEditingController,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: 'Eintrag',
                          ),
                        ),
                      ),
                      Expanded(
                          child: SimpleAutoCompleteTextField(
                        key: null,
                        controller: _toUserEditingController,
                        decoration: InputDecoration(
                          labelText: 'Zuständig',
                        ),
                        onFocusChanged: (hasfocus) {
                          if (hasfocus) {
                            _toUserEditingController.text = "";
                          }
                        },
                        suggestions: eMailList,
                      )),
                    ],
                  )
                : Column(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _dateEditingController,
                          decoration: InputDecoration(
                            labelText: 'Termin (JJJJ-MM-TT HH:MM)',
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _prioEditingController,
                          decoration: InputDecoration(
                            labelText: 'Priorität (z.B. hoch)',
                          ),
                        ),
                      ),
                    ],
                  ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Abbrechen'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Speichern'),
                  onPressed: () {
                    entry.subject = _textEditingController.text.toString();
                    entry.date = _dateEditingController.text.toString();
                    entry.prio = _prioEditingController.text.toString();
                    entry.completed = false;
                    entry.toUser = _toUserEditingController.text.toString();
                    if (entry.key == null) {
                      // wenn neuer Eintrag
                      addNewTodo(entry);
                    } else {
                      updateEntry(entry);
                    }
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  Widget showTodoList() {
    if (_todoList.length > 0) {
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
                      color: e.prio == 'hoch'
                          ? Colors.red
                          : Colors.black),
                ),
                subtitle: Text(
                    (e.fromUser != null && e.fromUser != widget.userEmail
                            ? "von: " + e.fromUser + "  "
                            : "") +
                        (e.toUser != "" && e.toUser != widget.userEmail
                            ? "an: " + e.toUser + "  "
                            : "") +
                        (e.date.isEmpty ? "" : "Termin: " + e.date + " ") +
                        (e.state.isEmpty ? "" : e.state + " ")
                    ),
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
<<<<<<< HEAD
                  // Zur Ändern-Seite
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EditPage(e, _eMailList, _stateList, updateEntry)),
                  );
                  //showAddOrEditDialog(context, e, true);
=======
                  showAddOrEditDialog(context, e, true);
>>>>>>> parent of f607099... Extra Seite zum Editieren (Hinzufügen und Ändern)
                },
                onLongPress: () {
                  showAddOrEditDialog(context, e,
                      false); // Zuständige Person und Priorität eingeben
                },
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
          title: new TextField(
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
<<<<<<< HEAD
            Entry entry = Entry();
            entry.subject = "";
            entry.fromUser = widget.userEmail;
            entry.toUser = widget.userEmail;
            // zur Hinzufügen-Seite
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EditPage(entry, _eMailList, _stateList, addNewEntry)),
            );
            //showAddOrEditDialog(context, null, true);
=======
            showAddOrEditDialog(context, null, true);
>>>>>>> parent of f607099... Extra Seite zum Editieren (Hinzufügen und Ändern)
          },
          tooltip: 'Hinzufügen',
          child: Icon(Icons.add),
        ));
  }
}
