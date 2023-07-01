import 'package:expense_manager_app/Database/database.dart';
import 'package:expense_manager_app/Pages/display_category.dart';
import 'package:expense_manager_app/Pages/payment_mode_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class Add_Page extends StatefulWidget {

  Add_Page(this.map,{super.key});
  Map<String, Object?>? map;

  @override
  State<Add_Page> createState() => _Add_PageState();
}

class _Add_PageState extends State<Add_Page> {
  DatabaseHelper? db = DatabaseHelper();
  var transfer_type=1;
  var currentTab = 0;
  var categoryId;
  var paymentId;

  final int income=0;
  final int spending=0;
  final int balance=0;

  DateTime? pickedDate;
  DateTime? today = DateTime.now();
  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController paymentModeController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    noteController.text = widget.map == null ? "" : widget.map!['Transfer_Note'].toString();
    dateController.text = widget.map == null ? "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}" : widget.map!['Transfer_Date'].toString();
    amountController.text = widget.map == null ? 0.toString() : widget.map!["Transfer_Amount"].toString();
    categoryController.text = widget.map == null ? "" : widget.map!["Category_Name"].toString();
    paymentModeController.text = widget.map == null ? "" : widget.map!["Mode_Type"].toString();
    transfer_type = widget.map == null ? 0 : int.parse(widget.map!["Transfer_Type"].toString());
  }


  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Add transaction"),
          leading: InkWell(onTap:() {
            Navigator.pop(context);
          },child: Icon(Icons.arrow_back)),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async{
            await DatabaseHelper().insertDatabase({
              'Transfer_Type':transfer_type,
              'Transfer_Date':dateController.text.toString(),
              'Transfer_Amount':amountController.text,
              'Transfer_Note':noteController.text.toString(),
              'Category_Id':categoryId,
              'Mode_Id':paymentId
            }).then((value){
              setState(() {
                DatabaseHelper().getTransfer();
              });
            });
            Navigator.of(context).pop();
          },
          backgroundColor: Colors.deepOrange,
          child: Icon(Icons.file_open),
        ),
        body: Column(
          children: [
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width / 2,
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey,
                ),
                height: 40,
                child: Row(
                  children: [
                    InkWell(
                        onTap: () {
                          currentTab = 0;
                          transfer_type=0;
                          setState(() {});
                        },
                        child: currentTab == 0
                            ? Container(
                                width: MediaQuery.of(context).size.width / 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: Center(child: Text("Expense")))
                            : Container(
                                width: MediaQuery.of(context).size.width / 4,
                                child: Center(child: Text("Expense")))),
                    InkWell(
                        onTap: () {
                          currentTab = 1;
                          transfer_type=1;
                          setState(() {});
                        },
                        child: currentTab == 1
                            ? Container(
                                width: MediaQuery.of(context).size.width / 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: Center(child: Text("Income")))
                            : Container(
                                width: MediaQuery.of(context).size.width / 4,
                                child: Center(child: Text("Income")))),
                  ],
                ),
              ),
            ),
            Divider(
              height: 20,
              thickness: 1,
              color: Colors.grey,
            ),

            //DatePicker
            Container(
              margin: EdgeInsets.only(left: 20,right: 20,top: 10),
              height: MediaQuery.of(context).size.height / 20,
              // color: Colors.grey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: dateController,
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    decorationThickness: 0
                  ),
                  decoration: InputDecoration(
                    icon: Icon(Icons.calendar_today),
                    border: InputBorder.none
                  ),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    pickedDate = await showDatePicker(
                      context: context,
                      initialDate: new DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      print(pickedDate);
                      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate!);
                      print("formateddate : $formattedDate");
                      setState(() {
                        dateController.text = formattedDate;
                      });
                    } else {
                      print("Date is not selected");
                    }
                  },
                ),
              ),
            ),

            //Amount Controller
            Container(
              margin: EdgeInsets.only(top: 10,left: 20,right: 20),
              height: MediaQuery.of(context).size.height / 15,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      child: Icon(Icons.currency_rupee),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Container(
                      margin: EdgeInsets.only(left: 5),
                      child: TextField(
                        controller: amountController,
                        decoration: InputDecoration(
                          labelText: "Amount",
                          // hintText: "Amount"
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ],
              )
            ),

            //Category Selector
            Container(
              margin: EdgeInsets.only(top: 10,left: 20,right: 20),
              height: MediaQuery.of(context).size.height / 15,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      child: Icon(Icons.category),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      child: TextField(
                        controller: categoryController,
                        decoration: InputDecoration(
                          labelText: "Category"
                        ),
                        readOnly: true,
                        onTap: () async{
                          final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => DisplayCategory(),));
                          setState(() {
                            print(result.toString());
                            categoryController.text = result['name'].toString();
                            print(categoryController.text);
                            categoryId = result['id'].toString();
                            print(categoryId);
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(child: Container(child: InkWell(onTap:()async{
                    final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => DisplayCategory(),));
                    setState(() {
                      print(result.toString());

                    });
                  },child: Icon(Icons.chevron_right)),))
                ],
              ),
            ),

            //Payment Mode
            Container(
              margin: EdgeInsets.only(top: 10,left: 20,right: 20),
              height: MediaQuery.of(context).size.height / 15,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      child: Icon(Icons.chrome_reader_mode),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      child: TextField(
                        controller: paymentModeController,
                        decoration: InputDecoration(
                            labelText: "Payment Mode"
                        ),
                        readOnly: true,
                        onTap: () async{
                          final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => DisplayMode(),));
                          print(result.toString());
                          paymentModeController.text = result['name'].toString();
                          print(paymentModeController.text);
                          paymentId = result['id'].toString();
                          print(paymentId);
                        },
                      ),
                    ),
                  ),
                  Expanded(child: Container(child: InkWell(onTap:() {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => DisplayMode(),));
                  },child: Icon(Icons.chevron_right)),))
                ],
              ),
            ),

            //Note
            Container(
              margin: EdgeInsets.only(top: 10,left: 20,right: 20),
              height: MediaQuery.of(context).size.height / 15,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      child: Icon(Icons.note),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(
                      child: TextField(
                        controller: noteController,
                        decoration: InputDecoration(
                            labelText: "Note"
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //Edit and Delete
            Container(
              margin: EdgeInsets.all(30),
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    height: MediaQuery.of(context).size.height / 20,
                    width: MediaQuery.of(context).size.width / 3,
                    color: Colors.green,
                    child: TextButton(
                      onPressed: () {
                          updateTransfer(widget.map!["Transfer_Id"]).then((value) => Navigator.of(context).pop());
                      },
                      child: Text("Edit",style: TextStyle(color: Colors.white,fontSize: 20),),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    height: MediaQuery.of(context).size.height / 20,
                    width: MediaQuery.of(context).size.width / 3,
                    color: Colors.red,
                    child: TextButton(
                      onPressed: () {
                          deleteTransfer(widget.map!["Transfer_Id"]).then((value) => Navigator.of(context).pop());
                      },
                      child: Text("Delete",style: TextStyle(color: Colors.white,fontSize: 20),),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<int> updateTransfer(id) async{
    Map<String,dynamic> map = {};
    map['Transfer_Type']=transfer_type;
    map['Transfer_Date']=dateController.text;
    map['Transfer_Amount']=amountController.text;
    map['Transfer_Note']=noteController.text;
    map['Category_id']=categoryId==null?widget.map!["Category_id"]:categoryId.toString();
    map['Mode_Id']=paymentId==null?widget.map!["Mode_Id"]:paymentId.toString();

    int userID = await DatabaseHelper().updateTransferDetail(map, id);
    return userID;
  }

  Future<int> deleteTransfer(id) async{
    int userId = await DatabaseHelper().deleteTransferId(id);
    return userId;
  }
}



