import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr/qr.dart';
import 'package:receiptfrontend/constants/colors.dart';
import 'package:receiptfrontend/screens/qr/qr_render.dart';
import 'package:receiptfrontend/screens/receipt/receipt.dart';
import 'package:receiptfrontend/screens/receipt_list/receipt_model.dart';

import 'package:http/http.dart' as http;
import 'package:receiptfrontend/constants/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

class ReceiptGeneratorScreen extends StatefulWidget {
  @override
  State createState() => new _ReceiptGeneratorScreen();
}

class _ReceiptGeneratorScreen extends State<ReceiptGeneratorScreen> {
  List<ReceiptItem> items = [];

  final TextEditingController shopController = new TextEditingController();
  final TextEditingController nameController = new TextEditingController();
  final TextEditingController quantityController = new TextEditingController(text: '1');
  final TextEditingController priceController = new TextEditingController();

  @override
  Widget build (BuildContext ctxt) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: LIGHT_GREEN,
        title: Text('Generate receipt', style: TextStyle(fontSize: 25),),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: shopController,
            decoration: InputDecoration(
              labelText: 'Shop'
            ),
          ),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Name'
            ),
          ),
          TextField(
            controller: quantityController,
            decoration: InputDecoration(
              labelText: 'Quantity'
            ),
            
          ),
          TextField(
            controller: priceController,
            decoration: InputDecoration(
              labelText: 'Price'
            ),
          ),
          Expanded(
            child: ListView.builder
              (
                itemCount: items.length,
                itemBuilder: (BuildContext ctxt, int index) {
                return InkWell(
                  splashColor: BLUE_SHADOW,
                  highlightColor: WHITE_COLOR.withOpacity(.5),
                  onTap: () {
                    setState(() {
                      items.removeAt(index);
                    });
                  },
                  child: receiptItemCloseup(ctxt, items[index])
                  );
                },
            )
        )
        ],

      ),
      persistentFooterButtons: <Widget>[
        FlatButton(
          color: LIGHT_GREEN,
          shape: CircleBorder(),
          child: new Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            ReceiptItem item;

            try {
              item = new ReceiptItem(
                name: nameController.text, 
                quantity: int.parse(quantityController.text), 
                price: double.parse(priceController.text)
              );
            } catch(_) {
              print("Error parsing controller text data");
              return;
            }

            setState(() {
              items.add(item);
            });

            nameController.clear();
            quantityController.text = '1';
            priceController.clear();
          },
        ),
        FloatingActionButton(
          backgroundColor: LIGHT_GREEN,
          child: new Icon(
            Icons.done,
          ),
          onPressed: () async {
            //Generate receipt from all the items + shop name + current time()
            Receipt receipt;

            if (shopController.text.isEmpty) {
              print('Error creating final receipt');
              return;
            }

            try {
              receipt = new Receipt(
                shop: shopController.text,
                creationDate: DateTime.now(),
                items: items
              );
            } catch(_) {
              print('Error creating final receipt');
              return;
            }

            final preferences = await SharedPreferences.getInstance();
            http.Response response;
            bool caught = false;
            String auth_hash;

            try {
              response = await http.post(globals.backend_addr + 'generate-receipt/', 
                    headers: {'Authorization': 'Token ' + preferences.getString('auth_token')}, body: jsonEncode(receipt.toJson()));

            } catch(_) {
              print(_.toString());
              caught = true;
            }

            if (!caught && response.statusCode == 200) {
              auth_hash = response.body;

              Navigator.pop(context);
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => Scaffold(
                  appBar: AppBar(
                    backgroundColor: LIGHT_GREEN,
                    title: Text('QR Image', style: TextStyle(fontSize: 25),),
                  ),
                  body: Container(
                    alignment: Alignment.center,
                    child: QrImage(data: auth_hash, size: 200.0, errorCorrectionLevel: QrErrorCorrectLevel.M)
                  ),
                )));
            } else {
              print('Error getting generation receipt in API ');
            }
          },
        ),
      ],
    );
  }
}