import 'package:expense_manager_app/Database/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:expense_manager_app/Controller/date_filter_controller.dart' as dfc;

import 'add_page.dart';

class AnalysisPage extends StatefulWidget{
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {

  int? sliding = 0;
  DateTime selectedYear = DateTime.now();
  DateTime? selectedMonth = DateTime.now();
  String analysingDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  var month;
  var year;

  selectYear(context) async{
    print("calling date picker");
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select Year'),
            titleTextStyle: TextStyle(color: Colors.blue,fontSize: 20),
            content: SizedBox(
              width: 300,
              height: 300,
              child: YearPicker(
                firstDate: DateTime(DateTime.now().year-10,1),
                lastDate: DateTime.now(),
                initialDate: DateTime.now(),
                selectedDate: selectedYear,
                onChanged: (DateTime dateTime) {
                    setState(() {
                      selectedYear=dateTime;
                      analysingDate=selectedYear.year.toString();
                      print(selectedYear.year);
                    });
                    Navigator.pop(context);
                },
              ),
            ),
          );
        },
    );
  }

  selectDate(context) async{
    var selectedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
    );
    setState(() {
      analysingDate = DateFormat('dd-MM-yyyy').format(selectedDate!);
    });
  }

  selectMonth(BuildContext context) async{
      selectedMonth = await showMonthPicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2010),
          lastDate: DateTime.now(),
        yearFirst: true,
      ).then((DateTime? date){
          if(date!=null){
            setState(() {
              selectedMonth = date;
              analysingDate = DateFormat.yMMMM().format(selectedMonth!);
              month = DateFormat('MM').format(selectedMonth!);
              year = selectedMonth!.year.toString();
              print(month);
              print(year);
              // print(selectedMonth!.month.toString());
              // print(selectedMonth!.year.toString());
            });
          }
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
          appBar: AppBar(
            leading: Icon(Icons.account_circle,size: 35,),
            title: Text("Analysis Page"),
          ),
          body: Column(
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: CupertinoSlidingSegmentedControl(
                    children: {
                      0: InkWell(child: Text('Date'),onTap: () {sliding=0;selectDate(context);},),
                      1: InkWell(child: Text('Month'),onTap: () {sliding=1;selectMonth(context);},),
                      2: InkWell(child: Text('Year'),onTap: () {sliding=2;selectYear(context);},)
                    },
                    groupValue: sliding,
                    onValueChanged: (int? newValue) {
                      setState(() {
                        sliding=newValue;
                        print(sliding);
                        sliding==2?selectYear(context):DateTime.now();
                        sliding==0?selectDate(context):DateTime.now();
                        sliding==1?selectMonth(context):DateTime.now();
                      });
                    },
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Center(child: Text(analysingDate,style: TextStyle(fontSize: 20),)),
                      width: 10*MediaQuery.of(context).size.width/15,
                    ),
                  ],
                ),
              ),
              Container(
                height: 10*MediaQuery.of(context).size.height/16,
                margin: EdgeInsets.only(top: 30),
                child: filterData(),
              ),
            ],
          ),
      ),
    );
  }

  Widget filterData(){
    return FutureBuilder<List<Map<String,dynamic>>>(
        future: sliding==0?DatabaseHelper().dateWiseFilter(analysingDate):(sliding==1?DatabaseHelper().monthWiseFilter(year, month):DatabaseHelper().yearWiseFilter(selectedYear.year)),
        builder: (context, snapshot) {
          if(snapshot.hasData && snapshot.data!.isNotEmpty){
            return ListView.builder(
              scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                    return Container(
                      height: 60,
                      child: InkWell(
                        onTap: () async{
                          await Navigator.of(context).push(MaterialPageRoute(builder: (context) => Add_Page(snapshot.data![index]),)).then((value){
                            setState(() {
                              DatabaseHelper().getTransfer();
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
                                          child: Text(snapshot.data![index]['Transfer_Amount'].toString()),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: 2),
                                          child: Text(snapshot.data![index]['Transfer_Note'].toString()),
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
                                          child: Text(snapshot.data![index]['Transfer_Date'].toString()),
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
              itemCount: snapshot.data!.length,
            );
          }else{
            return Center(child: Container(child: Text("No Data Found"),));
          }
        },
    );
  }

  // Widget monthWiseFilter(){
  //   return FutureBuilder(
  //     future: DatabaseHelper().monthWiseFilter(year,month),
  //     builder: (context, snapshot) {
  //       if(snapshot.hasData){
  //         return ListView.builder(
  //           scrollDirection: Axis.vertical,
  //           itemBuilder: (context, index) {
  //             return Container(
  //               height: 60,
  //               child: InkWell(
  //                 onTap: () async{
  //                   await Navigator.of(context).push(MaterialPageRoute(builder: (context) => Add_Page(snapshot.data![index]),)).then((value){
  //                     setState(() {
  //                       DatabaseHelper().getTransfer();
  //                     });
  //                   });
  //                 },
  //                 child: Card(
  //                   color: snapshot.data![snapshot.data!.length-index-1]['Transfer_Type']==0?Color.fromARGB(255, 233, 133, 133):Color.fromARGB(255, 121, 202, 125),
  //                   elevation: 10,
  //                   child: Row(
  //                     children: [
  //                       Expanded(
  //                           flex: 1,
  //                           child: Container(
  //                             child: CircleAvatar(
  //                               child: Icon(Icons.transform),
  //                             ),
  //                           )),
  //                       Expanded(
  //                           flex: 3,
  //                           child: Container(
  //                             child: Column(
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 Container(
  //                                   margin:EdgeInsets.only(top: 8),
  //                                   child: Text(snapshot.data![index]['Transfer_Amount'].toString()),
  //                                 ),
  //                                 Container(
  //                                   margin: EdgeInsets.only(top: 2),
  //                                   child: Text(snapshot.data![index]['Transfer_Note'].toString()),
  //                                 )
  //                               ],
  //                             ),
  //                           )),
  //                       Expanded(
  //                           flex: 2,
  //                           child: Container(
  //                             margin: EdgeInsets.only(right: 10),
  //                             child: Column(
  //                               crossAxisAlignment: CrossAxisAlignment.end,
  //                               children: [
  //                                 Container(
  //                                   margin:EdgeInsets.only(top: 8),
  //                                   child: Text(snapshot.data![index]['Transfer_Date'].toString()),
  //                                 ),
  //                                 Container(
  //                                   margin:EdgeInsets.only(top: 2),
  //                                   child: Icon(Icons.money),
  //                                 )
  //                               ],
  //                             ),
  //                           ))
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //           itemCount: snapshot.data!.length,
  //         );
  //       }else{
  //         return Center(child: Container(child: Text("No Data Found"),));
  //       }
  //     },
  //   );
  // }
  //
  // Widget yearWiseFilter(){
  //   return FutureBuilder(
  //     future: DatabaseHelper().yearWiseFilter(selectedYear.year),
  //     builder: (context, snapshot) {
  //       if(snapshot.data!=null){
  //         return ListView.builder(
  //           scrollDirection: Axis.vertical,
  //           itemBuilder: (context, index) {
  //             return Container(
  //               height: 60,
  //               child: InkWell(
  //                 onTap: () async{
  //                   await Navigator.of(context).push(MaterialPageRoute(builder: (context) => Add_Page(snapshot.data![index]),)).then((value){
  //                     setState(() {
  //                       DatabaseHelper().getTransfer();
  //                     });
  //                   });
  //                 },
  //                 child: Card(
  //                   color: snapshot.data![snapshot.data!.length-index-1]['Transfer_Type']==0?Color.fromARGB(255, 233, 133, 133):Color.fromARGB(255, 121, 202, 125),
  //                   elevation: 10,
  //                   child: Row(
  //                     children: [
  //                       Expanded(
  //                           flex: 1,
  //                           child: Container(
  //                             child: CircleAvatar(
  //                               child: Icon(Icons.transform),
  //                             ),
  //                           )),
  //                       Expanded(
  //                           flex: 3,
  //                           child: Container(
  //                             child: Column(
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 Container(
  //                                   margin:EdgeInsets.only(top: 8),
  //                                   child: Text(snapshot.data![index]['Transfer_Amount'].toString()),
  //                                 ),
  //                                 Container(
  //                                   margin: EdgeInsets.only(top: 2),
  //                                   child: Text(snapshot.data![index]['Transfer_Note'].toString()),
  //                                 )
  //                               ],
  //                             ),
  //                           )),
  //                       Expanded(
  //                           flex: 2,
  //                           child: Container(
  //                             margin: EdgeInsets.only(right: 10),
  //                             child: Column(
  //                               crossAxisAlignment: CrossAxisAlignment.end,
  //                               children: [
  //                                 Container(
  //                                   margin:EdgeInsets.only(top: 8),
  //                                   child: Text(snapshot.data![index]['Transfer_Date'].toString()),
  //                                 ),
  //                                 Container(
  //                                   margin:EdgeInsets.only(top: 2),
  //                                   child: Icon(Icons.money),
  //                                 )
  //                               ],
  //                             ),
  //                           ))
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //           itemCount: snapshot.data!.length,
  //         );
  //       }else{
  //         return Center(child: Container(child: Text("No Data Found"),));
  //       }
  //     },
  //   );
  // }

  // Widget yearWiseFilter(){
  //   var start=DateFormat('yyyy').parse(selectedYear.toString());
  //   var last=DateTime.utc(start.year + 1).subtract(Duration(days: 1));
  //   print("start : $start");
  //   print("end : $last");
  //   return FutureBuilder(
  //     future: DatabaseHelper().yearWiseFilter(start,last),
  //     builder: (context, snapshot) {
  //       if(snapshot.hasData){
  //         return ListView.builder(
  //           scrollDirection: Axis.vertical,
  //           itemBuilder: (context, index) {
  //             return Container(
  //               height: 30,
  //               child: Text(snapshot.data![index]['Transfer_Date'].toString()),
  //             );
  //           },
  //           itemCount: snapshot.data!.length,
  //         );
  //       }else{
  //         return Center(child: Container(child: Text("No Data Found"),));
  //       }
  //     },
  //   );
  // }
}