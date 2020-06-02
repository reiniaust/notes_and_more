import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import '../models/entry.dart';

class EditPage extends StatelessWidget {
  EditPage(this.entry, this.eMailList, this.callback);

  //final String title;
  final Entry entry;
  final List<String> eMailList;
  final void Function(Entry) callback;

  final _textEditingController = TextEditingController();
  final _dateEditingController = TextEditingController();
  final _prioEditingController = TextEditingController();
  final _toUserEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _textEditingController.text = entry.subject;
    _dateEditingController.text = entry.date;
    _prioEditingController.text = entry.prio;
    _toUserEditingController.text = entry.toUser;

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                print("2");
                entry.subject = _textEditingController.text;
                entry.date = _dateEditingController.text;
                entry.prio = _prioEditingController.text;
                entry.toUser = _toUserEditingController.text;
                callback(entry);
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
              suggestions: eMailList,
            )),
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
        ));
  }
}
