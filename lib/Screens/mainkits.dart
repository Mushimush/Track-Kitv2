import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:trackkit/Screens/addkitscreen.dart';
import 'package:trackkit/Screens/detailpage.dart';
import 'package:trackkit/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'flutter_barcode_scanner.dart';

class HomeScreenUI extends StatefulWidget {
  const HomeScreenUI({Key? key}) : super(key: key);

  @override
  _HomeScreenUIState createState() => _HomeScreenUIState();
}

class _HomeScreenUIState extends State<HomeScreenUI> {
  String _scanBarcode = '';
  late String barcode = "error";

  var lists = [];

  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
        .listen((barcode) => print(barcode));
  }

  Future<bool> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);

      setState(() {
        barcode = barcodeScanRes;
        _scanBarcode = barcodeScanRes;
      });
      print(barcodeScanRes);
      return true;
    } catch (e) {
      barcodeScanRes = 'Failed to get platform version.';
      barcodeScanRes = '$e';
      setState(() {
        _scanBarcode = barcodeScanRes;
      });
      print("EROR IS = $_scanBarcode");
      return false;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    // if (!mounted) return;
  }

  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  final database = FirebaseDatabase(
      databaseURL:
      "https://trackkit-a5cf3-default-rtdb.asia-southeast1.firebasedatabase.app")
      .reference()
      .child("NTU");

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF21BFBD),
      body: SingleChildScrollView(
        child:Column(
          children: <Widget>[
            const SizedBox(height: 60.0),
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Row(
                children: const <Widget>[
                  Text('TracK',
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0)),
                  SizedBox(),
                  Text('Kit',
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontSize: 25.0)),
                  Text(' Your first-aid solution',
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontStyle: FontStyle. italic,
                          color: Colors.white,
                          fontSize: 15.0))
                ],
              ),

            ),
            const SizedBox(height: 40.0),
            Scrollbar(
              isAlwaysShown: true,
              child: Container(
                height: MediaQuery.of(context).size.height - 180.0,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(75.0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 300.0,
                    child: StreamBuilder(
                      stream: database.onValue,
                      builder: (context, AsyncSnapshot<Event> snapshot) {
                        if (snapshot.hasData &&
                            !snapshot.hasError &&
                            snapshot.data!.snapshot.value != null) {
                          print("Error on the way");
                          lists.clear();
                          DataSnapshot dataValues = snapshot.data!.snapshot;
                          Map<dynamic, dynamic> values = dataValues.value;
                          values.forEach((key, values) {
                            values["referenceName"] = key;

                            lists.add(values);
                          });
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: lists.length,
                            itemBuilder: (BuildContext context, int index) {
                              return _buildItem(
                                  'assets/Icon.png',
                                  lists[index]["Lab Name"].toString(),
                                  lists[index]["Place"].toString(),
                                  lists[index]["Barcode"].toString(),
                                  lists[index]["referenceName"]);
                            },
                          );
                        }
                        return const Text("Add Kits");
                      },
                    ),
                  ),
                ),
              ),),

            Container(
              height: 51,
              decoration: const BoxDecoration(
                color: Colors.white ,),

              child: ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF21BFBD),
                      onPrimary: Colors.white,
                    ),
                    child: const Text('Add Kit'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddKit()),
                      );
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF21BFBD),
                      onPrimary: Colors.white,
                    ),
                    child: const Text('Scan QR'),
                    onPressed: () {
                      scanQR().then((value) {
                        if (value) {

                          String imgPath = "";
                          String labby = "";
                          String labName = "";

                          for (int i = 0; i < lists.length; i++) {
                            if (lists[i]["Barcode"].toString() == barcode) {
                              imgPath = 'assets/Icon.png';
                              labName = lists[i]["Lab Name"].toString();
                              labby = lists[i]["Place"].toString();
                            }
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => detailsPage(
                                  heroTag: imgPath,
                                  labPlace: labby,
                                  foodName: labName,
                                  barcode: barcode,
                                  referenceName: barcode,
                                )),
                          );
                        } else {
                          print("Error ");
                        }
                      });
                    },
                  ),
                ],
              ),

            ),
            //
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
      String imgPath,
      String labName,
      String Labby,
      String barcode,
      String referenceName,
      ) {
    return Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
        child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => detailsPage(
                      heroTag: imgPath,
                      labPlace: Labby,
                      foodName: labName,
                      barcode: barcode,
                      referenceName: referenceName,
                    )),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(children: [
                  Hero(
                      tag: imgPath,
                      child: Image(
                          image: AssetImage(imgPath),
                          fit: BoxFit.cover,
                          height: 90.0,
                          width: 90.0)),
                  const SizedBox(width: 10.0),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(labName,
                            style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold)),
                        Text(Labby,
                            style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold)),
                      ]),
                ]),
              ],
            )));
  }
}