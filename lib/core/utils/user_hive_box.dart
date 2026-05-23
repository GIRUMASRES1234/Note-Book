import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

class UserHiveBox {
  // box name depends on logged in user
  static String get notesBoxName {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");
    return "notesBox_$uid";
  }

  // ✅ OPEN BOX (this is what your error needs)
  static Future<void> openNotesBox() async {
    final name = notesBoxName;

    if (!Hive.isBoxOpen(name)) {
      await Hive.openBox(name);
    }
  }

  // get opened box
  static Box getNotesBox() {
    return Hive.box(notesBoxName);
  }

  // close box (optional, useful for logout)
  static Future<void> closeNotesBox() async {
    final name = notesBoxName;

    if (Hive.isBoxOpen(name)) {
      await Hive.box(name).close();
    }
  }
}
