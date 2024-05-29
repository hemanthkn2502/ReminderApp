
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService{


  final FlutterLocalNotificationsPlugin notificationsPlugin=
  FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    var initializationSettingsAndroid = AndroidInitializationSettings('notification');
    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {}
    );

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {}
    );

    notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  notificationDetails()
  {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName',icon: "notification",
            importance: Importance.max)
    );
  }

  Future showNotification(
      {
        int id=0,
        String? title,
        String? body,
        String? payload
      }
      ) async{
    return notificationsPlugin.show(id, title, body,await notificationDetails()) ;
  }



  Future scheduleNotification(
      {
        int id=0,
        String? title,
        String? body,
        String? payload,
        required DateTime scheduledNotificationDateTime
      }
      ) async{
    final dt1 = DateTime.parse(DateTime.now().toString());
    final dt2 = DateTime.parse(scheduledNotificationDateTime.toString());

    if(dt1.millisecondsSinceEpoch ~/ 1000>dt2.millisecondsSinceEpoch ~/ 1000)
    {
      return notificationsPlugin.show(id, title, body,await notificationDetails()) ;
    }



  }






}