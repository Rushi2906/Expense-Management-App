import 'dart:ffi';

import 'package:expense_manager_app/Database/database.dart';
import 'package:expense_manager_app/Pages/add_page.dart';
import 'package:expense_manager_app/Pages/transfer_detail_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int count=0;

  @override
  void initState() {
    super.initState();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(
          Icons.account_circle,
          size: 35,
        ),
        title: Text("Home Page"),

      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async{
          await Navigator.of(context).push(MaterialPageRoute(builder: (context) => Add_Page(null),)).then((value){
              setState(() {
                DatabaseHelper().getTransfer();
              });
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [

          //Message
          Container(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      "Welcome to the App",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Container(
                    child: Icon(
                      Icons.search,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),

          //Spending and Income total
          Container(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FutureBuilder(
                    future:DatabaseHelper().sumOfExpense(),
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        return SpendingIncome(
                            icn: Icon(Icons.arrow_upward,
                                color: Colors.white, weight: 7),
                            clr: Color.fromARGB(255, 221, 49, 49),
                            txt: "Spending",
                            amount: snapshot.data!.length!=0?snapshot.data![0]['totalExpense']:0,
                            iconclr: Color.fromARGB(255, 233, 133, 133)
                        );
                      }else{
                       return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                  FutureBuilder(
                      future: DatabaseHelper().sumOfIncome(),
                      builder: (context, snapshot) {
                        if(snapshot.hasData){
                          return SpendingIncome(
                              icn: Icon(
                                Icons.arrow_downward,
                                color: Colors.white,
                                weight: 7,
                              ),
                              clr: Color.fromARGB(255, 56, 142, 61),
                              txt: "Income",
                              amount: snapshot.data!.length!=0?snapshot.data![0]['totalIncome']:0,
                              iconclr: Color.fromARGB(255, 121, 202, 125)
                          );
                        }else{
                          return CircularProgressIndicator();
                        }
                      },
                  )
                ],
              ),
            ),
          ),

          //Balance total
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 10),
              width: 10 * MediaQuery.of(context).size.width / 20,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(40)),
                color: Colors.grey,
              ),
              child: FutureBuilder(
                future: DatabaseHelper().sumOfBalance(),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    return Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          child: Text(
                            "Balance: \$ ",
                            style: TextStyle(
                                color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          child: Text(snapshot.data!.length!=0?snapshot.data![0]['balance'].toString():0.toString()),
                        )
                      ],
                    );
                  }else{
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ),

          //Recent Transaction Heading
          Container(
            margin: EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Text(
                    "Recent Transactions",
                    style: TextStyle(fontSize: 17),
                  ),
                ),
                Container(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => TransferDetail(),));
                    },
                    child: Text(
                      "See all",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                )
              ],
            ),
          ),

          //Recent Transaction
          Container(
              height: 300,
              child: FutureBuilder(
                future: DatabaseHelper().getTransfer(),
                builder: (context, snapshot) {
                  print(snapshot.data);
                  if(snapshot.hasData){
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        return Container(
                          height: 60,
                          child: InkWell(
                            onTap: () async{
                             await Navigator.of(context).push(MaterialPageRoute(builder: (context) => Add_Page(snapshot.data![snapshot.data!.length-index-1]),)).then((value){
                                setState(() {

                                });
                              });
                            },
                            child: Card(
                              color: snapshot.data![snapshot.data!.length-index-1]['Transfer_Type']==0?Color.fromARGB(255, 233, 133, 133):Color.fromARGB(255, 121, 202, 125),
                              elevation: 10,
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: Container(
                                        child: CircleAvatar(
                                          child: Icon(Icons.transform),
                                        ),
                                      )),
                                  Expanded(
                                      flex: 3,
                                      child: Container(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin:EdgeInsets.only(top: 8),
                                              child: Text(snapshot.data![snapshot.data!.length-index-1]['Transfer_Amount'].toString()),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 2),
                                              child: Text(snapshot.data![snapshot.data!.length-index-1]['Transfer_Note'].toString()),
                                            )
                                          ],
                                        ),
                                      )),
                                  Expanded(
                                      flex: 2,
                                      child: Container(
                                        margin: EdgeInsets.only(right: 10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              margin:EdgeInsets.only(top: 8),
                                              child: Text(snapshot.data![snapshot.data!.length-index-1]['Transfer_Date'].toString()),
                                            ),
                                            Container(
                                              margin:EdgeInsets.only(top: 2),
                                              child: Icon(Icons.money),
                                            )
                                          ],
                                        ),
                                      ))
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: snapshot.data!.length<=5?snapshot.data!.length:5,
                    );
                  }else{
                    return Center(child: Text("Database is empty"));
                  }
                },
              )

          ),
        ],
      ),
    );
  }

  Widget SpendingIncome(
      {required Icon icn,
      required Color clr,
      required String txt,
      required int amount,
      required Color iconclr}) {
    return Container(
      width: 10 * MediaQuery.of(context).size.width / 22,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(40)),
        color: clr,
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: CircleAvatar(
                child: icn,
                backgroundColor: iconclr,
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                margin: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 2),
                      child: Text(
                        "$txt",
                        style: TextStyle(fontSize: 15, color: iconclr),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 2),
                      child: Text(
                        "\$ $amount",
                        style: TextStyle(fontSize: 17, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
