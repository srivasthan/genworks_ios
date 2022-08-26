import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:upgrader/upgrader.dart';

import '../network/Response/login_response.dart';
import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/validator.dart';
import 'dashboard.dart';
import 'forgot_password.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? _fcmToken;
  bool _isPasswordHidden = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        getToken();
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
      });
    }
  }

  Future<void> getToken() async {
    if (await checkInternetConnection() == true) {
      _fcmToken = await FirebaseMessaging.instance.getToken();
    } else {
      return setToastMessage(context, MyConstants.internetConnection);
    }
  }

  void _toggleVisibility() {
    setState(() {
      FocusScope.of(context).requestFocus(FocusNode());
      _isPasswordHidden = !_isPasswordHidden;
    });
  }

  @override
  void initState() {
    super.initState();
    initializeFlutterFire();
    PreferenceUtils.init();
  }

  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    doLogin(BuildContext context) async {
      final form = formKey.currentState;

      if (form!.validate()) {
        form.save();
        if (await checkInternetConnection() == true) {
          showAlertDialog(context);

          String? deviceType, deviceName, osVersion;
          DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

          //getting package details using package_info_plus plugin
          PackageInfo packageInfo = await PackageInfo.fromPlatform();
          String buildNumber = packageInfo.version;

          if (Platform.isAndroid) {
            deviceType = "android";
            AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
            deviceName =
                '${androidDeviceInfo.manufacturer}-${androidDeviceInfo.model}';
            osVersion = androidDeviceInfo.version.release;
          } else {
            deviceType = "ios";
            IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
            deviceName = '${iosInfo.name}-${iosInfo.model}';
            osVersion = iosInfo.systemVersion;
          }

          final Map<String, dynamic> loginData = {
            'username': emailController.text.trim(),
            'password': passwordController.text.trim(),
            'device_token': _fcmToken,
            'device_type': deviceType,
            'device_model': deviceName,
            'device_os': osVersion,
            'app_version': buildNumber
          };


          PreferenceUtils.setString("password", passwordController.text.trim());

          final Response result = await Dio().request(
              'https://genworks.kaspontech.com/djadmin_qa/technician_login/',
              queryParameters: <String, dynamic>{},
              options: Options(
                  method: 'POST',
                  headers: {'Content-Type': 'application/json'},
                  extra: <String, dynamic>{}),
              data: loginData);

          final value = result.data;
          String responseCode = value!['response']['response_code'];

          print(value);

          if (responseCode == MyConstants.response500) {
            Navigator.of(context, rootNavigator: true).pop();
            FocusScope.of(context).requestFocus(FocusNode());
            if (value['response']['message'] !=
                MyConstants.checkYourCredentials) {
              showSweetAlert(context, MyConstants.loginDialog);
            } else {
              setToastMessage(context, value['response']['message']);
            }
          } else if (responseCode == MyConstants.response200) {
            Navigator.of(context, rootNavigator: true).pop();
            final value = LoginResponse.fromJson(result.data);
            PreferenceUtils.setDouble("technician_rating",
                value.loginEntity!.technicianRating!.toDouble());
            PreferenceUtils.setString("token", value.loginEntity!.token!);
            PreferenceUtils.setString(
                "username", value.loginEntity!.loginDetails!.username!);
            PreferenceUtils.setString(
                "name", capitalize(value.loginEntity!.loginDetails!.name!));
            PreferenceUtils.setInteger(
                "technician_id", value.loginEntity!.userDetails!.technicianId!);
            PreferenceUtils.setString("technician_code",
                value.loginEntity!.userDetails!.technicianCode!);
            PreferenceUtils.setInteger(
                "role_id", value.loginEntity!.userDetails!.role!.roleId!);
            PreferenceUtils.setString(
                "role_name", value.loginEntity!.userDetails!.role!.roleName!);
            PreferenceUtils.setInteger("punch_status", 0);
            if (value.loginEntity!.userDetails!.profilePic != null) {
              PreferenceUtils.setString(MyConstants.profilePicture,
                  value.loginEntity!.userDetails!.profilePic!);
            } else {
              PreferenceUtils.setString(
                  MyConstants.profilePicture, MyConstants.empty);
            }

            setToastMessage(context, value.loginEntity!.message!);
            FocusScope.of(context).requestFocus(FocusNode());

            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => DashBoard()));
            });
          }
        } else {
          return setToastMessage(context, MyConstants.internetConnection);
        }
      } else {
        return setToastMessage(context, MyConstants.emptyForm);
      }
    }

    // Platform messages are asynchronous, so we initialize in an async method.
    Future<void> checkForUpdate(String appState) async {
      if (await checkInternetConnection() == true) {
        updateAlertDialog(context);
        InAppUpdate.checkForUpdate().then((info) {
          setState(() {
            if (info.updateAvailability == 1) {
              Navigator.of(context, rootNavigator: true).pop();
              ArtSweetAlert.show(
                  context: context,
                  artDialogArgs: ArtDialogArgs(
                      type: ArtSweetAlertType.success,
                      title: MyConstants.appTittle,
                      text: MyConstants.latestVersion,
                      confirmButtonText: MyConstants.okButton,
                      onConfirm: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        if (appState == MyConstants.loginClick) doLogin(context);
                      },
                      confirmButtonColor:
                          Color(int.parse("0xfff" "507a7d"))));
            } else if (info.updateAvailability == 2) {
              InAppUpdate.performImmediateUpdate().then((_) {
                setState(() {
                  Navigator.of(context, rootNavigator: true).pop();
                  Future.delayed(const Duration(seconds: 1), () {
                    setToastMessage(context, MyConstants.inAppUpdateSuccess);
                    if (appState == MyConstants.loginClick) doLogin(context);
                  });
                });
              }).catchError((e) {
                Navigator.of(context, rootNavigator: true).pop();
                doLogin(context);
              });
            }
          });
        }).catchError((e) {
          Navigator.of(context, rootNavigator: true).pop();
          doLogin(context);
        });
      } else {
        setToastMessage(context, MyConstants.internetConnection);
      }
    }

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: UpgradeAlert(
          child: Builder(
            builder: (BuildContext context) {
              return Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/loginscreen_backgrd.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Form(
                  key: formKey,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Card(
                        color: Colors.white,
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        margin: const EdgeInsets.only(right: 15.0, left: 15.0),
                        child: Wrap(
                          children: <Widget>[
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(top: 20.0),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(fontSize: 20.0),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 20.0, right: 20.0, left: 20.0),
                              child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                controller: emailController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: const InputDecoration(
                                    labelText: 'Email',
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder(),
                                    prefixIcon:
                                        Icon(Icons.person_add_alt_1)),
                                validator: validateEmail,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 20.0, right: 20.0, left: 20.0),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                controller: passwordController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                    labelText: 'Password',
                                    contentPadding:
                                        const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      onPressed: _toggleVisibility,
                                      icon: _isPasswordHidden
                                          ? const Icon(Icons.visibility_off)
                                          : const Icon(Icons.visibility),
                                    )),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Please enter password";
                                  }
                                  return null;
                                },
                                obscureText: _isPasswordHidden,
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Container(
                                  width: 150,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(
                                            int.parse("0xfff" "898e8f")),
                                        Color(int.parse("0xfff" "507a7d"))
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        offset: Offset(5, 5),
                                        blurRadius: 10,
                                      )
                                    ],
                                  ),
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        checkForUpdate(
                                            MyConstants.loginClick);
                                      },
                                      child: const Text('SIGN IN',
                                          style: TextStyle(
                                            color: Colors.white,
                                          )),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Container(
                                margin: const EdgeInsets.only(
                                    top: 10.0, bottom: 15.0),
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ForgotPassword()));
                                    },
                                    child: Text(
                                      "Forgot Password?",
                                      style: TextStyle(
                                          color: Color(int.parse(
                                              "0xfff" "2b6c72")),
                                          fontSize: 15.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ));
  }
}
