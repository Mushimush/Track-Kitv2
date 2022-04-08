import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trackkit/Screens/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';


import 'flutter_barcode_scanner.dart';

class AddKit extends StatefulWidget {
  const AddKit({Key? key}) : super(key: key);

  @override
  _AddKitState createState() => _AddKitState();
}

class _AddKitState extends State<AddKit> {
  String _scanBarcode = '';

  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
        .listen((barcode) => print(barcode));
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  TextEditingController location = TextEditingController();
  TextEditingController labName = TextEditingController();
  TextEditingController barcode = TextEditingController();

  final database = FirebaseDatabase(
      databaseURL:
      "https://trackkit-a5cf3-default-rtdb.asia-southeast1.firebasedatabase.app")
      .reference()
      .child('NTU')
      .child('Location 1');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Add Kit"),
          titleTextStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 25,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          elevation: 10,
          backgroundColor: const Color(0xFF21BFBD),
          leading: Container(
              padding: const EdgeInsets.all(1),
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
                  maxLength: 25,
                  controller: labName,
                  decoration: InputDecoration(
                    hintText: "Enter Lab Name",
                    hintStyle: TextStyle(fontSize: 13, color: Colors.redAccent),
                    labelText: ('Lab Name'),
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
                      Icons.find_in_page,
                      size: 40,
                      //
                    ),
                    // prefixIcon: Icon(Icons.qr_code),
                    // prefixIconColor: (color: Colors.blue,)
                  ),
                ),
                const SizedBox(height: 30.0),
                TextField(
                  maxLength: 25,
                  controller: location,
                  decoration: InputDecoration(
                    hintText: "Enter Location",
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.redAccent),
                    labelText: ('Location'),
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
                      Icons.store,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                TextField(
                    maxLength: 100,
                    controller: barcode,
                    decoration: InputDecoration(
                      hintText: "Press to Scan",
                      hintStyle:
                      const TextStyle(fontSize: 13, color: Colors.redAccent),
                      labelText: ('Scan'),
                      labelStyle: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 25,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                        const BorderSide(width: 4, color: Colors.blueGrey),
                      ),
                      icon: const Icon(
                        Icons.qr_code,
                        size: 40,
                      ),
                    ),
                    onTap: () {
                      scanQR();
                      barcode.text = _scanBarcode;
                    }),
                const SizedBox(height: 220,),
                SizedBox(
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
                      final DatabaseReference database = FirebaseDatabase(
                          databaseURL:
                          "https://trackkit-a5cf3-default-rtdb.asia-southeast1.firebasedatabase.app")
                          .reference()
                          .child('NTU');
                      if (location.text.isEmpty){
                        Fluttertoast.showToast(
                            msg: "Please key in Location",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );

                      }else if (labName.text.isEmpty){
                        Fluttertoast.showToast(
                            msg: "Please key in LabName",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );

                      }else if(barcode.text.isEmpty){
                        Fluttertoast.showToast(
                            msg: "Please Scan Barcode",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );

                      }else{
                        final locay = database.child(barcode.text);
                        await locay.set({ 'Lab Name': labName.text,
                          'Place': location.text,
                          'Barcode': barcode.text});
                           Navigator.pop(context);

                      }
                      //
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
}