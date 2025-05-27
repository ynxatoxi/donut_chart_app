import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'phone_widget.dart'; // Asegúrate de importar tu PhoneWidget
import '../../settings/data/customize_ui.dart';
import '../constants/font_xatoxi.dart';
import 'custom_container.dart';
import 'phone/phone_widget2.dart';
import 'package:xatoxi_italpay/global/constants/color_solid.dart';

// ignore: must_be_immutable
class CustomPhoneSelector extends StatelessWidget {
  CustomPhoneSelector({
    super.key,
    required this.onCountryUpdate,
    required this.selectedCountryCode,
    required this.countries, // Mapa con código de país y ruta de la bandera
    this.dropWidht,
    this.horizontalPadding,
    this.verticalPadding,
    this.width,
    this.label,
    this.textColor,
    this.borderColor = Colors.transparent,
    this.height,
    this.backgroundColor,
    this.initialPhone,
    this.onChanged,
    this.textAlign,
    this.countryHint,
    this.suffixIcon,
    this.controller,
    this.enableUnderline = true,
  });

  final Color? backgroundColor;
  final void Function(String?) onCountryUpdate;
  final String selectedCountryCode;
  final List<CountryData> countries;
  final String? initialPhone;
  final ValueChanged<String>? onChanged;

  Color? textColor;
  double? dropWidht;
  double? width;
  double? horizontalPadding;
  final double? verticalPadding;
  double? height;
  String? label;
  Color borderColor;
  final TextAlign? textAlign;
  final String? countryHint;
  final Icon? suffixIcon;
  final TextEditingController? controller;
  final bool? enableUnderline;

  @override
  Widget build(BuildContext context) {
    final ui = Provider.of<CustomizeUi>(context);
    final deviceSize = MediaQuery.of(context).size;
    dropWidht = dropWidht ?? deviceSize.width * .65;
    final bool showUnderline = enableUnderline ?? false;
    return GreyContainer(
        backgroundColor: backgroundColor,
        label: label,
        horizontalPadding: horizontalPadding ?? 20,
        verticalPadding: verticalPadding ?? 12,
        borderColor: borderColor,
        width: width,
        height: height ?? 60,
        child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: deviceSize.width * .05,
              vertical: deviceSize.height * .01,
            ),
            child: PhoneWidget(
              controller: controller,
              countries: countries,
              initialCountryCode: selectedCountryCode,
              initialPhone: initialPhone,
              textAlign: textAlign ?? TextAlign.center,
              countryHint: countryHint ?? 'Select Country',
              onCountryChanged: (country) => onCountryUpdate(country.code),
              onPhoneChanged: onChanged,
              textStyle: TextStyle(
                fontSize: deviceSize.height * .025,
                fontFamily: FontXatoxi.atarian,
                color: ui.darkMode ? Colors.white : Colors.black,
                height: 2, // Ajuste de altura de línea
              ),
              dropdownTextStyle: TextStyle(
                fontSize: deviceSize.height * .025,
                fontFamily: FontXatoxi.atarian,
                color: ui.darkMode ? Colors.white : Colors.black,
              ),
              dropdownBackgroundColor: ui.subContainerColor,
              dropdownSelectedItemColor: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(deviceSize.height * .02),
              borderColor: Colors.transparent,
              borderWidth: 0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12), // Padding horizontal uniforme
              countrySelectorWidth: 80,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: deviceSize.height * .0),
                isDense: true,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        showUnderline ? ColorSolid.grey1 : Colors.transparent,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        showUnderline ? ColorSolid.grey1 : Colors.transparent,
                  ),
                ),
                suffixIcon: suffixIcon,
              ),
              //suffixIcon: suffixIcon,
            )));
  }
/*  @override
  Widget build(BuildContext context) {
    final ui = Provider.of<CustomizeUi>(context);
    final deviceSize = MediaQuery.of(context).size;
    dropWidht = dropWidht ?? deviceSize.width * .65;

    return GreyContainer(
      backgroundColor: backgroundColor,
      label: label,
      horizontalPadding: horizontalPadding,
      verticalPadding: verticalPadding,
      borderColor: borderColor,
      width: containerWidht,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PhoneWidget(
            countries: countries,
            initialCountryCode: selectedCountryCode,
            initialPhone: initialPhone,
            onCountryChanged: (country) => onUpdate(country.code),
            onPhoneChanged: onPhoneChanged,
            textStyle: TextStyle(
              fontSize: deviceSize.height * .025,
              fontFamily: FontXatoxi.atarian,
              color: ui.darkMode ? Colors.white : Colors.black,
            ),
            dropdownTextStyle: TextStyle(
              fontSize: deviceSize.height * .022,
              fontFamily: FontXatoxi.atarian,
              color: ui.darkMode ? Colors.white : Colors.black,
            ),
            dropdownBackgroundColor: ui.subContainerColor,
            dropdownSelectedItemColor: Colors.blue.withOpacity(0.9),
            borderRadius: BorderRadius.circular(deviceSize.height * .02),
            borderColor: Colors.transparent,
            borderWidth: 0,
            padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
            countrySelectorWidth: 70, //dropWidht,
          ),
        ],
      ),
    );
  }
*/
}
