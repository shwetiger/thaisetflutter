// @dart=2.9
import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thai2dlive/data/constant.dart';
import 'package:thai2dlive/data/sys_data.dart';
import 'package:thai2dlive/models/chat_user.dart';
import 'package:thai2dlive/models/country_model.dart';
import 'package:thai2dlive/utils/message_handel.dart';
import 'package:thai2dlive/utils/validator.dart';
import 'package:provider/provider.dart';
import 'package:thai2dlive/providers/login_provider.dart';
import '../data/constant.dart';
import 'chat.dart';

class UserPhLoginScreen extends StatefulWidget {
  const UserPhLoginScreen({Key key}) : super(key: key);

  @override
  _UserPhLoginScreenState createState() => _UserPhLoginScreenState();
}

class _UserPhLoginScreenState extends State<UserPhLoginScreen> {
  final _phscaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _dialogformKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final _formKey = GlobalKey<FormState>();
  bool isPhoneToken = false;
  String fcmtoken = "";

  List<CountryModel> countries = [
    CountryModel(
      '+95',
      'Myanmar',
      'assets/flags/mm_flag.png',
    ),
    CountryModel(
      '+65',
      'Singapore',
      'assets/flags/sg_flag.png',
    ),
    CountryModel(
      '+60',
      'Malaysia',
      'assets/flags/my_flag.png',
    ),
    CountryModel(
      '+66',
      'Thailand',
      'assets/flags/th_flag.png',
    ),
    CountryModel(
      '+86',
      'China',
      'assets/flags/ch_flag.png',
    ),
  ];
  CountryModel selectedCountry = CountryModel(
    '+95',
    'Myanmar',
    'assets/flags/mm_flag.png',
  );

  @override
  void initState() {
    super.initState();
    selectedCountry = countries.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _phscaffoldKey,
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
        backgroundColor: mainColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Card(
            margin:
                const EdgeInsets.only(top: 0, bottom: 8, right: 16, left: 16),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              padding: const EdgeInsets.only(
                  left: 16, top: 16, right: 16, bottom: 16),
              alignment: Alignment.center,
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        "User Profile",
                        style: TextStyle(
                          color: mainColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextFormField(
                        autofocus: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: _nameController,
                        keyboardType: TextInputType.text,
                        validator: (val) {
                          return Validator.userName(
                              context, val, "User Name", true);
                        },
                        decoration: const InputDecoration(
                          labelText: "User Name",
                          labelStyle: TextStyle(color: mainColor),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color:
                                    mainColor), // Set your desired color here
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 26.0),
                              child: DropdownButton(
                                // underline: Container(),
                                items: countries
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 30,
                                                height: 30,
                                                child: Image.asset(
                                                  e.imgUrl,
                                                  width: 30,
                                                  height: 30,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                              Text(e.countryName),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                                selectedItemBuilder: (context) => countries
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 30,
                                                height: 30,
                                                child: Image.asset(
                                                  e.imgUrl,
                                                  width: 30,
                                                  height: 30,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                              Text("(${e.countryCode})"),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                                isExpanded: true,
                                value: selectedCountry,
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedCountry = newValue;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              controller: _phoneController,
                              validator: (val) {
                                return Validator.registerPhone(
                                    context,
                                    val.toString(),
                                    selectedCountry.countryCode,
                                    true);
                              },
                              keyboardType: TextInputType.phone,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: const InputDecoration(
                                labelText: "Phone",
                                labelStyle: TextStyle(color: mainColor),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          mainColor), // Set your desired color here
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              _showDialog(context);
                              await register();
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                mainColor), // Set your desired color here
                          ),
                          child: const Text(
                            "Login",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String phNoFormat(String phoneNumber) {
    if (selectedCountry.countryCode == '+95') {
      if (phoneNumber.startsWith("0")) {
        phoneNumber = phoneNumber.substring(1, phoneNumber.length);
      }
      phoneNumber = "+95" + phoneNumber;
    } else {
      phoneNumber = selectedCountry.countryCode + phoneNumber;
    }
    return phoneNumber;
  }

  String vId = "";
  Future<void> register() async {
    // setState(() {
    //   isWaiting = true;
    // });

    String phone = phNoFormat(_phoneController.text);
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: phone,
          timeout: const Duration(seconds: timeOut),
          verificationCompleted:
              (PhoneAuthCredential phoneAuthCredential) async {},
          verificationFailed: (FirebaseAuthException authException) {
            String str =
                "Phone number verification failed. Code: @authExceptionCode. Message: @authExceptionMessage"
                    .replaceAll('@authExceptionCode', authException.code)
                    .replaceAll('@authExceptionMessage', authException.message);

            MessageHandel.showSnackbar(str, context, 6);
          },
          codeSent: (String verificationId, [int forceResendingToken]) async {
            MessageHandel.showSnackbar(
                "Please check your phone for the verification code.",
                context,
                6);
            vId = verificationId;
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            vId = verificationId;
          });
    } catch (e) {
      MessageHandel.showSnackbar(
          "Failed to Verify Phone Number: @e".replaceAll('@e', e), context, 6);
    }
    // isWaiting = false;
  }

  Future<void> signInWithPhoneNumber() async {
    String token = await checkToken(fcmtoken);
    int retryCount = 0;
    int retryDelaySeconds = 5;
    ChatUser user = ChatUser(
        name: _nameController.text,
        phoneNo: _phoneController.text,
        fcmtoken: token,
        createdAt: Timestamp.fromDate(DateTime.now()));
    bool isSuccess = await context
        .read<LoginProvider>()
        .register(context, vId, _codeController.text, user);
    if (!isSuccess) {
      if (retryCount >= 3) {
        // Maximum retries reached, return false
        return isSuccess;
      }
      try {
        isSuccess = await context
            .read<LoginProvider>()
            .register(context, vId, _codeController.text, user);
      } catch (e) {
        // Retry with exponential backoff
        retryCount++;
        await Future.delayed(Duration(seconds: retryDelaySeconds));
      }
    }
    // if (isSuccess) {
    //   Navigator.pushAndRemoveUntil(
    //       context,
    //       MaterialPageRoute(
    //         builder: (BuildContext context) => const ChatScreen(),
    //       ),
    //       (route) => false);
    // }
    Navigator.pop(context);
    if (isSuccess) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              // contentPadding:
              //     EdgeInsets.symmetric(vertical: 40, horizontal: 80),
              // insetPadding: EdgeInsets.symmetric(vertical: 40, horizontal: 80),
              // actionsPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              title: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/confirm-check-3091.png',
                      width: 70,
                      height: 70,
                      //alignment: Alignment.center,
                    ),
                  ],
                ),
              ]),
              content: const Text(
                'Registration Successful!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: mainColor, // Change the color to your desired color
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1, // Set the maximum number of lines for the text
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                Container(
                  width: double.infinity, // Set the width as needed
                  alignment: Alignment.center,
                  child: FlatButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => const ChatScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white, // Set the text color
                      ),
                    ),
                    color: mainColor,
                  ),
                ),
              ],
            );
          });
    }
  }

  Future<void> _showDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(16),
          actionsPadding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
          actions: [
            TextButton(
              child: Text(
                "CANCEL",
                style: TextStyle(color: Colors.black87.withOpacity(0.7)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                return null;
              },
            ),
            TextButton(
              child: Text(
                "VERIFY",
                style: TextStyle(color: Colors.black87.withOpacity(0.7)),
              ),
              onPressed: () async {
                if (_dialogformKey.currentState.validate()) {
                  await signInWithPhoneNumber();
                }
              },
            ),
          ],
          title: Center(
            child: Row(
              children: const [
                Flexible(
                  child: Text(
                    "Verification",
                    maxLines: null,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Image.asset(
                    selectedCountry.imgUrl,
                    width: 25,
                    height: 25,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    phNoFormat(_phoneController.text),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                // textBaseline: TextBaseline.,
                children: [
                  const Expanded(
                    flex: 3,
                    child: Text(
                      "We just sent you an SMS with a code. Enter it to verify your phone.\nDidn't receive an SMS? ",
                      style: TextStyle(height: 1.5),
                      // textScaleFactor: 1.5,
                    ),
                    // child: RichText(
                    //   maxLines: null,
                    //   text: TextSpan(
                    //     children: [
                    //       const TextSpan(
                    //         text:
                    //             "We just sent you an SMS with a code. Enter it to verify your phone.\nDidn't receive an SMS? ",
                    //         style: TextStyle(
                    //           fontSize: 16,
                    //           color: Colors.black,
                    //         ),
                    //       ),

                    // // TextSpan(
                    // //   text: "Try again",
                    // //   recognizer: TapGestureRecognizer()
                    // //     ..onTap = () async {
                    // //       await register();
                    // //     },
                    // //   style: const TextStyle(
                    // //     fontSize: 16,
                    // //     color: Colors.blueAccent,
                    // //   ),
                    // // ),
                    //   ],
                    // ),
                    // ),
                  ),
                  // Align(
                  //   alignment: Alignment.bottomRight,
                  //   // padding: const EdgeInsets.only(top: 16.0),
                  //   child:
                  Expanded(
                    flex: 1,
                    child: ArgonTimerButton(
                      initialTimer: 180,
                      highlightColor: Colors.transparent,
                      highlightElevation: 0,
                      roundLoadingShape: false,
                      height: 40,
                      minWidth: 180,
                      width: 100,
                      onTap: (startTimer, btnState) async {
                        if (btnState == ButtonState.Idle) {
                          await register();
                          startTimer(180);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Try again",
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      loader: (timeLeft) {
                        return Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "$timeLeft Sec",
                            style: TextStyle(
                                color: mainColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w700),
                          ),
                        );
                      },
                      borderRadius: 5.0,
                      color: Colors.transparent,
                      elevation: 0,
                      borderSide: BorderSide(
                          // color: Theme.of(context).primaryColor,
                          color: mainColor,
                          // Colors.black.withOpacity(0.2),
                          width: 1.5),
                    ),
                  ),
                  // ),
                ],
              ),
              Form(
                key: _dialogformKey,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextFormField(
                      autofocus: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _codeController,
                      validator: (val) {
                        return Validator.verifyCode(
                            context, val.toString(), true);
                      },
                      keyboardType: const TextInputType.numberWithOptions(),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: const InputDecoration(
                          labelText: "Enter the code",
                          labelStyle: TextStyle(color: mainColor),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: mainColor),
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> checkToken(String fcmtoken) async {
    String tokenStr = "";
    if (!kIsWeb) {
      if (fcmtoken == null || fcmtoken == "") {
        tokenStr = await _messaging.getToken();
        if (tokenStr == null || tokenStr == "") {
          tokenStr = await checkToken(tokenStr);
        } else {
          SystemData.fcmtoken = tokenStr;
        }
        return tokenStr;
      } else {
        return fcmtoken;
      }
    } else {
      return null;
    }
  }
}
