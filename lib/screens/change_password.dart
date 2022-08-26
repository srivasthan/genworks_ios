import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_pw_validator/flutter_pw_validator.dart';

import '../network/api_services.dart';
import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/validator.dart';
import 'dashboard.dart';

class ChangePassword extends StatefulWidget {
  @override
  _PasswordChange createState() => _PasswordChange();
}

class _PasswordChange extends State<ChangePassword> {
  final formKey = GlobalKey<FormState>();
  String? getEmail, _password, token;
  bool _enabled = true;
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  // Initially password is obscure
  bool _isOldPasswordHidden = true,
      _isNewPasswordHidden = true,
      _isConfirmPasswordHidden = true;

  void _oldToggleVisibility() {
    setState(() {
      _isOldPasswordHidden = !_isOldPasswordHidden;
    });
  }

  void _newToggleVisibility() {
    setState(() {
      _isNewPasswordHidden = !_isNewPasswordHidden;
    });
  }

  void _confirmToggleVisibility() {
    setState(() {
      _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
    });
  }

  setDetails(BuildContext context) async {
    token = PreferenceUtils.getString(MyConstants.token);
    PreferenceUtils.setString(
        MyConstants.technicianStatus, MyConstants.free);
    _password = PreferenceUtils.getString("password");
    getEmail = PreferenceUtils.getString(MyConstants.email);
    Navigator.of(context, rootNavigator: true).pop();
    setState(() {
      _enabled = !_enabled;
    });
  }

  @override
  void initState() {
    super.initState();
    PreferenceUtils.init();
    Future.delayed(Duration.zero, () {
      showAlertDialog(context);
      setDetails(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    changePassword(BuildContext context) async {
      final form = formKey.currentState;

      if (form!.validate()) {
        form.save();

        if (await checkInternetConnection() == true) {
          showAlertDialog(context);

          final Map<String, dynamic> data = {
            'email': getEmail,
            'old_password': oldPasswordController.text,
            'new_password': passwordController.text,
            'confirm_password': confirmPasswordController.text
          };

          // done , now run app
          ApiService apiService = ApiService(dio.Dio());

          final response = await apiService.changePassword(token!, data);

          if (response.changePasswordEntity!.responseCode == '200') {
            setState(() {
              PreferenceUtils.setString("password", passwordController.text);
              Navigator.of(context, rootNavigator: true).pop();
              setToastMessage(context, response.changePasswordEntity!.message!);
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => DashBoard()));
              });
            });
          } else if (response.changePasswordEntity!.responseCode == '400' ||
              response.changePasswordEntity!.responseCode == '500') {
            setState(() {
              Navigator.of(context, rootNavigator: true).pop();
              setToastMessage(context, response.changePasswordEntity!.message!);
            });
          }
        } else {
          return setToastMessage(
              context, MyConstants.internetConnection);
        }
      } else {
        return setToastMessage(context, MyConstants.emptyForm);
      }
    }

    Future<T?> pushPage<T>(BuildContext context) {
      return Navigator.push(context,
          MaterialPageRoute(builder: (context) => DashBoard()));
    }

    return WillPopScope(
      onWillPop: () async {
        pushPage(context);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DashBoard())),
              ),
              title: const Text('Change Password'),
              backgroundColor: Color(int.parse("0xfff" "507a7d")),
            ),
            body: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(40.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.visiblePassword,
                          controller: oldPasswordController,
                          decoration: InputDecoration(
                            labelText: "Old Password",
                            contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: _oldToggleVisibility,
                              icon: _isOldPasswordHidden
                                  ? const Icon(Icons.visibility_off)
                                  : const Icon(Icons.visibility),
                            ),
                          ),
                          validator: (value) {
                            if (oldPasswordController.text.isEmpty) {
                              return "Please Enter Old Password";
                            } else if (oldPasswordController.text.toString() !=
                                _password) {
                              return "Old Password didn't match";
                            }
                            return null;
                          },
                          obscureText: _isOldPasswordHidden),
                      const SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        obscureText: _isNewPasswordHidden,
                        keyboardType: TextInputType.visiblePassword,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: passwordController,
                        validator: validatePassword,
                        decoration: InputDecoration(
                          labelText: "New Password",
                          contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: _newToggleVisibility,
                            icon: _isNewPasswordHidden
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                          ),
                        ),
                      ),
                      FlutterPwValidator(
                        controller: passwordController,
                        minLength: 6,
                        uppercaseCharCount: 1,
                        numericCharCount: 1,
                        width: 400,
                        height: 140,
                        onSuccess: () {},
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.visiblePassword,
                          controller: confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: _confirmToggleVisibility,
                              icon: _isConfirmPasswordHidden
                                  ? const Icon(Icons.visibility_off)
                                  : const Icon(Icons.visibility),
                            ),
                          ),
                          obscureText: _isConfirmPasswordHidden,
                          validator: (value) {
                            if (passwordController.text.isEmpty) {
                              return "Please Enter Confirm Password";
                            } else if (passwordController.text.toString() !=
                                confirmPasswordController.text.toString()) {
                              return "Password and Confirm Password didn't match";
                            }
                            return null;
                          }),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: GestureDetector(
                            onTap: () {
                              changePassword(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                width: 150,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(int.parse("0xfff" "898e8f")),
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
                                child: const Center(
                                  child: Text(
                                    'Change Password',
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
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }
}
