// class Constants{
//
//   static final String BASE_URL = 'https://fcm.googleapis.com/fcm/send';
//   static final String KEY_SERVER = 'AAAAYCBPdG0:APA91bGRehkDsZXbxbcE17TbBcTz1Kau91duFBgIgsOukMhWb8T6eiGpm3v-rKptVGwTKIKYvQ9Ej80WPli7XWuLok6VV3fjgxSmQqCIupofe_hvkHe6i7XJLq5lUN_VsAnf3jQHGn9W';
//   static final String SENDER_ID = '412858938477';
//
// }
//
//
// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'high_importance_channel', // id
//     'High Importance Notifications', // title
//     'This channel is used for important notifications.', // description
//     importance: Importance.high,
//     playSound: true);
//
//
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// FlutterLocalNotificationsPlugin();
//
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('A bg message just showed up :  ${message.messageId}');
// }
//
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//       AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);
//
//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
//   runApp(MyApp());
// }
//
// Future<bool> pushNotificationsAllUsers({
//   required String title,
//   required String body,
// }) async {
//   // FirebaseMessaging.instance.subscribeToTopic("myTopic1");
//
//   String dataNotifications = '{ '
//       ' "to" : "/topics/myTopic1" , '
//       ' "notification" : {'
//       ' "title":"$title" , '
//       ' "body":"$body" '
//       ' } '
//       ' } ';
//
//   var response = await http.post(
//     Uri.parse(Constants.BASE_URL),
//     headers: <String, String>{
//       'Content-Type': 'application/json',
//       'Authorization': 'key= ${Constants.KEY_SERVER}',
//     },
//     body: dataNotifications,
//   );
//   print(response.body.toString());
//   return true;
// }
//
// Future<String> token() async {
//   return await FirebaseMessaging.instance.getToken() ?? "";
// }
//
//
// void showNotification() {
//   setState(() {
//     _counter++;
//   });
//   flutterLocalNotificationsPlugin.show(
//       0,
//       "Testing $_counter",
//       "How you doin ?",
//       NotificationDetails(
//           android: AndroidNotificationDetails(
//               channel.id, channel.name, channel.description,
//               importance: Importance.high,
//               color: Colors.blue,
//               playSound: true,
//               icon: '@mipmap/ic_launcher')));
// }
//
//
// bool check() {
//   if (_textTitle.text.isNotEmpty && _textBody.text.isNotEmpty) {
//     return true;
//   }
//   return false;
// }
// }
