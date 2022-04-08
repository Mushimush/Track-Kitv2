import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:trackkit/model/user_model.dart';
import 'addnewitem.dart';

class detailsPage extends StatefulWidget {
  detailsPage(
      {Key? key,
        this.heroTag,
        this.labPlace,
        this.foodName,
        this.barcode,
        this.onValueChanged,
        required this.referenceName})
      : super(key: key);

  final heroTag;
  final labPlace;
  final foodName;
  final barcode;
  final onValueChanged;
  String referenceName;



  @override
  _detailsPageState createState() => _detailsPageState();
}

class _detailsPageState extends State<detailsPage> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications',
    importance: Importance.high,
  );

  @override
  void initState() {
    super.initState();

    _requestPermissions();

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
    final database = FirebaseDatabase(
        databaseURL:
        "https://trackkit-a5cf3-default-rtdb.asia-southeast1.firebasedatabase.app")
        .reference()
        .child('NTU')
        .child(widget.referenceName);
    return Scaffold(
        backgroundColor: const Color(0xFF7A9BEE),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.white,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: const Text('Details',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18.0,
                  color: Colors.white)),
          centerTitle: true,
        ),
        body: ListView(children: [
          Stack(children: [
            Container(
                height: MediaQuery.of(context).size.height - 82.0,
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent),
            Positioned(
                top: 75.0,
                child: Container(
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(45.0),
                          topRight: Radius.circular(45.0),
                        ),
                        color: Colors.white),
                    height: MediaQuery.of(context).size.height - 100.0,
                    width: MediaQuery.of(context).size.width)),
            Positioned(
                top: 0.0,
                left: (MediaQuery.of(context).size.width / 2) - 50.0,
                child: widget.heroTag == null?Container():Hero(
                    tag: widget.heroTag,
                    child: Container(
                        decoration:  BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(widget.heroTag),
                                fit: BoxFit.cover)),
                        height: 100.0,
                        width: 100.0))),
            Positioned(
                top: 100.0,
                left: 25.0,
                right: 25.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: <Widget>[
                    Text("${widget.foodName}",
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5.0, width: 1.0),
                    Container(
                      color: Colors.white,
                      height: MediaQuery.of(context).size.height - 300,
                      child: StreamBuilder(
                        stream: database.onValue,
                        builder: (context, AsyncSnapshot<Event> snapshot) {
                          final lists = [];
                          if (snapshot.hasData &&
                              !snapshot.hasError &&
                              snapshot.data!.snapshot.value != null) {
                            lists.clear();
                            DataSnapshot dataValues = snapshot.data!.snapshot;
                            Map<dynamic, dynamic> values = dataValues.value;
                            values.forEach((key, values) {
                              if (key == 'Place') return;
                              if (key == 'Lab Name') return;
                              if (key == 'Barcode') return;
                              values["referenceName"] = key;
                              lists.add(values);
                            });
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: lists.length,
                              itemBuilder: (BuildContext context, int index) {
                                void onAdd() {
                                  final newItem = lists[index];
                                  newItem["Quantity"] = newItem["Quantity"] + 1;
                                  final item =
                                  Map<String, dynamic>.from(newItem);
                                  database
                                      .child(lists[index]["referenceName"])
                                      .update(item);
                                }

                                void onSubtract() {
                                  final newItem = lists[index];
                                  if (newItem["Quantity"] == 0) return;
                                  newItem["Quantity"] = newItem["Quantity"] - 1;
                                  final item =
                                  Map<String, dynamic>.from(newItem);
                                  database
                                      .child(lists[index]["referenceName"])
                                      .update(item);
                                }

                                void onDelete() {
                                  database
                                      .child(lists[index]["referenceName"])
                                      .remove();
                                }

                                print("Data = ${lists[index]["Quantity"]}");


                                return _buildItem(
                                  //  'assets/Aborbent Gauze.jpeg',
                                  lists[index]["Image"],
                                  lists[index]["Item"].toString(),
                                  lists[index]["Quantity"],
                                  lists[index]["Expiry Date"],
                                  onAdd,
                                  onSubtract,
                                  onDelete,
                                );
                              },
                            );
                          }

                          return const Text("Add Items");
                        },
                      ),
                    ),

                    ElevatedButton(
                      child: const Text('Add Items'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddItem(referenceName: widget.referenceName,)),
                        );
                      },
                    ),
                  ],
                ))
          ])
        ]));
  }

  Widget _buildItem(String imgPath, String labName, int quantity, String expiry,
      Function onAdd, Function onSubtract, Function onDelete) {
    void _minusNum() {
      onSubtract();
    }

    void _onAdd() {
      onAdd();
    }

    void _onDelete() {
      onDelete();
    }

    return Padding(
        padding: const EdgeInsets.only(left: 0.0, right: 10, top: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
              onLongPress: _onDelete,
              child: Row(children: [
                Hero(
                    tag: imgPath,
                    child:  Image(
                        image: NetworkImage(imgPath),
                        fit: BoxFit.cover,
                        height: 120.0,
                        width: 130.0)),
                const SizedBox(width: 10.0),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    labName,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    expiry,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: 100.0,
                    height: 30.0,
                    margin: const EdgeInsets.only(left: 0.0, top: 5.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17.0),
                        color: const Color(0xFF7A9BEE)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        InkWell(
                          onTap: _minusNum,
                          child: Container(
                            height: 25.0,
                            width: 25.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7.0),
                                color: const Color(0xFF7A9BEE)),
                            child: const Center(
                              child: Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 20.0,
                              ),
                            ),
                          ),
                        ),
                        Text(quantity.toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                                fontSize: 15.0)),
                        InkWell(
                          onTap: _onAdd,
                          child: Container(
                            height: 25.0,
                            width: 25.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7.0),
                                color: Colors.white),
                            child: const Center(
                              child: Icon(
                                Icons.add,
                                color: Color(0xFF7A9BEE),
                                size: 20.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ]),
              ]),
            ),
          ],
        ));
  }

  Future<void> _showNotificationWithNoTitle(int notificationId, String body) async {
    print("Data notificationId= ${notificationId}");
    flutterLocalNotificationsPlugin.show(
        notificationId,
        "${widget.foodName}",
        "$body needs attention",
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            icon: 'launch_background',
          ),
        ));
  }

  Future<void> setNotification() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseDatabase.instance
        .reference()
        .child('NTU')
        .child(widget.referenceName)
        .once()
        .then((snapShot) {
      Map<dynamic, dynamic> values = snapShot.value;

      var tempList = [];

      // print("DATA = ${snapShot.value}");

      snapShot.value.forEach((key, value) {
        // if (key == 'Place') return;
        // if (key == 'Lab Name') return;
        // if (key == 'Barcode') return;
        // values["referenceName"] = key;
        tempList.add(value);
      });

      int counter = 1;
      for(var databaseData in tempList){
        try{
          checkItem(counter, databaseData);
          counter++;
        }catch(e){
          print("Error = $e");
        }

      }
    });
  }

  checkItem(int id, var data){
    //["Item"].toString()
    String date = data["Expiry Date"].toString();
    String dateAndMonth = date.split(",")[0];

    int month = getMonthValue(dateAndMonth);
    int day = int.parse(dateAndMonth.split(" ")[1]);
    int year = int.parse(date.split(",")[1]);
    print("Date is = $year $month $day");

    final birthday = DateTime(year, month, day);
    final date2 = DateTime.now();

    final expiresIn = date2.difference(birthday).inDays;
    print(" expiresIn = $expiresIn");
    print(" expiresIn = ${expiresIn>-90}");



    if(data["Quantity"] < 90 || expiresIn>-90){
      flutterLocalNotificationsPlugin.show(
          id,
          "${widget.foodName}",
          "${data['Item']} need attention",
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: "@mipmap/icon",
            ),
          ));
    }
  }


  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    setNotification();

  }

  int getMonthValue(String date) {
    int month;
    String data = date.split(" ")[0];
    if(data == "Jan"){
      month = 01;
    }else if(data == "Feb"){
      month = 02;
    }else if(data == "Mar"){
      month = 03;
    }else if(data == "Apr"){
      month = 04;
    }else if(data == "May"){
      month = 05;
    }else if(data == "Jun"){
      month = 06;
    }else if(data == "Jul"){
      month = 07;
    }else if(data == "Aug"){
      month = 08;
    }else if(data == "Sep"){
      month = 09;
    }else if(data == "Oct"){
      month = 10;
    }else if(data == "Nov"){
      month = 11;
    }else if(data == "Dec"){
      month = 12;
    }else{
      month = 01;
    }
    return month;
  }
}