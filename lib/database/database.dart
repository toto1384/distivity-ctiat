import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../todo.dart';
import 'my_prefs.dart';


class TodoDatabase {

  String table = "todos";
  static TodoDatabase _todoDatabase ;

  DatabaseReference userReference;

  int idCount;
  Database _database;





  static Future<TodoDatabase> initAndGetDatabase(int deviceId,int idCount,FirebaseUser firebaseUser) async{
    if(_todoDatabase==null){
      _todoDatabase = TodoDatabase();
      _todoDatabase._database = await _todoDatabase._initDatabase();
      if(_todoDatabase._database==null){
        print("isnull");
      }
      _todoDatabase.idCount=idCount;


      //GET THE DATA

      //if the user isn't null that means that it is logged in
      print(firebaseUser);
      if(firebaseUser!=null){
        _todoDatabase.userReference=FirebaseDatabase.instance.reference().child("u").child(firebaseUser.uid);
        DataSnapshot fDevId =await  _todoDatabase.userReference.child("l").once();


        //if the last device that modified the database isn't this device id, update the database with new data;
        print(fDevId.value);
        print(deviceId);

        if(fDevId.value!=deviceId){
          _todoDatabase.userReference.child("l").set(deviceId);
          _todoDatabase.nukeAllFromDatabase();
          DataSnapshot todosDs =await  _todoDatabase.userReference.child("t").once();

          DataSnapshot dataSnapshot = await _todoDatabase.userReference.child("i").once();
          MyPrefs myPrefs = MyPrefs(await SharedPreferences.getInstance());
          myPrefs.setTodoId(dataSnapshot.value ?? 0);

          Batch dbBatch = _todoDatabase._database.batch();

          List<Todo> todosFromFirebase = List();
          Map mapFromFirebase = todosDs.value as Map ?? Map();
          mapFromFirebase.forEach((f,m){
            todosFromFirebase.add(Todo.fromMap(Map.from(m)));
          });

          todosFromFirebase.forEach((f){
            dbBatch.insert(_todoDatabase.table, f.toMap());
          });

          await dbBatch.commit();
        }
      }
    }
    //

    return _todoDatabase;

  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "TodoDatabase.db");
    return await openDatabase(path,
        version: 1,
        onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            i INTEGER PRIMARY KEY,
            n TEXT NOT NULL,
            c INTEGER NOT NULL,
            p INTEGER NOT NULL
          )
          ''');
  }
  
  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  insert(Todo todo) async {
    //DATABASE
    
    await _database.insert(table, todo.toMap());
    
    //FIREBASE
    if(userReference!=null){
      userReference.child("t").child(todo.id.toString()).set(todo.toMap());
    }
  }

  // All of the rows are returned as a list of maps, where each map is 
  // a key-value list of columns.
  Future<List<Todo>> querryTodos() async {
    if(_database==null){
      _database=await _initDatabase();
    }
    List<Map> maps =  await _database.query(table);
    return Todo.getTodosFromMap(maps);
  }



  update(Todo todo) async {
    //Database
     _database.update(table, todo.toMap(), where: 'i = ?', whereArgs: [todo.id]);
    //Firebase
    if(userReference!=null){
      userReference.child("t").child(todo.id.toString()).set(todo.toMap());
    }
  }

  // Deletes the row specified by the id. The number of affected rows is 
  // returned. This should be 1 as long as the row exists.
  delete(int id) async {
     await _database.delete(table, where: 'i = ?', whereArgs: [id]);

    //delete from firebase
    if(userReference!=null){
      userReference.child("t").child(id.toString()).remove();
    }
  }

  nukeAllFromDatabase()async{
    await _database.delete(table);
  }

  void nukeChecked() async{
     await _database.delete(table, where: 'c = ?', whereArgs: [1]);

    //delete from firebase
    if(userReference!=null){
    userReference.child("t").orderByChild('c').equalTo('1')
    .once().then((snapshot) {
        Map mapFromFirebase = snapshot as Map;
          mapFromFirebase.forEach((f,m){
            userReference.child("t").child(Todo.fromMap(Map.from(m)).id.toString()).remove();
          });
});
  }

  }

}


