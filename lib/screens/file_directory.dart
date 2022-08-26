import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

import '../utility/store_strings.dart';

class FileDirectory {
  Directory? directory;
  final String folderType;
  final BuildContext context;

  FileDirectory(this.context, this.folderType);

  Future<Directory> createFolder() async {
    try {
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        String newPath = "";
        List<String> paths = directory!.path.split("/");
        for (int x = 1; x < paths.length; x++) {
          String folder = paths[x];
          if (folder != "Android") {
            newPath += "/$folder";
          } else {
            break;
          }
        }

        if (folderType == MyConstants.imageFolder) {
          newPath = "$newPath/FieldPro/Images";
        } else if (folderType == MyConstants.documentFolder) {
          newPath = "$newPath/FieldPro/Document";
        }
        directory = Directory(newPath);
      } else {
        directory = await getTemporaryDirectory();
      }
    } catch (e) {
      print(e);
    }

    return directory!;
  }
}
