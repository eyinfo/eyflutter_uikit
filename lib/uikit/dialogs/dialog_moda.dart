import 'package:flutter/material.dart';

class DialogModa {
  void showWidget({required BuildContext context, required Widget widget, String title = "", double height = 300}) {
    Widget buildContent() {
      return Stack(
        children: [
          Container(
            padding: EdgeInsets.only(top: 10),
            alignment: Alignment.topCenter,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              color: Colors.white,
            ),
            child: Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              child: SizedBox(width: 40, height: 40, child: Icon(Icons.clear)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(top: 40, left: 0, right: 0, bottom: 0, child: widget)
        ],
      );
    }

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (BuildContext context) {
          return buildContent();
        });
  }
}
