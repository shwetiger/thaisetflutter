// @dart=2.9
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:thai2dlive/pages/notification_detail.dart';
import 'package:thai2dlive/pages/twod_page.dart';
import 'package:thai2dlive/providers/twod_provider.dart';
import 'data/constant.dart';
import 'data/data_key_name.dart';
import 'data/database_helper.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'models/notification_page_obj.dart';
import 'providers/login_provider.dart';
import 'package:intl/date_symbol_data_local.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_thai2dlive_channel', 'High thai2d3d Notifications',
    description: 'This channel is used for thai2d3d notifications.',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
    sound: RawResourceAndroidNotificationSound('noti'));

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await DatabaseHelper.setData("", DataKeyValue.backgroundNotiStatus);
}

Future<void> cancelNotification() async {
  await flutterLocalNotificationsPlugin.cancelAll();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await initializeDateFormatting();
  if (!kIsWeb) {
    await FlutterDownloader.initialize(
        debug: true // optional: set false to disable printing logs to console
        );
  }

  GestureBinding.instance?.resamplingEnabled = true;

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      liveQueryUrl: keyLiveQueryUrl,
      debug: false, // When enabled, prints logs to console
      clientKey: keyClientKey,
      autoSendSessionId: true);

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => TwoDProvider()),
    ChangeNotifierProvider(create: (_) => LoginProvider()),
  ], child: const MyApp()));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);
  static final navKey = GlobalKey<NavigatorState>();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  FirebaseMessaging _messaging = FirebaseMessaging.instance;
  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      registerNotification(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (BuildContext context, Widget child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          key: key,
          navigatorKey: MyApp.navKey,
          home: const TwoDPage(),
          title: "Thai 2D Live",
          theme: ThemeData(
              // ThemeData configuration goes here
              ),
        );
      },
    );
  }

  void registerNotification(BuildContext context) async {
    _messaging = FirebaseMessaging.instance;
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const IOSInitializationSettings initializationSettingsIos =
        IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    const MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIos,
            macOS: initializationSettingsMacOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      checkForInitialMessage();
      onMessage();
      onMessageOpenedApp(context);
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
      await checkForInitialMessage();
      await onMessage();
      onMessageOpenedApp(context);
    } else {}
  }

  checkForInitialMessage() async {
    var backgroundNotificationStatus =
        await DatabaseHelper.getData(DataKeyValue.backgroundNotiStatus);

    await Firebase.initializeApp();
    RemoteMessage initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null &&
        (backgroundNotificationStatus == null ||
            backgroundNotificationStatus == "")) {
      //print("Initial initialmsg: $initialMessage");
      NotificationPageObj _notification = NotificationPageObj(
        id: int.parse(initialMessage.data['id']),
        body: initialMessage.data['body'].toString(),
        type: initialMessage.data['type'].toString(),
        title: initialMessage.data['title'].toString(),
        clickAction: initialMessage.data["click_action"].toString(),
        number: initialMessage.data['number'].toString(),
        fortime: initialMessage.data['fortime'].toString(),
        currentdate: initialMessage.data['currentdate'].toString(),
        status: initialMessage.data['status'].toString(),
      );
      //print("Initial noti: $_notification");
      await MyApp.navKey.currentState.push(
        MaterialPageRoute(
          builder: (_) => NotificationDetailPage(item: _notification),
        ),
      );
    }
  }

  onMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      var androidPlatformChannel = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelShowBadge: true,
        channelDescription: channel.description,
        color: const Color.fromARGB(255, 0, 0, 0),
        importance: Importance.max,
        sound: const RawResourceAndroidNotificationSound('noti'),
        playSound: true,
        priority: Priority.high,
      );

      var platform =
          NotificationDetails(android: androidPlatformChannel, iOS: null);

      await flutterLocalNotificationsPlugin.show(
          0,
          message.data['type'].toString(),
          message.data['title'].toString() +
              " " +
              message.data['body'].toString(),
          platform,
          payload: message.data['body'].toString());

      Timer(const Duration(seconds: 4), () {
        flutterLocalNotificationsPlugin.cancel(0);
      });

      print("On Message msg: $message");
      NotificationPageObj _notification = NotificationPageObj(
        id: int.parse(message.data['id']),
        body: message.data['body'].toString(),
        type: message.data['type'].toString(),
        title: message.data['title'].toString(),
        clickAction: message.data["click_action"].toString(),
        number: message.data['number'].toString(),
        fortime: message.data['fortime'].toString(),
        currentdate: message.data['currentdate'].toString(),
        status: message.data['status'].toString(),
      );
      // print("On Message noti: $_notification");

      final context = MyApp.navKey.currentState.overlay.context;
      _showAlertDialog(context, _notification);
    });
  }

  onMessageOpenedApp(BuildContext context) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      // print("On Message opened App msg: $message");
      NotificationPageObj _notification = NotificationPageObj(
        id: int.parse(message.data['id']),
        body: message.data['body'].toString(),
        type: message.data['type'].toString(),
        title: message.data['title'].toString(),
        clickAction: message.data["click_action"].toString(),
        number: message.data['number'].toString(),
        fortime: message.data['fortime'].toString(),
        currentdate: message.data['currentdate'].toString(),
        status: message.data['status'].toString(),
      );

      //print("On Message opened App noti: $_notification");

      await MyApp.navKey.currentState.push(
        MaterialPageRoute(
          builder: (_) => NotificationDetailPage(item: _notification),
        ),
      );
    });
  }

  Future<void> _showAlertDialog(
      BuildContext context, NotificationPageObj _notification) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            actionsPadding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      side: const BorderSide(
                        width: 1.0,
                        color: Colors.black12,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: const Text(
                      "    Close    ",
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      return null;
                    },
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      side: const BorderSide(
                        width: 1.0,
                        color: Colors.black12,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: const Text(
                      "Go to Detail",
                      // 3/4/2022 2:51:31 PM
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await MyApp.navKey.currentState.push(
                        MaterialPageRoute(
                          builder: (_) =>
                              NotificationDetailPage(item: _notification),
                        ),
                      );
                    },
                  ),
                ],
              ),
              // OutlinedButton(
              //   style: OutlinedButton.styleFrom(
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(18.0),
              //     ),
              //     side: const BorderSide(
              //       width: 1.0,
              //       color: Colors.black12,
              //       style: BorderStyle.solid,
              //     ),
              //   ),
              //   child: const Text(
              //     "Close",
              //   ),
              //   onPressed: () {
              //     Navigator.of(context).pop();
              //     return null;
              //   },
              // ),
              // const SizedBox(
              //   width: 20,
              // ),
              // OutlinedButton(
              //   style: OutlinedButton.styleFrom(
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(18.0),
              //     ),
              //     side: const BorderSide(
              //       width: 1.0,
              //       color: Colors.black12,
              //       style: BorderStyle.solid,
              //     ),
              //   ),
              //   child: const Text(
              //     "Go to Detail",
              //     // 3/4/2022 2:51:31 PM
              //   ),
              //   onPressed: () async {
              //     Navigator.of(context).pop();
              //
              //     await MyApp.navKey.currentState.push(
              //       MaterialPageRoute(
              //         builder: (_) =>
              //             NotificationDetailPage(item: _notification),
              //       ),
              //     );
              //   },
              // ),
            ],
            title: Center(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      _notification.type,
                      maxLines: null,
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: RichText(
                    maxLines: null,
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(2, 0, 4, 0),
                            child: Icon(
                              Icons.warning,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        TextSpan(
                          text: "${_notification.title} ${_notification.body}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ));
      },
    );
  }
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}
