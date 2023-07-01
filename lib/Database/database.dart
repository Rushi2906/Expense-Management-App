import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DatabaseHelper{

  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper();

  Future<Database?> get database async {
    _database ?? await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String databasePath = join(appDocDir.path, 'expense_app.db');
    return await openDatabase(databasePath);
  }

  Future<bool> copyPasteAssetFileToRoot() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "expense_app.db");

    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      ByteData data = await rootBundle.load(join('assets/database', 'expense_app.db'));
      List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);
      return true;
    }
    return false;
  }

  Future<List<Map<String, Object?>>> getCategoryFromCategoryTable() async {
    Database db = await initDatabase();
    List<Map<String, Object?>> data = await db.rawQuery('SELECT * FROM Category');
    print(data);
    return data;
  }

  Future<List<Map<String, Object?>>> getPaymentMode() async {
    Database db = await initDatabase();
    List<Map<String, Object?>> data = await db.rawQuery('SELECT * FROM Mode');
    return data;
  }

  Future<List<Map<String, Object?>>> getTransfer() async{
    Database? db = await initDatabase();
    List<Map<String, Object?>> data = await db.rawQuery('Select * from Transfer T inner join Category C on T.Category_id=C.Category_id inner join Mode M on T.Mode_Id=M.Mode_Id');
    return data;
  }

  Future<void> insertDatabase(Map map) async {
    Database db = await initDatabase();
    await db.rawInsert('INSERT INTO Transfer VALUES('
        '${map['Transfer_Id']}, '
        '${map['Transfer_Type']},'
        '"${map['Transfer_Date']}", '
        '${map['Transfer_Amount']},'
        '"${map['Transfer_Note']}",'
        '${map['Category_Id']},'
        '${map['Mode_Id']})'
    );
  }

  Future<int> updateTransferDetail(map,id) async {
    Database db = await initDatabase();
    int userID =
    await db.update("Transfer", map, where: "Transfer_Id = ?", whereArgs: [id]);
    return userID;
  }

  Future<int> deleteTransferId(id) async{
    Database db = await initDatabase();
    int userId = await db.delete("Transfer",where: "Transfer_Id = ?",whereArgs: [id]);
    return userId;
  }

  Future<List<Map<String,dynamic>>> sumOfExpense() async{
    Database db = await initDatabase();
    List<Map<String,dynamic>> amountExpense = await db.rawQuery('Select sum(T.Transfer_Amount) as totalExpense from Transfer T inner join Category C on T.Category_id=C.Category_id inner join Mode M on T.Mode_Id=M.Mode_Id where T.Transfer_Type=0');
    print(amountExpense);
    return amountExpense;
  }

  Future<List<Map<String,dynamic>>> sumOfIncome() async{
    Database db = await initDatabase();
    List<Map<String,dynamic>> amountIncome = await db.rawQuery('Select sum(T.Transfer_Amount) as totalIncome from Transfer T inner join Category C on T.Category_id=C.Category_id inner join Mode M on T.Mode_Id=M.Mode_Id where T.Transfer_Type=1');
    print(amountIncome);
    return amountIncome;
  }

  Future<List<Map<String,dynamic>>> sumOfBalance() async{
    Database db = await initDatabase();
    List<Map<String,dynamic>> amountBalance = await db.rawQuery('select (select sum(Transfer_Amount) as income from Transfer where Transfer_Type=1) - (select sum(Transfer_Amount) as expense from Transfer where Transfer_Type=0) as balance from Transfer');
    print(amountBalance);
    return amountBalance;
  }

  Future<List<Map<String, Object?>>> dateWiseFilter(dateTime) async {
    Database db = await initDatabase();
    print("dateTime : $dateTime");
    List<Map<String, Object?>> data = await db.rawQuery('Select * from Transfer T inner join Category C on T.Category_id=C.Category_id inner join Mode M on T.Mode_Id=M.Mode_Id where T.Transfer_Date= ?',[dateTime]);
    print("data : $data");
    return data;
  }

  Future<List<Map<String, Object?>>> monthWiseFilter(year,month) async {
    Database db = await initDatabase();
    List<Map<String, Object?>> data = await db.rawQuery("select * from Transfer T inner join Category C on T.Category_id=C.Category_id inner join Mode M on T.Mode_Id=M.Mode_Id where substr(T.Transfer_Date,4,2)='$month' AND substr(T.Transfer_Date,7,4)='$year'");
    print("data : $data");
    return data;
  }

  Future<List<Map<String, Object?>>> yearWiseFilter(year) async {
    Database db = await initDatabase();
    List<Map<String, Object?>> data = await db.rawQuery("select * from Transfer T inner join Category C on T.Category_id=C.Category_id inner join Mode M on T.Mode_Id=M.Mode_Id where substr(T.Transfer_Date,7,4)='$year'");
    print("data : $data");
    return data;
  }
  // Future<List<Map<String, Object?>>> yearWiseFilter(start,end) async {
  //   Database db = await initDatabase();
  //   var start_date=DateFormat('yyyy-MM-dd').format(start);
  //   var end_date=DateFormat('yyyy-MM-dd').format(end);
  //   print("start : $start_date");
  //   print("end : $end_date");
  //   List<Map<String, Object?>> data = await db.rawQuery("select * from Transfer where substr(Transfer_Date,7)||substr(Transfer_Date,4,2)||substr(Transfer_Date,1,2) BETWEEN substr($start_date,7)||substr($start_date,4,2)||substr($start_date,1,2) AND substr($end_date,7)||substr($end_date,4,2)||substr($end_date,1,2)");
  //   print("data : $data");
  //   return data;
  // }
}