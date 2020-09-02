import 'package:intl/intl.dart';
import 'dart:convert';

class ReceiptItem {
  final String name;
  final int quantity;
  final double price;

  ReceiptItem({this.name, this.price, this.quantity});

  ReceiptItem.fromJson(Map<String, dynamic> json)
    : name = json['name'],
      quantity = json['quantity'],
      price = json['price'];

  Map<String, dynamic> toJson() =>
    {
      'name': name,
      'quantity': quantity,
      'price': price
    };
}

class Receipt {
  final String shop;
  final DateTime creationDate;
  DateTime expirationDate;
  bool isReturnable;

  List<ReceiptItem> items;

  Receipt({this.shop, this.creationDate, this.expirationDate, this.isReturnable = false, this.items});

  double getTotalPrice()
  {
    double total = 0.0;
    items.forEach((item) => total += item.price);
    return total;
  }

  String getFormatedDate()
  {
    var now = DateTime.now();

    if (creationDate.isAfter(DateTime(now.year, now.month, now.day - 1))) {
      return new DateFormat.Hm().format(creationDate);
    } else if (creationDate.isAfter(DateTime(now.year, now.month, now.day - 2))) {
      return "Yesterday";
    } else {
      return new DateFormat.yMd().format(creationDate);
    }
  }

  Receipt.fromJson(Map<String, dynamic> json)
    : shop = json['shop'],
      //We use parse here because we want it to throw and exception, since creation date value is 
      creationDate = DateTime.parse(json['creation_date'])
  {
    isReturnable = json.containsKey('is_returnable') ? json['is_returnable'] : false;
    
    //We use tryParse here because we want dont care if it returns null 
    if (json.containsKey('expiration_date')) {
      expirationDate = DateTime.tryParse(json['expiration_date']);
    }

    items = [];
    for (Map<String, dynamic> jsonItem in json['items']) {
      items.add(new ReceiptItem.fromJson(jsonItem));
    }
  }

  Map<String, dynamic> toJson()
  {
    Map<String, dynamic> json = new Map<String, dynamic>();

    json['shop'] = shop;
    json['is_returnable'] = isReturnable;
    json['creation_date'] = creationDate.toIso8601String();

    if (expirationDate != null) {
      json['expiration_date'] = expirationDate.toIso8601String();
    }

    json['items'] = new List<Map<String, dynamic>>();

    for (ReceiptItem item in items) {
      json['items'].add(item.toJson());
    }

    return json;
  }

}