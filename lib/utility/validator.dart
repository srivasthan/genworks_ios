import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:edge_alerts/edge_alerts.dart';
import 'package:fieldpro_genworks_healthcare/utility/store_strings.dart';
import 'package:flutter/material.dart';
import 'package:art_sweetalert/art_sweetalert.dart';

String? validateEmail(String? value) {
  RegExp regex = RegExp(
      r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
  if (value!.isEmpty) {
    return "Please enter email";
  } else if (!regex.hasMatch(value)) {
    return "Please provide a valid email address";
  }
  return null;
}

String? validatePassword(String? value) {
  RegExp regex = RegExp(r"[$&+,:;=\\?@#|/'<>.^*()%!-]");
  RegExp regexNumber = RegExp("[0123456789]");
  RegExp regexUppercase = RegExp("[A-Z]");

  if (value!.isEmpty) {
    return "Please enter password";
  } else if (value.length < 6) {
    return "Password must contain at least 6 characters";
  } else if (!regexUppercase.hasMatch(value)) {
    return "Password must contain at least one upper character";
  } else if (!regexNumber.hasMatch(value)) {
    return "Password must contain at least one number";
  } else if (!regex.hasMatch(value)) {
    return "Password should have one special character";
  }
  return null;
}

capitalize(String text) {
  return text[0].toUpperCase() + text.substring(1);
}

showAlertDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Row(
      children: [
        CircularProgressIndicator(
          color: Color(int.parse("0xfff" "507a7d")),
        ),
        Container(margin: const EdgeInsets.only(left: 5), child: const Text("Loading")),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showVideoDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Row(
      children: [
        CircularProgressIndicator(
          color: Color(int.parse("0xfff" "507a7d")),
        ),
        Container(margin: const EdgeInsets.only(left: 5), child: const Text("Processing Video")),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showImageDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Row(
      children: [
        CircularProgressIndicator(
          color: Color(int.parse("0xfff" "507a7d")),
        ),
        Container(margin: const EdgeInsets.only(left: 5), child: const Text("Processing Image")),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

updateAlertDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Row(
      children: [
        CircularProgressIndicator(
          color: Color(int.parse("0xfff" "507a7d")),
        ),
        Container(margin: const EdgeInsets.only(left: 5), child: const Text("Checking for updates")),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

downloadingDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Row(
      children: [
        CircularProgressIndicator(
          color: Color(int.parse("0xfff" "507a7d")),
        ),
        Container(margin: const EdgeInsets.only(left: 5), child: const Text("Downloading Please wait...")),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

attachmentDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Row(
      children: [
        CircularProgressIndicator(
          color: Color(int.parse("0xfff" "507a7d")),
        ),
        Container(margin: const EdgeInsets.only(left: 5), child: const Text("Image uploading please wait...")),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

videoAlertDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Row(
      children: [
        CircularProgressIndicator(
          color: Color(int.parse("0xfff" "507a7d")),
        ),
        Container(
            margin: const EdgeInsets.only(left: 5), child: const Text("Saving video")),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return alert;
    },
  );
}

Future<bool> checkInternetConnection() async {
  var result = await Connectivity().checkConnectivity();
  if (result == ConnectivityResult.wifi ||
      result == ConnectivityResult.mobile) {
    return true;
  } else {
    return false;
  }
}

void setToastMessage(BuildContext context, String message) {
  edgeAlert(
    context,
    title: MyConstants.appName,
    description: message,
    gravity: Gravity.top,
    backgroundColor: Color(int.parse("0xfff" "2b6c72")),
    icon: Icons.add_alert,
  );
}

void setToastMessageLoading(BuildContext context) {
  edgeAlert(
    context,
    title: MyConstants.appName,
    description: MyConstants.loading,
    gravity: Gravity.top,
    backgroundColor: Color(int.parse("0xfff" "2b6c72")),
    icon: Icons.autorenew,
  );
}

void checkingUpdate(BuildContext context) {
  edgeAlert(
    context,
    title: MyConstants.appName,
    description: MyConstants.updateLoading,
    gravity: Gravity.top,duration: 3,
    backgroundColor: Color(int.parse("0xfff" "2b6c72")),
    icon: Icons.autorenew,
  );
}

void showSweetAlert(BuildContext context, String description) {
  ArtSweetAlert.show(
      context: context,
      artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.warning,
          title: MyConstants.appTittle,
          text: description,
          confirmButtonText: MyConstants.okButton,
          confirmButtonColor: Color(int.parse("0xfff" "507a7d"))));
}
