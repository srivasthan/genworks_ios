import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;

import '../network/api_services.dart';
import '../utility/store_strings.dart';
import '../utility/validator.dart';
import 'login.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Future<void> resetPassword() async {
      if (await checkInternetConnection() == true) {
        final form = formKey.currentState;
        if (form!.validate()) {
          form.save();
          showAlertDialog(context);
          final Map<String, dynamic> data = {'email': emailController.text};

          // done , now run app
          ApiService apiService = ApiService(dio.Dio());

          final response = await apiService.forgotPassword(data);

          switch (response.forgotPasswordEntity!.responseCode) {
            case "200":
              {
                FocusScope.of(context).requestFocus(FocusNode());
                Navigator.of(context, rootNavigator: true).pop();
                setToastMessage(
                    context, response.forgotPasswordEntity!.message!);
                Future.delayed(const Duration(seconds: 2), () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Login()));
                });
                break;
              }
            case "400":

            case "500":
              {
                Navigator.of(context, rootNavigator: true).pop();

                FocusScopeNode currentFocus = FocusScope.of(context);

                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                setToastMessage(
                    context, response.forgotPasswordEntity!.message!);
                break;
              }
          }
        }
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        setToastMessage(context, MyConstants.internetConnection);
      }
    }

    Future<T?> pushPage<T>(BuildContext context) {
      return Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));
    }

    return WillPopScope(
      onWillPop: () async {
        pushPage(context);
        return true;
      },
      child: MaterialApp(
          home: Scaffold(
              resizeToAvoidBottomInset: false,
              body: Builder(
                builder: (BuildContext context) {
                  return Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image:
                            AssetImage("assets/images/loginscreen_backgrd.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Form(
                        key: formKey,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                          child: Card(
                            color: Colors.white,
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            margin:
                                const EdgeInsets.only(right: 15.0, left: 15.0),
                            child: Wrap(
                              children: <Widget>[
                                Center(
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 20.0),
                                    child: const Text(
                                      'Forgot Password',
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20.0, right: 20.0, left: 20.0),
                                  child: TextFormField(
                                    keyboardType:
                                        TextInputType.emailAddress,
                                    controller: emailController,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    decoration: const InputDecoration(
                                        labelText: 'Email',
                                        contentPadding: EdgeInsets.fromLTRB(
                                            10, 10, 10, 0),
                                        border: OutlineInputBorder(),
                                        prefixIcon:
                                            Icon(Icons.mail_outline_sharp)),
                                    validator: validateEmail,
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: GestureDetector(
                                      onTap: () {
                                        resetPassword();
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Container(
                                          width: 150,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(int.parse(
                                                    "0xfff" "898e8f")),
                                                Color(int.parse(
                                                    "0xfff" "507a7d"))
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black12,
                                                offset: Offset(5, 5),
                                                blurRadius: 10,
                                              )
                                            ],
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Send',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ))),
    );
  }
}
