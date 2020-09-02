// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';

// import 'package:receiptfrontend/constants/globals.dart' as globals;

// class CameraScreen extends StatefulWidget {
//   CameraScreen();

//   @override
//   CameraScreenState createState() {
//     return new CameraScreenState();
//   }
// }

// class CameraScreenState extends State<CameraScreen> {
//   CameraController controller;

//   @override
//   void initState() {
//     super.initState();
//     controller =
//         new CameraController(globals.cameras[0], ResolutionPreset.medium);
//     controller.initialize().then((_) {
//       if (!mounted) {
//         return;
//       }
//       setState(() {});
//     });
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!controller.value.isInitialized) {
//       return new Container();
//     }
//     return new AspectRatio(
//       aspectRatio: controller.value.aspectRatio,
//       child: new CameraPreview(controller),
//     );
//   }
// }
