import 'package:expense_manager_app/Database/database.dart';
import 'package:flutter/material.dart';

class DisplayCategory extends StatefulWidget {
  const DisplayCategory({super.key});

  @override
  State<DisplayCategory> createState() => _DisplayCategoryState();
}

class _DisplayCategoryState extends State<DisplayCategory> {

  var id;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Category"),
      ),
      body: FutureBuilder<bool>(builder: (context, snapshot1) {
        if(snapshot1.hasData){
          print(snapshot1.data);
          return FutureBuilder<List<Map<String, Object?>>>(
            future: DatabaseHelper().getCategoryFromCategoryTable(),
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
                            Expanded(child: CircleAvatar(child: Image(image: AssetImage(snapshot.data![index]['Category_Image'].toString()),),backgroundColor: Colors.white,)),
                            Expanded(flex:5,child: InkWell(
                              onTap: () {
                                Map map={};
                                map['name'] = (snapshot.data![index]['Category_Name']).toString();
                                map['id']=(snapshot.data![index]['Category_id']).toString();
                                Navigator.pop(context,map);
                              },
                              child: Text(
                                (snapshot.data![index]['Category_Name']).toString(),style: TextStyle(fontSize: 20),
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
