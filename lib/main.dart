import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/main_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainController());
    return GetMaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView(
          padding: const EdgeInsets.only(top: 30),
          children: <Widget>[
            Obx(() => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (controller.supportState == SupportState.unknown)
                  const CircularProgressIndicator()
                else if (controller.supportState == SupportState.supported)
                  const Text('This device is supported')
                else
                  const Text('This device is not supported'),
                const Divider(height: 100),
                Text('Can check biometrics: ${controller.canCheckBiometrics}\n'),
                ElevatedButton(
                  onPressed: controller.checkBiometrics,
                  child: const Text('Check biometrics'),
                ),
                const Divider(height: 100),
                Text('Available biometrics: ${controller.availableBiometrics}\n'),
                ElevatedButton(
                  onPressed: controller.getAvailableBiometrics,
                  child: const Text('Get available biometrics'),
                ),
                const Divider(height: 100),
                Text('Current State: ${controller.authorized}\n'),
                if (controller.isAuthenticating)
                  ElevatedButton(
                    onPressed: controller.cancelAuthentication,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        Text('Cancel Authentication'),
                        Icon(Icons.cancel),
                      ],
                    ),
                  )
                else
                  Column(
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: controller.authenticate,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const <Widget>[
                            Text('Authenticate'),
                            Icon(Icons.perm_device_information),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: controller.authenticateWithBiometrics,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(controller.isAuthenticating
                                ? 'Cancel'
                                : 'Authenticate: biometrics only'),
                            const Icon(Icons.fingerprint),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}