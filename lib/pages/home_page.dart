import 'package:flutter/material.dart';
import '../services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/entry.dart';
import 'dart:async';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.userEmail, this.logoutCallback})
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

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
    _todoQuery =
        _database.reference().child("notesandmore-943e9"); //.orderByChild("date").equalTo();
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
    var oldEntry = _todoList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _todoList[_todoList.indexOf(oldEntry)] =
          Entry.fromSnapshot(event.snapshot);
      sortList();
    });
  }

  onEntryAdded(Event event) {
    setState(() {
      Entry e = Entry.fromSnapshot(event.snapshot);

      ///e.old = false;
      if (e.userId == null || e.userId == widget.userId || e.toUser == widget.userEmail) {
        _todoList.add(e);
        sortList(); // neu nach Termin sortieren (13.5.)
      }
    });
  }

  void sortList() {
    //_todoList = _todoList.where((e) => e.userId == widget.userId);
    _todoList.sort((a, b) => (a.completed.toString() + a.date).compareTo(
        b.completed.toString() + b.date)); // neu nach Termin sortieren (13.5.)
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
  addNewTodo(Entry entry) {
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
      });
    });
  }

  showAddOrEditDialog(
      BuildContext context, Entry entry, bool titleAndDate) async {
    if (entry == null) {
      // wenn neuer Eintrag
      _textEditingController.clear();
      entry = Entry();
    } else {
      _textEditingController.text = entry.subject;
      _dateEditingController.text = entry.date;
      _prioEditingController.text = entry.prio;
      _toUserEditingController.text = entry.toUser;
    }

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
                        child: TextField(
                          controller: _dateEditingController,
                          decoration: InputDecoration(
                            labelText: 'Termin (JJJJ-MM-TT HH:MM)',
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: <Widget>[
                      Expanded(
                          child: SimpleAutoCompleteTextField(
                        key: null,                          controller: _toUserEditingController,
                          decoration: InputDecoration(
                            labelText: 'Zuständig',
                          ),
                        suggestions: eMailList,
                      )),
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
          itemCount: _todoList.length,
          itemBuilder: (BuildContext context, int index) {
            Entry e = _todoList[index];
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
                      fontWeight: _todoList[index].prio == 'hoch'
                          ? FontWeight.bold
                          : FontWeight.normal),
                ),
                subtitle: Text((e.date == null
                        ? ""
                        : e.date +
                            " ") //+ e.toUser == null ? "" : e.toUser  // + _todoList[index].newBold?.toString()
                    ),
                trailing: IconButton(
                    icon: (e.completed)
                        ? Icon(
                            Icons.done_outline,
                            color: Colors.green,
                          )
                        : Icon(Icons.done, color: Colors.grey),
                    onPressed: () {
                      _todoList[index].completed = !_todoList[index].completed;
                      updateEntry(_todoList[index]);
                    }),
                onTap: () {
                  showAddOrEditDialog(context, _todoList[index], true);
                },
                onLongPress: () {
                  showAddOrEditDialog(context, _todoList[index],
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
          title: new Text('Notes & More'),
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
            showAddOrEditDialog(context, null, true);
          },
          tooltip: 'Hinzufügen',
          child: Icon(Icons.add),
        ));
  }
}
