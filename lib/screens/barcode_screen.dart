import 'dart:developer';
import 'dart:io';

import 'package:final_project_yroz/screens/physical_payment_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRViewExample extends StatefulWidget {
  static const routeName = '/barcode-screen';

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Expanded(flex: 4, child: _buildQrView(context, deviceSize)),
              Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      if (result != null)
                        _openUrl(result!)
                            .build(context) // to change for another action
                      else
                        Container(
                          margin: EdgeInsets.all(deviceSize.width * 0.05),
                          child: ElevatedButton(
                            onPressed: () async {
                              await controller?.pauseCamera();
                            },
                            child: Text('SCAN', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            ],
          ),
          Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(top: deviceSize.height * 0.025),
            child: IconButton(
              onPressed: () async {
                await controller?.flipCamera();
                setState(() {});
              },
              icon: Icon(Icons.flip_camera_ios_outlined,
                  color: Theme.of(context).primaryColor),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context, Size deviceSize) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = deviceSize.width * 0.7;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class _openUrl {
  final Barcode result;

  _openUrl(this.result);

  void _launchPayment(context, url) async =>
      Navigator.of(context).pushNamed(PhysicalPaymentScreen.routeName,
          arguments: {'store': url.toString()});

  @override
  Widget build(BuildContext context) {
    _launchPayment(context, result.code);
    return Text(
        'Barcode Type: ${describeEnum(result.format)}   Data: ${result.code}');
  }
}
