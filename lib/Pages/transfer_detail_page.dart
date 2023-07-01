import 'package:flutter/material.dart';

import '../Database/database.dart';
import 'add_page.dart';

class TransferDetail extends StatefulWidget{
  const TransferDetail({super.key});

  @override
  State<TransferDetail> createState() => _TransferDetailState();
}

class _TransferDetailState extends State<TransferDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(
          Icons.account_circle,
          size: 35,
        ),
        title: Text("Transfer Detail Page"),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        height: 10*MediaQuery.of(context).size.height/11,
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
                          await Navigator.of(context).push(MaterialPageRoute(builder: (context) => Add_Page(snapshot.data![index]),)).then((value){
                            setState(() {
                              DatabaseHelper().getTransfer();
                            });
                          });
                        },
                        child: Card(
                          color: snapshot.data![index]['Transfer_Type']==0?Color.fromARGB(255, 233, 133, 133):Color.fromARGB(255, 121, 202, 125),
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
                  itemCount: snapshot.data?.length,
                );
              }else{
                return Center(child: Text("Database is empty"));
              }
            },
          )
      ),
    );
  }
}