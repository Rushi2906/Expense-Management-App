import 'package:expense_manager_app/Database/database.dart';
import 'package:flutter/material.dart';

class DisplayMode extends StatefulWidget {
  const DisplayMode({super.key});

  @override
  State<DisplayMode> createState() => _DisplayModeState();
}

class _DisplayModeState extends State<DisplayMode> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Mode"),
      ),
      body: FutureBuilder<bool>(builder: (context, snapshot1) {
        if(snapshot1.hasData){
          print(snapshot1.data);
          return FutureBuilder<List<Map<String, Object?>>>(
            future: DatabaseHelper().getPaymentMode(),
            builder: (context,snapshot) {
              if(snapshot.hasData){
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(child: InkWell(
                              onTap: () {
                                Map map={};
                                map['name'] = (snapshot.data![index]['Mode_Type']).toString();
                                map['id']=(snapshot.data![index]['Mode_Id']).toString();
                                Navigator.pop(context,map);
                              },
                              child: Text(
                                (snapshot.data![index]['Mode_Type']).toString(),style: TextStyle(fontSize: 20),
                              ),
                            )),
                          ],
                        ),
                      ),
                    );
                  },);
              }
              else{
                return Center(child: CircularProgressIndicator());
              }
            },
          );
        }
        else{
          return CircularProgressIndicator();
        }
      },
        future: DatabaseHelper().copyPasteAssetFileToRoot(),
      ),
    );
  }
}
