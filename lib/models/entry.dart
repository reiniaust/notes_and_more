import 'package:firebase_database/firebase_database.dart';

class Entry {
  String key;
  String subject;
  bool completed;
  String userId;
  String date;
  String prio;
  String fromUser;
  String toUser;

  Entry();
  //Entry(this.subject, this.userId, this.completed, this.date, this.prio, this.toUser);

  Entry.fromSnapshot(DataSnapshot snapshot) :
    key = snapshot.key,
    subject = snapshot.value["subject"],
    completed = snapshot.value["completed"],
    date = snapshot.value["date"],
    prio = snapshot.value["prio"],
    fromUser = snapshot.value["fromUser"],
    toUser = snapshot.value["toUser"];

  toJson() {
    return {
      "userId": userId,
      "subject": subject,
      "completed": completed,
      "date": date,
      "prio": prio,
      "fromUser": fromUser,
      "toUser": toUser,
    };
  }
}