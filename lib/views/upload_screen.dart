import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:flutter/services.dart';
import 'package:flutter_autostart/flutter_autostart.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:reminderapp/controllers/controller.dart';
import 'package:uuid/uuid.dart';

import '../services.dart';
import '../variables.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;

  late String reminderTitle;
  late String reminderDescription;
  late String time;
  late String priorityValue;
  final reminderTitleText= TextEditingController();
  final reminderDescriptionText=TextEditingController();
  final timeText=TextEditingController();
  final priorityValueText=TextEditingController();
  List<String>priority=['high','low'];
  late DateTime scheduleTime;
  Timer? timer;
  bool value=false;
  final GlobalKey<FormState> _key=GlobalKey<FormState>();

  @override
  initState()  {





    // TODO: implement initState
    super.initState();



    ReminderController reminderController=ReminderController();
    reminderController.deriveData();
    timer = Timer.periodic(Duration(seconds: 15), (Timer t) async
    {
      var collection=FirebaseFirestore.instance.collection('reminders');
      var querySnapshot = await collection.get();
      for(var doc in querySnapshot.docs)
      {
        print('Hi'+ doc.id);
        Map<String,dynamic> data=doc.data();
        if(data['timeCompleted']==false && data['userId']==FirebaseAuth.instance.currentUser!.uid)
        {
          String prior=data['highPriority']==true? 'high' : 'low';

          Reminder reminder=Reminder(data['reminderDate'], data['reminderTitle'], data['reminderDescription'], prior,data['reminderid']);
          reminderList.add(reminder);
          print(reminderList);
        }
        print(reminderList);
      }
      //   print(DateTime.now());
      //  print(scheduleTime);

      if(reminderList.isNotEmpty) {
        for(int j=0;j<reminderList.length;j++)
        {
          final dt1 = DateTime.parse(DateTime.now().toString());
          final dt2 = DateTime.parse(reminderList[j].time);
          print(dt1);
          print(dt2);
          if(dt1.millisecondsSinceEpoch ~/ 1000>dt2.millisecondsSinceEpoch ~/ 1000)
          {
            NotificationService().showNotification(
                title: reminderList[j].title,
                body: reminderList[j].body
            );

            final ref = FirebaseFirestore.instance.collection("reminders").doc(reminderList[j].id);
            ref.update({"timeCompleted" : true}).then(
                    (value) => print("DocumentSnapshot successfully updated!"),
                onError: (e) => print("Error updating document $e"));



            reminderList.removeAt(j);


          }
          // print(value);



        }


      }
    });
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload Reminder'
        ),
      ),
      body: Form(
        key: _key,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInputSection(
                label: 'Enter Reminder Name',
                hint: 'Enter Reminder name',
                controllerText: reminderTitleText,
                onChanged: (value) => reminderTitle=value,
                validator: (value) => value!.isEmpty ? 'Enter Reminder name' : null,
              ),
              _buildInputSection(
                label: 'Reminder Description',
                hint: 'Enter reminder description',
                maxLines: 10,
                minLines: 1,
                maxLength: 800,
                onChanged: (value) {
                  reminderDescription=value;
                  print(reminderDescription);
                },
                controllerText: reminderDescriptionText,
                validator: (value) => value!.isEmpty ? 'Enter reminder description' : null,
              ),
              _buildDropdownSection(
                label: 'Select Priority',
                items: priority,
                onChanged: (value) => {
                  priorityValue=value,
                  print(priorityValue)
                },
              ),
              TextButton(onPressed: ()
              {
                picker.DatePicker.showDateTimePicker(context,
                    showTitleActions: true,
                    onChanged: (date){
                  scheduleTime=date;
                  print(scheduleTime);
                    },
                    onConfirm: (date){}
                );
              }, child: Text('Select Date and time',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),)),
              ElevatedButton(onPressed: () async
              {

                final reminderId=Uuid().v4();

                if(_key.currentState!.validate())
                  {


                    EasyLoading.show(status: 'Please wait');
                    bool val=priorityValue=='high'? true: false;
                    await _firestore.collection('reminders').doc(reminderId)
                    .set(
                      {
                        'reminderid':reminderId,
                        'reminderTitle':reminderTitle,
                        'reminderDescription':reminderDescription,
                        'reminderDate':scheduleTime.toString(),
                        'highPriority':val,
                        'timeCompleted':false,
                        'userId':FirebaseAuth.instance.currentUser!.uid,

                      }
                    ).whenComplete(() {
                      EasyLoading.dismiss();
                      const snackBar = SnackBar(
                        content: Text('Your reminder is saved'),
                        backgroundColor: Colors.green,
                        elevation: 10,
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.all(5),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      reminderTitleText.clear();
                      reminderDescriptionText.clear();
                      setState(() {

                      });
                    });

                    final _flutterAutostartPlugin = FlutterAutostart();

                    String isAutoStartEnabled;
                    try {
                      isAutoStartEnabled = await _flutterAutostartPlugin.checkIsAutoStartEnabled() == true ? "Yes" : "No";
                      print("isAutoStartEnabled: $isAutoStartEnabled");
                    } on PlatformException {
                      isAutoStartEnabled = 'Failed to check isAutoStartEnabled.';
                    }

                    String autoStartPermission;
                    try {
                      autoStartPermission =
                          await _flutterAutostartPlugin.showAutoStartPermissionSettings() ?? 'Unknown autoStartPermission';
                    } on PlatformException {
                      autoStartPermission = 'Failed to show autoStartPermission.';
                    }

                  }





                print(scheduleTime.timeZoneName);
                print('Notification Scheduled for $scheduleTime');
                setState(() {

                  Reminder newReminder=  Reminder(scheduleTime.toString(),reminderTitle,reminderDescription,priorityValue,reminderId);
                  reminderList.add(newReminder);

                });

              }, child: Text('Save Reminder')),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildInputSection({
    required String label,
    required String hint,
    required void Function(String) onChanged,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int minLines = 1,
    int? maxLength,
     required TextEditingController controllerText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Reduced padding
        decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(8.0),

        ),
        child: TextFormField(
          validator: validator,
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          controller: controllerText,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0), // Adjusted padding
            labelText: label,
            hintText: hint,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildDropdownSection({
    required String label,
    required List<String> items,
    required void Function(dynamic) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Reduced padding
        decoration: BoxDecoration(
          // color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),

        ),
        child: DropdownButtonFormField(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0), // Adjusted padding
            labelText: label,
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          items: items.map<DropdownMenuItem<dynamic>>((e) {
            return DropdownMenuItem(value: e, child: Text(e));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }



}


class Reminder{
  String time;
  String title;
  String body;
  String priorityValue;
  String id;

  Reminder(this.time,this.title,this.body,this.priorityValue,this.id);
}
