// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:xatoxi_italpay/global/widgets/custom_phone_selector.dart';

import '../../global/constants/app_ref.dart';
import '../../global/constants/color_solid.dart';
import '../../global/i18n/language_str.dart';
import '../../global/utils/custom_encrypt_decrypt.dart';
import '../../global/functions/debug_line.dart';
import '../../global/utils/device_size.dart';
import '../../global/utils/string_content_analysis.dart';
import '../../global/utils/xato_routes.dart';
import '../../global/utils/xatoxi_icons.dart';
import '../../global/widgets/custom_pin_field.dart';
import '../../global/widgets/events/request_failed.dart';
// import '../../global/widgets/events/signature_dialog.dart';
import '../../global/widgets/footer_xatoxi.dart';
import '../../global/widgets/hexagon_button.dart';
import '../../global/widgets/custom_email_field.dart';
import '../../global/widgets/phone/phone_widget2.dart';
import '../../main_menu/widgets/multiline_icon_container.dart';
import '../../settings/data/customize_ui.dart';
import '../data/biometric_tool_data.dart';
import '../data/login_data.dart';
import '../services/login_summit_action.dart';
import '../utils/ios_biometric_auth.dart';
import '../widgets/setting_switches.dart';
import '../widgets/signup_forgot_buttons.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/loginPage';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String email, password, savedPin, savedEmail;
  late TextEditingController emailController, pinController;

  late TextEditingController _phoneController;

  static const List<CountryData> _defaultCountries = [
    CountryData(name: 'Argentina', code: 'AR', dialCode: '+54', flag: '🇦🇷'),
    CountryData(name: 'Brasil', code: 'BR', dialCode: '+55', flag: '🇧🇷'),
    CountryData(name: 'Chile', code: 'CL', dialCode: '+56', flag: '🇨🇱'),
    CountryData(name: 'Colombia', code: 'CO', dialCode: '+57', flag: '🇨🇴'),
    CountryData(name: 'España', code: 'ES', dialCode: '+34', flag: '🇪🇸'),
    CountryData(
      name: 'Estados Unidos',
      code: 'US',
      dialCode: '+1',
      flag: '🇺🇸',
    ),
    CountryData(name: 'Francia', code: 'FR', dialCode: '+33', flag: '🇫🇷'),
    CountryData(name: 'Italia', code: 'IT', dialCode: '+39', flag: '🇮🇹'),
    CountryData(name: 'México', code: 'MX', dialCode: '+52', flag: '🇲🇽'),
    CountryData(name: 'Perú', code: 'PE', dialCode: '+51', flag: '🇵🇪'),
    CountryData(name: 'Reino Unido', code: 'GB', dialCode: '+44', flag: '🇬🇧'),
    CountryData(name: 'Venezuela', code: 'VE', dialCode: '+58', flag: '🇻🇪'),
    CountryData(name: 'Alemania', code: 'DE', dialCode: '+49', flag: '🇩🇪'),
    CountryData(name: 'Canadá', code: 'CA', dialCode: '+1', flag: '🇨🇦'),
    CountryData(name: 'Portugal', code: 'PT', dialCode: '+351', flag: '🇵🇹'),
    CountryData(name: 'Japón', code: 'JP', dialCode: '+81', flag: '🇯🇵'),
    CountryData(name: 'China', code: 'CN', dialCode: '+86', flag: '🇨🇳'),
    CountryData(name: 'India', code: 'IN', dialCode: '+91', flag: '🇮🇳'),
    CountryData(name: 'Australia', code: 'AU', dialCode: '+61', flag: '🇦🇺'),
    CountryData(name: 'Rusia', code: 'RU', dialCode: '+7', flag: '🇷🇺'),
  ];

  @override
  void initState() {
    final i18n = Provider.of<LanguageStr>(context, listen: false);
    XatoRoutes.currentNavigation = CurrentSection.login;
    email = '';
    password = '';

    _phoneController = TextEditingController(text: "+584164309090");

    APPref.setServerRoute();
    debugLine('Current Server: ${APPref.server}', LoginPage.routeName);
    savedEmail = LoginData.previousEmail;
    email = LoginData.previousEmail;
    savedPin = LoginData.previousPin;
    String showPartialEmail = '';
    if (email != '') {
      showPartialEmail = '***${email.substring(email.indexOf('@') - 3)}';
    }
    emailController = TextEditingController(text: showPartialEmail);
    pinController = TextEditingController();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (BiometricToolData.showBiometricButton &&
          savedEmail != '' &&
          savedPin != '' &&
          BiometricToolData.rememberBiometric &&
          Platform.isAndroid) {
        checkAuthWithLocal(
          i18n: i18n,
          tag: 'BiometricLogin',
          email: savedEmail,
          pin: savedPin,
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    debugLine('Login dispose', 'loginDispose');
    emailController.dispose();
    pinController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void popApp() {
    SystemNavigator.pop();
  }

  Future<bool> checkAuthWithLocal({
    required String email,
    required String pin,
    required LanguageStr i18n,
    required String tag,
  }) async {
    debugLine('Current email: $email', 'encryptDecryptTest');
    debugLine(
      'Encrypt result: ${CustomEncryptDecrypt.customEncrypt(
        content: email,
        cryptKey: APPref.customKey,
      )}',
      'encryptDecryptTest',
    );
    debugLine(
      'Decrypt result: ${CustomEncryptDecrypt.customDecrypt(
        encryptedContent: CustomEncryptDecrypt.customEncrypt(
          content: email,
          cryptKey: APPref.customKey,
        ),
        cryptKey: APPref.customKey,
      )}',
      'encryptDecryptTest',
    );
    if (Platform.isAndroid) {
      try {
        bool didAuthenticate =
            await BiometricToolData.authentication.authenticate(
          localizedReason: i18n.text('labelAuthFinger'),
          options: const AuthenticationOptions(
            biometricOnly: true,
          ),
        );
        debugLine('Try local auth', 'tryAuth');
        if (didAuthenticate) {
          debugLine('Auth test success', 'tryAuth');
          if (savedEmail != '' && savedPin != '') {
            loginSummit(
              context,
              tag: tag,
              i18n: i18n,
              email: savedEmail,
              pin: savedPin,
            );
          }
          return true;
        } else {
          debugLine('Auth test failed', 'tryAuth');
          return false;
        }
      } on PlatformException catch (e) {
        debugLine('Auth test exception', 'tryAuth');
        debugLine('test error: $e', 'loginBioTest');
        return false;
      }
    } else {
      bool didAuthenticate =
          await IosBiometricAuth.authenticateWithFingerprint();
      if (didAuthenticate) {
        if (savedEmail != '' && savedPin != '') {
          loginSummit(
            context,
            tag: tag,
            i18n: i18n,
            email: savedEmail,
            pin: savedPin,
          );
        }
        return true;
      } else {
        return false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const String tag = 'LoginPage';
    final ui = Provider.of<CustomizeUi>(context);
    final i18n = Provider.of<LanguageStr>(context);
    final Size deviceSize = MediaQuery.of(context).size;
    final rememberMe = Provider.of<CustomizeRemember>(context);

    return KeyboardVisibilityBuilder(
      builder: (context, keyboardIsPresent) {
        return PopScope(
          onPopInvokedWithResult: (didPop, result) => popApp(),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: ui.backgroundColor,
              body: SingleChildScrollView(
                child: SizedBox(
                  height: deviceSize.height,
                  width: deviceSize.width,
                  child: Column(
                    children: [
                      SizedBox(height: deviceSize.height * .04),
                      const SettingSwitches(),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 450),
                        height: keyboardIsPresent
                            ? deviceSize.height * .075
                            : deviceSize.height * .15,
                        child: XatoxiIcons.mainLogo(),
                      ),
                      AnimatedContainer(
                          duration: const Duration(milliseconds: 450),
                          height: keyboardIsPresent
                              ? deviceSize.height * .0125
                              : deviceSize.height * .025),
                      MultilineWithIconContainer(
                        textAlign: TextAlign.center,
                        width: deviceSize.width * .85,
                        prefixIcons: const [
                          Icon(
                            Icons.person_rounded,
                            color: Colors.transparent,
                          ),
                        ],
                        textList: [APPref.appName],
                      ),
                      MultilineWithIconContainer(
                        textAlign: TextAlign.center,
                        width: deviceSize.width * .85,
                        prefixIcons: [
                          Icon(
                            Icons.person_rounded,
                            color: ui.darkMode
                                ? Colors.white
                                : ColorSolid.globalPrimary,
                          ),
                        ],
                        textList: [i18n.text('login')],
                      ),
                      SizedBox(height: deviceSize.height * .01),
                      //* Email text field ----------------------------------------
                      CustomEmailField(
                        textController: emailController,
                        width: deviceSize.width * .85,
                        enableUnderline: true,
                        maxLenght: 40,
                        borderColor: ColorSolid.globalPrimaryDark,
                        hint: i18n.text('hintEmail'),
                        onUpdate: (value) => email = value,
                      ),
                      CustomPhoneSelector(
                        controller: _phoneController,
                        //backgroundColor: ui.subContainerColor,
                        borderColor: ColorSolid.globalPrimaryDark,
                        horizontalPadding: deviceSize.width * .0,
                        width: deviceSize.width * .85,
                        height: deviceSize.height * .070,
                        enableUnderline: true,
                        initialPhone: "+584164309040",
                        countryHint: "País", //i18n.text('hintCountry'),
                        textAlign: TextAlign.center,
                        onCountryUpdate: (value) {
                          debugLine(value ?? "", 'PhoneSelectorUpdate');
                          //email = value;
                          //emailController.text = value;
                        },
                        onChanged: (value) {
                          debugLine(value, 'PhoneSelectorUpdate');
                          //email = value;
                          emailController.text = value;
                          debugLine(
                              _phoneController.text, 'PhoneSelectorUpdate x');
                        },
                        selectedCountryCode: 'AR',
                        countries: _defaultCountries,
                        suffixIcon: Icon(
                          Icons.phone,
                          color: ui.basicIconColor,
                          size: deviceSize.height * .03,
                        ),
                      ),
                      SizedBox(height: deviceSize.height * .01),
                      //* Password field [pin] ------------------------------------
                      CustomPinField(
                        controller: pinController,
                        enableUnderline: true,
                        width: deviceSize.width * .85,
                        borderColor: ColorSolid.globalPrimaryDark,
                        onUpdate: (value) {
                          password = value;
                        },
                        textAlign: TextAlign.center,
                        maxLenght: 10,
                        obscureText: true,
                        hint: i18n.text('hintPin'),
                      ),
                      AnimatedContainer(
                          duration: const Duration(milliseconds: 450),
                          height: keyboardIsPresent
                              ? deviceSize.height * .015
                              : deviceSize.height * .04),
                      const SignUpForgotButton(),
                      AnimatedContainer(
                          duration: const Duration(milliseconds: 450),
                          height: keyboardIsPresent
                              ? deviceSize.height * .005
                              : deviceSize.height * .035),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // HexagonButtons.generic(
                          //   context: context,
                          //   icon: Icon(
                          //     Icons.image,
                          //     color: ui.basicIconColor,
                          //   ),
                          //   onTap: () => SignatureDialog.popWindow(context),
                          // ),
                          if (savedEmail != '' &&
                              savedPin != '' &&
                              rememberMe.rememberBiometric &&
                              BiometricToolData.showBiometricButton)
                            HexagonButtons.generic(
                              context: context,
                              onTap: () {
                                checkAuthWithLocal(
                                  email: email,
                                  pin: password,
                                  i18n: i18n,
                                  tag: tag,
                                );
                              },
                              icon: Icon(
                                Icons.fingerprint,
                                color: ui.backgroundColor,
                                size: DeviceSize.height * .045,
                              ),
                            ),
                          HexagonButtons.saveButton(
                            context: context,
                            onTap: () async {
                              if (email == 'demo.xatoxi2025@xatoxi.com' &&
                                  password == '1358') {
                                APPref.serverEnviroment = ServerEnv.qa;
                                APPref.updateServerToQA();
                                email = 'vmachado87@outlook.com';
                                password = '9985';
                              }
                              // loginSummitAction(
                              //   context,
                              //   tag: tag,
                              //   i18n: i18n,
                              //   email: email,
                              //   pin: password,
                              // );
                              if (email != '' && password != '') {
                                if (StringContentAnalysis.isValidEmail(email)) {
                                  loginSummit(
                                    context,
                                    tag: tag,
                                    i18n: i18n,
                                    email: email.contains('***')
                                        ? savedEmail
                                        : email,
                                    pin: password,
                                  );
                                } else {
                                  RequestFailedWithConfirm.popWindow(
                                    context,
                                    i18n.text('validatorEmailFailed'),
                                    onTap: () => Navigator.of(context).pop(),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      const Spacer(),
                      const FooterXatoxi(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
