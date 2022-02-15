import 'package:firebase_chat_app/dialogs/dismissible_alert_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsHelper {
  static Map<Permission, String> permissionStatusToStringMap = {
    Permission.storage: "Storage",
  };
  static Future<bool> permissionRequest({
    required BuildContext context,
    required List<Permission> permissions,
  }) async {
    for (int i = 0; i < permissions.length; i++) {
      Permission permission = permissions[i];
      PermissionStatus status = await permission.status;
      if (status.isGranted) {
        continue;
      } else {
        status = await permission.request();
        if (status.isGranted) {
          continue;
        } else {
          showDialog(
              context: context,
              builder: (context) {
                return DismissibleAlertDialog(
                  title:
                      "${permissionStatusToStringMap[permission]} permission is required to do this, please grant permission in your device's App Management settings.",
                );
              });
          return false;
        }
      }
    }
    return true;
  }
}
