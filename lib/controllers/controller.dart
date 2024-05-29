import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reminderapp/variables.dart';
import 'package:reminderapp/views/upload_screen.dart';

class ReminderController{
 
    deriveData() async
  {
     var collection=FirebaseFirestore.instance.collection('reminders');
     var querySnapshot = await collection.get();
     for(var doc in querySnapshot.docs)
       {
         Map<String,dynamic> data=doc.data();
         if(data['timecompleted']==false)
           {
             String prior=data['highPriority']==true? 'high' : 'low';

             Reminder reminder=Reminder(data['reminderDate'], data['reminderTitle'], data['reminderDescription'], prior,data['reminderid']);
             reminderList.add(reminder);
             print(reminderList);
           }
       }
  }
}