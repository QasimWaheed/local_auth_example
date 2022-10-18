import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

enum SupportState {
  unknown,
  supported,
  unsupported,
}

class MainController extends GetxController {
  final LocalAuthentication auth = LocalAuthentication();
  final Rx<SupportState> _supportState = Rx<SupportState>(SupportState.unknown);
  final RxnBool _canCheckBiometrics = RxnBool();
  final RxList<BiometricType> _availableBiometrics = RxList<BiometricType>();
  final RxString _authorized = RxString('Not Authorized');
  final RxBool _isAuthenticating = RxBool(false);

  @override
  void onInit() {
    super.onInit();
    auth.isDeviceSupported().then(
          (bool isSupported) => supportState =
              isSupported ? SupportState.supported : SupportState.unsupported,
        );
  }

  Future<void> checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      Get.log(e.message.toString());
    }
    _canCheckBiometrics(canCheckBiometrics);
  }

  Future<void> getAvailableBiometrics() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      Get.log(e.message.toString());
    }
    _availableBiometrics.assignAll(availableBiometrics);
  }

  Future<void> authenticate() async {
    bool authenticated = false;
    try {
      _isAuthenticating(true);
      _authorized('Authenticating');
      authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );

      _isAuthenticating(false);
    } on PlatformException catch (e) {
      Get.log(e.message!.toString());

      _isAuthenticating(false);
      _authorized('Error - ${e.message}');
      return;
    }

    _authorized(authenticated ? 'Authorized' : 'Not Authorized');
  }

  Future<void> authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      _isAuthenticating(true);
      _authorized('Authenticating');
      authenticated = await auth.authenticate(
        localizedReason:
            'Scan your fingerprint (or face or whatever) to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      _isAuthenticating(false);
      _authorized('Authenticating');
    } on PlatformException catch (e) {
      Get.log(e.message.toString());
      _isAuthenticating(false);
      _authorized('Error - ${e.message}');
      return;
    }

    final String message = authenticated ? 'Authorized' : 'Not Authorized';

    _authorized(message);
  }

  Future<void> cancelAuthentication() async {
    await auth.stopAuthentication();
    _isAuthenticating(false);
  }

  bool get isAuthenticating => _isAuthenticating.value;

  set isAuthenticating(bool value) {
    _isAuthenticating(value);
  }

  String get authorized => _authorized.value;

  set authorized(String value) {
    _authorized(value);
  }

  bool? get canCheckBiometrics => _canCheckBiometrics.value;

  set canCheckBiometrics(bool? value) {
    _canCheckBiometrics(value);
  }

  SupportState get supportState => _supportState.value;

  set supportState(SupportState value) {
    _supportState(value);
  }

  List<BiometricType> get availableBiometrics =>
      List<BiometricType>.from(_availableBiometrics);
}
