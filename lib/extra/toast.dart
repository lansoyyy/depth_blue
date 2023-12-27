import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


void showToast(
    BuildContext context,
    String message,
    Color backgroundColor,
    Color textColor, {
      double? top,
      double? bottom,
      Map<String, double>? horizontal,
      Duration duration = const Duration(seconds: 1), // Default duration is 1 second
    }) {
  assert((horizontal != null &&
      horizontal.containsKey('left') &&
      horizontal.containsKey('right')) ||
      horizontal == null);

  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: top,
      bottom: bottom,
      left: horizontal != null ? horizontal['left'] : null,
      right: horizontal != null ? horizontal['right'] : null,
      child: Material(
        color: Colors.transparent,
        child: CustomToast(message: message, backgroundColor: backgroundColor, textColor: textColor),
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry);

  // Remove the toast after the specified duration
  Future.delayed(duration, () {
    overlayEntry.remove();
  });
}

class CustomToast extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;

  const CustomToast({super.key, required this.message, required this.backgroundColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 12.0, // Adjust the font size as needed
            ),
          ),
    );
  }
}

void showToastErr(String message){
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 12.0
  );
}


void showToastOk(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 12.0
  );
}

// void showToastInfo(String message) {
//   Fluttertoast.showToast(
//     msg: message,
//     toastLength: Toast.LENGTH_SHORT,
//     gravity: ToastGravity.BOTTOM,
//     timeInSecForIosWeb: 1,
//     backgroundColor: Colors.blue,
//     textColor: Colors.white,
//     fontSize: 12.0,
//   );
// }