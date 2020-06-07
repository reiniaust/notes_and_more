import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';

class EditPage extends StatefulWidget {
  EditPage(this.entry, this.eMailList, this.stateList, this.callback);

  //final String title;
  final Entry entry;
  final List<String> eMailList;
  final List<String> stateList;
  final void Function(Entry) callback;

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _textEditingController = TextEditingController();

  final _dateEditingController = TextEditingController();

  final _prioEditingController = TextEditingController();

  final _toUserEditingController = TextEditingController();

  final _stateEditingController = TextEditingController();

    void callDatePicker() async {
      var date = await getDate();
      //setState(() {
        var formatter = new DateFormat('yyyy-MM-dd');
        _dateEditingController.text = formatter.format(date);
      //});
    }

    Future<DateTime> getDate() {
      // Imagine that this function is
      // more complex and slow.
      return showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2018),
        lastDate: DateTime(2030),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.light(),
            child: child,
          );
        },
      );
    }

  @override
  Widget build(BuildContext context) {
    _textEditingController.text = widget.entry.subject;
    _dateEditingController.text = widget.entry.date;
    _prioEditingController.text = widget.entry.prio;
    _toUserEditingController.text = widget.entry.toUser;
    _stateEditingController.text = widget.entry.state;

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                widget.entry.subject = _textEditingController.text;
                widget.entry.date = _dateEditingController.text;
                widget.entry.prio = _prioEditingController.text;
                widget.entry.toUser = _toUserEditingController.text;
                widget.entry.state = _stateEditingController.text;
                widget.callback(widget.entry);
                Navigator.of(context).pop();
              }),
          //title: Text(title),
        ),
        body: Column(
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
              suggestions: widget.eMailList,
            )),
            Expanded(
              child: TextField(
                controller: _dateEditingController,
                decoration: InputDecoration(
                  labelText: 'Termin (JJJJ-MM-TT HH:MM)',
                ),
                onTap: () {
                  callDatePicker();
                }
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
            Expanded(
                child: SimpleAutoCompleteTextField(
              key: null,
              controller: _stateEditingController,
              decoration: InputDecoration(
                labelText: 'Status',
              ),
              onFocusChanged: (hasfocus) {
                if (hasfocus) {
                  //_toUserEditingController.text = "";
                }
              },
              suggestions: widget.stateList,
            )),
          ],
        ));
  }
}
