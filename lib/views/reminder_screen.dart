import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reminderapp/views/edit_reminder.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final Stream<QuerySnapshot> _reminderStream = FirebaseFirestore.instance
        .collection('reminders')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .orderBy('highPriority',descending: true)
        .orderBy('timeCompleted', descending: false)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reminders'),
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

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final reminderData = snapshot.data!.docs[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              reminderData['reminderTitle'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 19,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            reminderData['reminderDate'],
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        reminderData['reminderDescription'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            reminderData['highPriority']
                                ? Icons.priority_high
                                : Icons.low_priority,
                            color: reminderData['highPriority']
                                ? Colors.red
                                : Colors.green,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            reminderData['highPriority']
                                ? 'High Priority'
                                : 'Low Priority',
                            style: TextStyle(
                              color: reminderData['highPriority']
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)
                              {
                                return EditReminder(reminderId: reminderData['reminderid']);
                              }));
                              // Edit Reminder functionality
                            },
                            child: const Text('Edit'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              // Delete Reminder functionality
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Delete',
                            style: TextStyle(
                              color: Colors.lime,
                            ),),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
