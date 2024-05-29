import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;

class EditReminder extends StatefulWidget {
  final String reminderId;
  const EditReminder({super.key, required this.reminderId});

  @override
  State<EditReminder> createState() => _EditReminderState();
}

class _EditReminderState extends State<EditReminder> {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final Stream<QuerySnapshot> _reminderStream = FirebaseFirestore.instance
        .collection('reminders')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .snapshots();

    late String reminderTitle;
    late String reminderDescription;
    late String priorityValue;
    List<String> priority = ['high', 'low'];
    late String reminderTime;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Reminder',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _reminderStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final reminderData = snapshot.data!.docs[index];
                return widget.reminderId == reminderData['reminderid']
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit your reminder title',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      initialValue: reminderData['reminderTitle'],
                      onChanged: (val) {
                        reminderTitle = val;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter reminder title',
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final ref = FirebaseFirestore.instance
                            .collection("reminders")
                            .doc(reminderData['reminderid']);
                        ref.update({"reminderTitle": reminderTitle}).then(
                              (value) => print("DocumentSnapshot successfully updated!"),
                          onError: (e) => print("Error updating document $e"),
                        ).whenComplete(() {
                          const snackBar = SnackBar(
                            content: Text('Your reminder title is updated'),
                            backgroundColor: Colors.green,
                            elevation: 10,
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.all(5),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        });
                      },
                      child: Text('Update reminder title'),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Edit your reminder description',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      initialValue: reminderData['reminderDescription'],
                      onChanged: (val) {
                        reminderDescription = val;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter reminder description',
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final ref = FirebaseFirestore.instance
                            .collection("reminders")
                            .doc(reminderData['reminderid']);
                        ref.update({"reminderDescription": reminderDescription}).then(
                              (value) => print("DocumentSnapshot successfully updated!"),
                          onError: (e) => print("Error updating document $e"),
                        ).whenComplete(() {
                          const snackBar = SnackBar(
                            content: Text('Your reminder description is updated'),
                            backgroundColor: Colors.green,
                            elevation: 10,
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.all(5),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        });
                      },
                      child: Text('Update reminder description'),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Edit your reminder priority',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                        labelText: 'Select priority',
                        labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      items: priority.map<DropdownMenuItem<dynamic>>((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        );
                      }).toList(),
                      onChanged: (value) {
                        priorityValue = value;
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final ref = FirebaseFirestore.instance
                            .collection("reminders")
                            .doc(reminderData['reminderid']);
                        ref.update(priorityValue == 'high'
                            ? {"highPriority": true}
                            : {"highPriority": false}).then(
                              (value) => print("DocumentSnapshot successfully updated!"),
                          onError: (e) => print("Error updating document $e"),
                        ).whenComplete(() {
                          const snackBar = SnackBar(
                            content: Text('Your reminder priority is updated'),
                            backgroundColor: Colors.green,
                            elevation: 10,
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.all(5),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        });
                      },
                      child: Text('Update reminder priority'),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Select Date and Time',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        picker.DatePicker.showDateTimePicker(context,
                            showTitleActions: true,
                            onChanged: (date) {
                              reminderTime = date.toString();
                            },
                            onConfirm: (date) {});
                      },
                      child: Text(
                        'Pick Date and Time',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final ref = FirebaseFirestore.instance
                            .collection("reminders")
                            .doc(reminderData['reminderid']);
                        ref.update({
                          "reminderDate": reminderTime,
                          "timeCompleted": false,
                        }).then(
                              (value) => print("DocumentSnapshot successfully updated!"),
                          onError: (e) => print("Error updating document $e"),
                        ).whenComplete(() {
                          const snackBar = SnackBar(
                            content: Text('Your reminder time is updated'),
                            backgroundColor: Colors.green,
                            elevation: 10,
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.all(5),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        });
                      },
                      child: Text('Update reminder time'),
                    ),
                  ],
                )
                    : Container();
              },
            ),
          );
        },
      ),
    );
  }
}
