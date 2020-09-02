import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:receiptfrontend/screens/receipt_list/receipt_model.dart';
import 'package:receiptfrontend/screens/qr_scanner/qr_code_scanner.dart';
import 'package:receiptfrontend/screens/qr_scanner/qr_scanner_overlay_shape.dart';

import 'package:http/http.dart' as http;
import 'package:receiptfrontend/constants/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:receiptfrontend/constants/colors.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

Future<Receipt> scanQR() async {
  String token;

  try {
    token = await BarcodeScanner.scan();

    //for some reason the token is wrapped around double quotes
    token = token.replaceAll('"', '');

  } on PlatformException catch (ex) {
    if (ex.code == BarcodeScanner.CameraAccessDenied) {
      print("Camera permission was denied");
    } else {
      print("Unknown Error $ex");
    }

    return null;
  } on FormatException {
      print("The back button was pressed before scanning anything");
      return null;
  } catch (ex) {
      print("Unknown Error $ex");
      return null;
  }

  final preferences = await SharedPreferences.getInstance();
  http.Response response;
  bool caught = false;

  Receipt receipt;

  try {
    response = await http.post(globals.backend_addr + 'verify-receipt/', 
          headers: {'Authorization': 'Token ' + preferences.getString('auth_token')}, body: token);

  } catch(_) {
    print(_.toString());
    caught = true;
  }

  if (!caught && response.statusCode == 200) {
    receipt = Receipt.fromJson(jsonDecode(response.body));
    
  } else {
    print('Error veryfing receipt in API ');
  }

  return receipt;
}

// class QRCamera extends StatefulWidget {
//   @override
//   QRCameraState createState() {
//     return new QRCameraState();
//   }
// }

// class QRCameraState extends State<QRCamera> {
//   String result = "Hey there !";

//   Future _scanQR() async {
//     try {
//       String qrResult = await BarcodeScanner.scan();
//       setState(() {
//         result = qrResult;
//       });
//     } on PlatformException catch (ex) {
//       if (ex.code == BarcodeScanner.CameraAccessDenied) {
//         setState(() {
//           result = "Camera permission was denied";
//           Navigator.pop(context);
//         });
//       } else {
//         setState(() {
//           result = "Unknown Error $ex";
//           Navigator.pop(context);
//         });
//       }
//     } on FormatException {
//       setState(() {
//         result = "You pressed the back button before scanning anything";
//         Navigator.pop(context);
//       });
//     } catch (ex) {
//       setState(() {
//         result = "Unknown Error $ex";
//         Navigator.pop(context);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text("QR Scanner"),
    //   ),
    //   body: Center(
    //     child: Text(
    //       result,
    //       style: new TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
    //     ),
    //   ),
    //   floatingActionButton: FloatingActionButton.extended(
    //     icon: Icon(Icons.camera_alt),
    //     label: Text("Scan"),
    //     onPressed: _scanQR,
    //   ),
    //   floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    // );

//     return _scanQR();
//   }

//   void scanCompleted(String token) async {
//     final preferences = await SharedPreferences.getInstance();
//     http.Response response;
//     bool caught = false;

//     Receipt receipt;

//     try {
//       response = await http.post(globals.backend_addr + 'verify-receipt/', 
//             headers: {'Authorization': 'Token ' + preferences.getString('auth_token')}, body: token);

//     } catch(_) {
//       print(_.toString());
//       caught = true;
//     }

//     if (!caught && response.statusCode == 200) {
//       receipt = Receipt.fromJson(jsonDecode(response.body));
      
//     } else {
//       print('Error getting generation receipt in API ');
//     }

//     Navigator.pop(context, receipt);
//   }
// }

// const flash_on = "FLASH ON";
// const flash_off = "FLASH OFF";
// const front_camera = "FRONT CAMERA";
// const back_camera = "BACK CAMERA";

// class QRViewExample extends StatefulWidget {
//   const QRViewExample({
//     Key key,
//   }) : super(key: key);

//   @override
//   State<StatefulWidget> createState() => _QRViewExampleState();
// }

// class _QRViewExampleState extends State<QRViewExample> {
//   var qrText = "";
//   var flashState = flash_on;
//   var cameraState = front_camera;
//   QRViewController controller;
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: QRView(
//               key: qrKey,
//               onQRViewCreated: _onQRViewCreated,
//               overlay: QrScannerOverlayShape(
//                 borderColor: Colors.red,
//                 borderRadius: 10,
//                 borderLength: 30,
//                 borderWidth: 10,
//                 cutOutSize: 300,
//               ),
//             ),
//             flex: 4,
//           ),
//           Expanded(
//             child: FittedBox(
//               fit: BoxFit.contain,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: <Widget>[
//                   Text("This is the result of scan: $qrText"),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: <Widget>[
//                       Container(
//                         margin: EdgeInsets.all(8.0),
//                         child: RaisedButton(
//                           onPressed: () {
//                             if (controller != null) {
//                               controller.toggleFlash();
//                               if (_isFlashOn(flashState)) {
//                                 setState(() {
//                                   flashState = flash_off;
//                                 });
//                               } else {
//                                 setState(() {
//                                   flashState = flash_on;
//                                 });
//                               }
//                             }
//                           },
//                           child:
//                               Text(flashState, style: TextStyle(fontSize: 20)),
//                         ),
//                       ),
//                       Container(
//                         margin: EdgeInsets.all(8.0),
//                         child: RaisedButton(
//                           onPressed: () {
//                             if (controller != null) {
//                               controller.flipCamera();
//                               if (_isBackCamera(cameraState)) {
//                                 setState(() {
//                                   cameraState = front_camera;
//                                 });
//                               } else {
//                                 setState(() {
//                                   cameraState = back_camera;
//                                 });
//                               }
//                             }
//                           },
//                           child:
//                               Text(cameraState, style: TextStyle(fontSize: 20)),
//                         ),
//                       )
//                     ],
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: <Widget>[
//                       Container(
//                         margin: EdgeInsets.all(8.0),
//                         child: RaisedButton(
//                           onPressed: () {
//                             controller?.pauseCamera();
//                           },
//                           child: Text('pause', style: TextStyle(fontSize: 20)),
//                         ),
//                       ),
//                       Container(
//                         margin: EdgeInsets.all(8.0),
//                         child: RaisedButton(
//                           onPressed: () {
//                             controller?.resumeCamera();
//                           },
//                           child: Text('resume', style: TextStyle(fontSize: 20)),
//                         ),
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             flex: 1,
//           )
//         ],
//       ),
//     );
//   }

//   _isFlashOn(String current) {
//     return flash_on == current;
//   }

//   _isBackCamera(String current) {
//     return back_camera == current;
//   }

//   void _onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) {
//       controller.pauseCamera();
//       setState(() {
//         qrText = scanData;
//       });

//       scanCompleted(scanData);
//     });
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   void scanCompleted(String token) async {
//     final preferences = await SharedPreferences.getInstance();
//     http.Response response;
//     bool caught = false;

//     Receipt receipt;

//     try {
//       response = await http.post(globals.backend_addr + 'verify-receipt/', 
//             headers: {'Authorization': 'Token ' + preferences.getString('auth_token')}, body: token);

//     } catch(_) {
//       print(_.toString());
//       caught = true;
//     }

//     if (!caught && response.statusCode == 200) {
//       receipt = Receipt.fromJson(jsonDecode(response.body));
      
//     } else {
//       print('Error getting generation receipt in API ');
//     }

//     Navigator.pop(context, receipt);
//   }
// }