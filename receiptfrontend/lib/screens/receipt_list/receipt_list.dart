import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

import 'package:receiptfrontend/constants/colors.dart';
import 'package:receiptfrontend/constants/gradients.dart';
import 'package:receiptfrontend/screens/auth/login_screen.dart';
import 'package:receiptfrontend/screens/receipt/receipt.dart';
import 'package:receiptfrontend/screens/receipt_list/receipts_gql.dart';
import 'package:receiptfrontend/screens/receipt_list/receipt_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:receiptfrontend/constants/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

class ReceiptList extends StatefulWidget {
  ReceiptList({Key key}) : super(key: key);

  @override
  State createState() => new ReceiptListState();
}

class ReceiptListState extends State<ReceiptList> {
  Future<List<Receipt>> _queryData;
  List<Receipt> receipts;

  @override
  void initState() {
    super.initState();
    _queryData = queryReceiptList();
  }

  @override
  Widget build(BuildContext ctxt) {
    return new Expanded(
      flex: 1,
      child: ListView(
        children: <Widget>[
          FutureBuilder<List<Receipt>>(
            future: _queryData,
            builder: (BuildContext context, AsyncSnapshot<List<Receipt>> snapshot) {
              if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
                if (receipts == null) {
                  receipts = snapshot.data;
                }

                return receiptListComponent(receipts);
              } else {
                return receiptListComponent([]);
              }
            },
          )
        ],
      )
    );
  }

  void addReceipt(Receipt receipt) {
    if (receipt != null) {
      setState(() {
        receipts.add(receipt);
      });
    }
  }

  Widget receiptListComponent(List<Receipt> receipts) {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(indent: 60, height: 0),
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: receipts.length ?? 0,
      itemBuilder: (context, index) => receiptItem(context, receipts[index]),
    );
  }

  Widget receiptItem(context, Receipt receipt) {
    return InkWell(
      splashColor: BLUE_SHADOW,
      highlightColor: WHITE_COLOR.withOpacity(.5),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ReceiptItemWidget(receipt: receipt)),
        );

        //Push the receipt closeup
      },
      child: ListTile(
        title: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              receipt.shop,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
            Text(
              receipt.getFormatedDate(),
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Color(0xFF979797)),
            ),
          ],
        ),
        subtitle: new Container(
          padding: EdgeInsets.only(top: 5),
          child: new Text(
            receipt.getTotalPrice().toStringAsFixed(2) + '€',
            maxLines: 1,
            style: TextStyle(fontSize: 14, color: Color(0xFF979797)),
          )
        ),
      ),
    );
  }

  Future<List<Receipt>> queryReceiptList() async {
    final Directory documentsDir = await getApplicationDocumentsDirectory();

    Directory receiptsDir = new Directory(path.join(documentsDir.path, 'receipts'));

    try {
      receiptsDir.createSync();
    } catch (_) {
      print("Error creating receipts dir.");
      return null;
    }

    List<Receipt> loadedReceipts = [];

    var entityList = receiptsDir.listSync(recursive: false, followLinks: false);

    for (FileSystemEntity entity in entityList) {
      if (entity is File && path.extension(entity.path) == '.json') {
        File file = entity;
        Receipt receipt;

        try {
          final fileJson = jsonDecode(await file.readAsString());
          receipt = new Receipt.fromJson(fileJson);
        } catch(_) {
          print("Error loading json file " + file.path + " - " + _.toString());
          continue;
        }
        
        loadedReceipts.add(receipt);
      }
    }

    //TODO: Use checksum to compare the local receipts with the server most updated ones
    if (loadedReceipts.isEmpty) {
      final preferences = await SharedPreferences.getInstance();
      http.Response response;
      bool caught = false;

      try {
        response = await http.get(globals.backend_addr + 'receipts/', 
              headers: {'Authorization': 'Token ' + preferences.getString('auth_token')});

      } catch(_) {
        print(_.toString());
        caught = true;
      }

      if (!caught && response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        int index = 0;

        for (var receiptJson in jsonResponse) {
          loadedReceipts.add(new Receipt.fromJson(receiptJson));

          //Create file and put jsonEncode(receiptJson)
          File file = await new File(path.join(receiptsDir.path, index.toString()) + '.json').create();
          file.writeAsString(jsonEncode(receiptJson));

          index++;
        }

      } else {
        print('Error getting receipt data ');
      }
    }

    loadedReceipts.sort((a, b) => a.creationDate.compareTo(b.creationDate));

    return loadedReceipts;
  }
}