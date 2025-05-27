import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'app_colors.dart';

class MyToastHelper {
  static showLoadingDialog() {
    EasyLoading.show(
      maskType: EasyLoadingMaskType.black,
      dismissOnTap: false,
      indicator: SpinKitCubeGrid(
        size: 40.0,
        itemBuilder: (context, index) {
          return Container(
            height: 10,
            width: 10,
            margin: const EdgeInsets.all(1),
            decoration: const BoxDecoration(
              color: AppColors.color26386A,
              shape: BoxShape.circle,
            ),
          );
        },
      ),
      // status: LocaleKeys.wait.tr()
    );
  }

  static showLoadingView({Color? color}) {
    return Center(
      child: SpinKitCubeGrid(color: color ?? AppColors.color26386A, size: 40.0),
    );
  }

  // static showConfirmDialog({
  //   required BuildContext context,
  //   required String title,
  //   required Function() confirm,
  // }) {
  //   return showCupertinoDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return _alertDialog(title, confirm, context, LocaleKeys.confirm.tr());
  //     },
  //   );
  // }

  // static Widget _alertDialog(
  //   String title,
  //   Function() confirm,
  //   BuildContext context,
  //   String okText,
  // ) {
  //   return CupertinoAlertDialog(
  //     title: MyText(title: title, size: 12, color: colorTextBlack),
  //     // content: MyText(title: title,size: 12,color: MyColors.blackOpacity,),
  //     actions: [
  //       CupertinoDialogAction(
  //         child: MyText(
  //           title: LocaleKeys.back.tr(),
  //           size: 12,
  //           color: blackOpacity,
  //         ),
  //         onPressed: () => Navigator.pop(context),
  //       ),
  //       CupertinoDialogAction(
  //         onPressed: confirm,
  //         child: MyText(title: okText, size: 12, color: blackOpacity),
  //       ),
  //     ],
  //   );
  // }

  static errorBar(msg, {Color? color, Color? textColor, Alignment? alignment}) {
    BotToast.showSimpleNotification(
      title: msg,
      animationReverseDuration: const Duration(milliseconds: 500),
      animationDuration: const Duration(milliseconds: 500),
      backButtonBehavior: BackButtonBehavior.close,
      align: alignment ?? Alignment.topCenter,
      backgroundColor: color ?? Colors.red,
      //blackOpacity,
      titleStyle: TextStyle(
        color: textColor ?? Colors.white,
        letterSpacing: 0,
      ),
      duration: const Duration(seconds: 2),
      hideCloseButton: false,
      enableSlideOff: true,
      enableKeyboardSafeArea: true,
    );
  }

  static infoBar(
    String msg, {
    Color? color,
    Color? textColor,
    Alignment? alignment,
  }) {
    BotToast.showSimpleNotification(
      title: msg,
      animationReverseDuration: const Duration(milliseconds: 500),
      animationDuration: const Duration(milliseconds: 500),
      backButtonBehavior: BackButtonBehavior.close,
      align: alignment ?? Alignment.bottomCenter,
      backgroundColor: color ?? Colors.black,
      titleStyle: TextStyle(
        color: textColor ?? Colors.white,
        letterSpacing: 0,
      ),
      duration: const Duration(seconds: 2),
      hideCloseButton: false,
      enableSlideOff: true,
      enableKeyboardSafeArea: true,
    );
  }

  // static infoBar(msg,
  //     {Color? color, Color? textColor, Alignment? alignment}) {
  //   BotToast.showSimpleNotification(
  //     title: msg,
  //     animationReverseDuration: const Duration(seconds: 1, milliseconds: 500),
  //     animationDuration: const Duration(seconds: 1, milliseconds: 500),
  //     backButtonBehavior: BackButtonBehavior.close,
  //     align: alignment ?? Alignment.bottomCenter,
  //     backgroundColor: color ?? blackOpacity,
  //     titleStyle: TextStyle(
  //         color: textColor ?? colorTextWhite, fontFamily: FontFamily.regular),
  //     duration: const Duration(seconds: 3),
  //     hideCloseButton: false,
  //     enableSlideOff: true,
  //     enableKeyboardSafeArea: true,
  //   );
  // }

  static successBar(
    msg, {
    Color? color,
    Color? textColor,
    Alignment? alignment,
  }) {
    BotToast.showSimpleNotification(
      title: msg,
      animationReverseDuration: const Duration(milliseconds: 500),
      animationDuration: const Duration(milliseconds: 500),
      backButtonBehavior: BackButtonBehavior.close,
      align: alignment ?? Alignment.bottomCenter,
      backgroundColor: color ?? Colors.black,
      titleStyle: TextStyle(
        color: textColor ?? Colors.white,
      ),
      duration: const Duration(seconds: 2),
      hideCloseButton: false,
      enableSlideOff: true,
      enableKeyboardSafeArea: true,
    );
  }

  static showSimpleToast(msg) {
    BotToast.showText(text: msg);
  }

  static dismiss() {
    EasyLoading.dismiss();
  }
}
