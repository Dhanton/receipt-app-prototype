import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:receiptfrontend/constants/globals.dart' as globals;

Future<bool> verifyToken() async {
    final preferences = await SharedPreferences.getInstance();
    
    if (preferences.containsKey('auth_token')) {
      bool caught = false;
      http.Response response;

      try {
        response = await http.get(globals.backend_addr + 'verify-auth-token/', 
              headers: {'Authorization': 'Token ' + preferences.getString('auth_token')});

      } catch(_) {
        caught = true;
        print('Error verifying token ' + _.toString());
      }

      if (!caught && response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('is_shop_manager')) {
          preferences.setBool('is_shop_manager', jsonResponse['is_shop_manager']);
        } else {
          preferences.setBool('is_shop_manager', false);
        }

        return true;
      }

    }

    preferences.remove('auth_token');

    return false;
  }