import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';


class AddItem extends StatefulWidget {
  AddItem({Key? key, required this.referenceName}) : super(key: key);

  @override
  _AddItemState createState() => _AddItemState();
  String referenceName;
}

class _AddItemState extends State<AddItem> {
  File imageFile = File("");
  TextEditingController Quantity = TextEditingController();
  TextEditingController ItemName = TextEditingController();
  TextEditingController ExpiryDate = TextEditingController();

  final database = FirebaseDatabase(
      databaseURL:
      "https://trackkit-a5cf3-default-rtdb.asia-southeast1.firebasedatabase.app")
      .reference();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Add Item"),
          titleTextStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 25,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          elevation: 10,
          backgroundColor: const Color(0xFF21BFBD),
          leading: Container(
              padding: EdgeInsets.all(1),
              child: (Image.asset('assets/Icon.png'))),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(height: 80),
                TextField(
                  controller: ItemName,
                  maxLength: 25,
                  decoration: InputDecoration(
                    hintText: "Enter Item Name",
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.redAccent),
                    labelText: ('Item Name'),
                    labelStyle: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(width: 4, color: Colors.blueGrey),
                    ),
                    icon: const Icon(
                      Icons.cases_rounded,
                      size: 40,
                      //
                    ),
                    // prefixIcon: Icon(Icons.qr_code),
                    // prefixIconColor: (color: Colors.blue,)
                  ),
                ),
                const SizedBox(height: 30.0),
                TextField(
                  controller: Quantity,
                  maxLength: 25,
                  decoration: InputDecoration(
                    hintText: "Enter Quantity",
                    hintStyle: TextStyle(fontSize: 13, color: Colors.redAccent),
                    labelText: ('Quantity'),
                    labelStyle: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(width: 4, color: Colors.blueGrey),
                    ),
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      size: 40,
                    ),
                  ),
                  keyboardType: TextInputType.number,),
                const SizedBox(height: 30.0),
                TextField(
                  controller: ExpiryDate,
                  maxLength: 25,
                  decoration: InputDecoration(
                    hintText: "Enter Expiry Date",
                    hintStyle: TextStyle(fontSize: 13, color: Colors.redAccent),
                    labelText: ('Expiry Date'),
                    labelStyle: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(width: 4, color: Colors.blueGrey),
                    ),
                    icon: const Icon(
                      Icons.calendar_today_rounded,
                      size: 40,
                    ),
                  ),
                  onTap: () {
                    _selectDate(context);
                  },),
                const SizedBox(height: 15.0),
                Container(
                  height: 40,
                  width:250,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Color(0xFFCE0808),
                        onPrimary: Colors.white,
                        shape:const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50)))
                    ),
                    child: const Text('Add Picture'),
                    onPressed: () async {
                      _showChoiceDialog(context); //
                    },
                  ),
                ),
                const SizedBox(height: 15.0),
                imageFile.path == ""
                    ? Center(child: Text(""))
                    : Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Image.file(imageFile, fit: BoxFit.fill)),
                Spacer(),
                Container(
                  height: 40,
                  width:250,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Color(0xFF21BFBD),
                        onPrimary: Colors.white,
                        shape:const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50)))
                    ),
                    child: const Text('Save'),
                    onPressed: () async {
                      if (Quantity.text.isEmpty){
                        Fluttertoast.showToast(
                            msg: "Please key in Quantity",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );

                      }else if (ExpiryDate.text.isEmpty){
                        Fluttertoast.showToast(
                            msg: "Please key in Expiry Date",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );

                      }else if (ItemName.text.isEmpty){
                        Fluttertoast.showToast(
                            msg: "Please key in Item Name",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );

                      }else{
                        EasyLoading.show(status: 'Saving please wait...');
                        final DatabaseReference reference = FirebaseDatabase(
                            databaseURL:
                            "https://trackkit-a5cf3-default-rtdb.asia-southeast1.firebasedatabase.app")
                            .reference()
                            .child('NTU')
                            .child(widget.referenceName);
                        DatabaseReference newRef = reference.push();
                        uploadPic(newRef.key).then((imageUrl) async {
                          String referenceName = newRef.key;
                          await newRef.set({
                            'Quantity': int.parse(Quantity.text),
                            'Expiry Date': ExpiryDate.text,
                            'Item': ItemName.text,
                            'Image': imageUrl,
                            'referenceName': referenceName
                          });
                          EasyLoading.dismiss();
                          Navigator.pop(context);
                        });//

                      }

                    },
                  ),
                ),
              ], // );
            ),
          ),
        ),
      ),
    );
  }
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        ExpiryDate
          ..text = DateFormat.yMMMd().format(selectedDate)
          ..selection = TextSelection.fromPosition(TextPosition(
              offset: ExpiryDate.text.length, affinity: TextAffinity.upstream));
      });
    }
  }
  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              "Choose option",
              style: TextStyle(color: Colors.blue),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  const Divider(
                    height: 1,
                    color: Colors.blue,
                  ),
                  ListTile(
                    onTap: () {
                      _openGallery(context);
                    },
                    title: const Text("Gallery"),
                    leading: const Icon(
                      Icons.account_box,
                      color: Colors.blue,
                    ),
                  ),
                  const Divider(
                    height: 1,
                    color: Colors.blue,
                  ),
                  ListTile(
                    onTap: () {
                      _openCamera(context);
                    },
                    title: const Text("Camera"),
                    leading: const Icon(
                      Icons.camera,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
  void _openGallery(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      imageFile = File(pickedFile!.path);
    });

    Navigator.pop(context);
  }
  void _openCamera(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    setState(() {
      imageFile = File(pickedFile!.path);
    });
    Navigator.pop(context);
  }

  Future<String> uploadPic(String newRef) async {
    print("File path = ${imageFile.path}");
    final UploadTask uploadTask = FirebaseStorage.instance
        .ref()
        .child("${widget.referenceName}/$newRef")
        .putFile(File(imageFile.path));
    TaskSnapshot taskSnapshot = await uploadTask;

    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}