import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dbex2/db/dbhelper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../color.dart';

class AddContact extends StatefulWidget
{
  const AddContact({super.key});

  @override
  State<AddContact> createState() => _AddContactState();
}

class _AddContactState extends State<AddContact>
{
  TextEditingController name = TextEditingController();
  TextEditingController lname = TextEditingController();
  TextEditingController mobile = TextEditingController();
  TextEditingController email = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? imageFile;
  late Future<Uint8List> imageBytes;
  String currentCategory = "";
  List<String> allCategoryData = [];
  DbHelper dbHelper = DbHelper.instance;
  
  @override
  void initState() {
    // TODO: implement initState
    _query();
  }
  
  
  @override
  Widget build(BuildContext context)
  {
    return SafeArea
      (
          child: Scaffold
            (
              body: ListView
                (
                  children:
                  [

                    SizedBox
                      (
                      height: 20,
                      ),
                      InkWell
                      (
                        onTap: ()async
                        {
                          final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

                          if(pickedFile!=null)
                          {

                            imageBytes = pickedFile.readAsBytes();
                            setState(()
                            {
                              imageFile = File(pickedFile.path);
                            });

                          }
                        },
                        child: imageFile == null ?
                        CircleAvatar(
                          backgroundColor: MyColors.primaryColor,
                          minRadius: 50,
                          child: Icon(
                            Icons.image,
                            color: Colors.white,
                          ),
                        ):CircleAvatar(
                          backgroundImage: Image.file(
                            imageFile!,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ).image,
                          minRadius: 100,
                        ),
                      ),
                    SizedBox
                      (
                      height: 20,
                    ),
                    TextFormField(controller: name,decoration: InputDecoration(hintText: "Enter Name",border: OutlineInputBorder()),),
                    SizedBox
                      (
                      height: 20,
                    ),
                    TextFormField(controller: lname,decoration: InputDecoration(hintText: "Enter Lastname",border: OutlineInputBorder()),),
                    SizedBox
                      (
                      height: 20,
                    ),
                    TextFormField(controller: mobile,decoration: InputDecoration(hintText: "Enter Mobile",border: OutlineInputBorder()),),
                    SizedBox
                      (
                      height: 20,
                    ),
                    TextFormField(controller: email,decoration: InputDecoration(hintText: "Enter Email",border: OutlineInputBorder()),),
                    SizedBox
                      (
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: MyColors.primaryColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          items: allCategoryData
                              .map((String value)
                          {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (selectedItem) => setState(()
                          {
                            currentCategory = selectedItem!;
                          }),
                          hint: Text("Select Category "),
                          value: currentCategory.isEmpty ? null : currentCategory,
                        ),
                      ),
                    ),
                    SizedBox
                      (
                      height: 20,
                    ),
                    ElevatedButton(onPressed: ()
                    {
                      insertcontact();
                    }, child: Text("Add"))
                  ],
                )
            ),
      );
  }

  void _query()async
  {
    final allRows = await dbHelper.queryAllRows();
    if (kDebugMode)
    {
      print('query all rows:');
    }
    for (var element in allRows)
    {
      allCategoryData.add(element["category_name"]);

    }
    setState(() {});
  }


  void insertcontact()async
  {
    var base64image;

    if(imageFile!.exists()!=null)
    {
      base64image = base64Encode(imageFile!.readAsBytesSync().toList());
      Map<String, dynamic> row =
      {
        DbHelper.columnName: name.text.toString(),
        DbHelper.columnLName: lname.text.toString(),
        DbHelper.columnMobile: mobile.text.toString(),
        DbHelper.columnEmail: email.text.toString(),
        DbHelper.columnCategory: currentCategory,
        DbHelper.columnProfile:base64image,
      };

      int id = await dbHelper.insertcontact(row);
      print(id);
      print("contact inserted");
    }

  }
}
