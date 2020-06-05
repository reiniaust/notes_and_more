import 'package:firebase_database/firebase_database.dart';

class Entry {
  String key;
  String subject = "";
  bool completed = false;
  String userId;
  String date = "";
  String prio = "";
  String fromUser;
  String toUser;
  String state; // Status für offen, erledigt usw.

  Entry();

  Entry.fromSnapshot(DataSnapshot snapshot) :
    key = snapshot.key,
    subject = snapshot.value["subject"],
    completed = snapshot.value["completed"],
    date = snapshot.value["date"],
    prio = snapshot.value["prio"],
    fromUser = snapshot.value["fromUser"],
    toUser = snapshot.value["toUser"],
    state = snapshot.value["state"];

  toJson() {
    return {
      "userId": userId,
      "subject": subject,
      "completed": completed,
      "date": date,
      "prio": prio,
      "fromUser": fromUser,
      "toUser": toUser,
      "state": state,
    };
  }
}