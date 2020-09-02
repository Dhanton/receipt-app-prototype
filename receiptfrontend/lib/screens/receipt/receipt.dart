import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:receiptfrontend/constants/colors.dart';
import 'package:receiptfrontend/constants/gradients.dart';
import 'package:receiptfrontend/screens/auth/login_screen.dart';
import 'package:receiptfrontend/screens/receipt_list/receipt_model.dart';

class ReceiptItemWidget extends StatelessWidget {
  final Receipt receipt;

  @override
  Widget build(BuildContext context) => Scaffold(body: body(context));

  ReceiptItemWidget({@required this.receipt});

  Widget body(context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: LIGHT_GREEN,
        title: Text('Receipt details', style: TextStyle(fontSize: 25)),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text('Shop: ' + receipt.shop, style: TextStyle(fontSize: 17)),
                    subtitle: Text('Date: ' + DateFormat.jm().add_yMd().format(receipt.creationDate), style: TextStyle(fontSize: 16)),
                  ),
                ],
              )
            ),
            ListView.separated(
              separatorBuilder: (context, index) => Divider(indent: 60, height: 0),
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: receipt.items.length ?? 0,
              itemBuilder: (context, index) => receiptItemCloseup(context, receipt.items[index]),
            )
          ],
        )
      ),
    );
  }
}

Widget receiptItemCloseup(context, ReceiptItem receipt) {
    return ListTile(
      title: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(receipt.name),
          Container(margin: EdgeInsets.only(left: 15)),
          Text('x' + receipt.quantity.toString()),
        ],
      ),
      subtitle: new Container(
        padding: EdgeInsets.only(top: 5),
        child: new Text(
          receipt.price.toStringAsFixed(2) + '€',
          maxLines: 1,
          style: TextStyle(fontSize: 14, color: Color(0xFF979797)),
        )
      ),
    );
  }