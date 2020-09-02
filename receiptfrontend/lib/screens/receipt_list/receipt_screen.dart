import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

import 'package:receiptfrontend/constants/colors.dart';
import 'package:receiptfrontend/constants/gradients.dart';
import 'package:receiptfrontend/screens/auth/login_screen.dart';
import 'package:receiptfrontend/screens/receipt/receipt_generator.dart';
import 'package:receiptfrontend/screens/receipt_list/receipts_gql.dart';
import 'package:receiptfrontend/screens/receipt_list/receipt_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

import 'package:receiptfrontend/screens/receipt_list/receipt_list.dart';
import 'package:receiptfrontend/screens/qr/qr_render.dart';
import 'package:receiptfrontend/screens/qr_scanner/qr_screen.dart';
import 'package:path_provider/path_provider.dart';

class ReceiptListScreen extends StatelessWidget {
  final GlobalKey<ReceiptListState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) => Scaffold(body: body(context));

  Widget body(context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(margin: EdgeInsets.only(top: 60)),
          // Padding(
            // padding: const EdgeInsets.only(left: 30),
            gradientTextComponent(
              BLUE_GRADIENT,
              // "Your Receipts",
              "Reciby",
              align: TextAlign.center,
              size: 36,
            // ),
          ),
          // mainListComponent(context),
          new ReceiptList(key: _key),
          bottomBarComponent(context)
        ],
      ),
    );
  }

  Widget bottomBarComponent(context) {
    return Container(
      padding: EdgeInsets.only(left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(OMIcons.settings),
            color: Colors.grey[500],
            onPressed: () {
              //check user is shop manager??
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ReceiptGeneratorScreen()));
            },
          ),
          GestureDetector(
            onTap: () async {
              final Receipt receipt = await scanQR();

              if (receipt != null) {
                //Add receipt to list
                _key.currentState.addReceipt(receipt);

                //Save it to json file
                final Directory documentsDir = await getApplicationDocumentsDirectory();
                File file = await new File(path.join(documentsDir.path, 'receipts', (_key.currentState.receipts.length - 1).toString()) + '.json').create();
                file.writeAsString(jsonEncode(receipt));
              }
            },
            child: Container(
              height: 55,
              width: 170,
              padding: EdgeInsets.only(left: 15),
              decoration: BoxDecoration(
                gradient: BLUE_GRADIENT,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(100)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.camera_alt, size: 22, color: WHITE_COLOR),
                  Container(margin: EdgeInsets.only(left: 10)),
                  Text(
                    "SCAN QR",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      color: WHITE_COLOR,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}