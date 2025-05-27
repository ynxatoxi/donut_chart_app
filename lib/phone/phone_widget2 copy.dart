import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xatoxi_italpay/global/constants/color_solid.dart';

// Modelo para los datos del país
class CountryData {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  const CountryData({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryData &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

// Widget principal para el selector de teléfono internacional
class PhoneWidget extends StatefulWidget {
  /// Lista de países a mostrar. Si no se proporciona, se usa la lista por defecto
  final List<CountryData>? countries;

  /// Callback cuando cambia el número de teléfono completo (incluyendo código de país)
  final ValueChanged<String>? onPhoneChanged;

  /// Callback cuando se cambia el país seleccionado
  final ValueChanged<CountryData>? onCountryChanged;

  /// Número inicial (sin código de país)
  final String? initialPhone;

  /// Código de país inicial (ej. 'US', 'VE')
  final String? initialCountryCode;

  /// Decoración para el campo de texto
  final InputDecoration? decoration;

  /// Estilo de texto para el campo de entrada
  final TextStyle? textStyle;

  /// Estilo de texto para los ítems del dropdown
  final TextStyle? dropdownTextStyle;

  /// Estilo de texto para los códigos de país en el dropdown
  final TextStyle? dropdownDialCodeStyle;

  /// Ancho del selector de país
  final double? countrySelectorWidth;

  /// Altura máxima del dropdown de países
  final double? dropdownMaxHeight;

  /// Color de fondo del dropdown
  final Color? dropdownBackgroundColor;

  /// Color de fondo del ítem seleccionado en el dropdown
  final Color? dropdownSelectedItemColor;

  /// Icono para cuando el dropdown está abierto
  final Icon? dropdownOpenIcon;

  /// Icono para cuando el dropdown está cerrado
  final Icon? dropdownClosedIcon;

  /// Radio de borde del widget principal
  final BorderRadius? borderRadius;

  /// Color del borde del widget principal
  final Color? borderColor;

  /// Ancho del borde del widget principal
  final double? borderWidth;

  /// Espaciado interno del widget principal
  final EdgeInsets? padding;

  /// Validación del número de teléfono
  final FormFieldValidator<String>? validator;

  /// Controlador de texto externo
  final TextEditingController? controller;

  /// Focus node externo
  final FocusNode? focusNode;

  /// Indica si el widget está habilitado
  final bool enabled;

  const PhoneWidget({
    super.key,
    this.countries,
    this.onPhoneChanged,
    this.onCountryChanged,
    this.initialPhone,
    this.initialCountryCode,
    this.decoration,
    this.textStyle,
    this.dropdownTextStyle,
    this.dropdownDialCodeStyle,
    this.countrySelectorWidth,
    this.dropdownMaxHeight,
    this.dropdownBackgroundColor,
    this.dropdownSelectedItemColor,
    this.dropdownOpenIcon,
    this.dropdownClosedIcon,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.padding,
    this.validator,
    this.controller,
    this.focusNode,
    this.enabled = true,
  });

  @override
  State<PhoneWidget> createState() => _PhoneWidgetState();
}

class _PhoneWidgetState extends State<PhoneWidget> {
  late TextEditingController _phoneController;
  late CountryData _selectedCountry;
  bool _isDropdownOpen = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  late FocusNode _focusNode;
  late List<CountryData> _countries;

  // Lista de países por defecto
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
    super.initState();
    _countries = widget.countries ?? _defaultCountries;
    _phoneController = widget.controller ??
        TextEditingController(text: widget.initialPhone ?? '');
    _focusNode = widget.focusNode ?? FocusNode();

    // Seleccionar país inicial
    _selectedCountry = _countries.firstWhere(
      (country) => country.code == (widget.initialCountryCode ?? 'US'),
      orElse: () => _countries.first,
    );

    _phoneController.addListener(_onPhoneChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(PhoneWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _phoneController.removeListener(_onPhoneChanged);
      _phoneController = widget.controller ?? _phoneController;
      _phoneController.addListener(_onPhoneChanged);
    }
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_onFocusChanged);
      _focusNode = widget.focusNode ?? _focusNode;
      _focusNode.addListener(_onFocusChanged);
    }
    if (widget.countries != oldWidget.countries) {
      _countries = widget.countries ?? _defaultCountries;
      // Verificar que el país seleccionado aún esté en la lista
      if (!_countries.contains(_selectedCountry)) {
        _selectedCountry = _countries.first;
      }
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    if (widget.controller == null) {
      _phoneController.dispose();
    }
    _focusNode.removeListener(_onFocusChanged);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _onPhoneChanged() {
    String phone = _phoneController.text;

    // Detectar código de país automáticamente
    if (phone.startsWith('+')) {
      for (CountryData country in _countries) {
        if (phone.startsWith(country.dialCode)) {
          if (_selectedCountry != country) {
            setState(() {
              _selectedCountry = country;
            });
            widget.onCountryChanged?.call(country);
          }
          break;
        }
      }
    }

    // Notificar el cambio con el número completo
    widget.onPhoneChanged?.call(_selectedCountry.dialCode + phone);
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;

    if (_isDropdownOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = _createOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDropdownOpen = true;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isDropdownOpen = false;
      });
    }
  }

  OverlayEntry _createOverlay() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    Offset offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        width: 200, //widget.countrySelectorWidth ?? 300,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: widget.dropdownMaxHeight ?? 200,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: widget.borderWidth ?? 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: widget.dropdownBackgroundColor ?? Colors.white,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _countries.length,
                itemBuilder: (context, index) {
                  CountryData country = _countries[index];
                  bool isSelected = country.code == _selectedCountry.code;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCountry = country;
                      });
                      widget.onCountryChanged?.call(country);
                      _removeOverlay();
                      // Actualizar el número completo
                      widget.onPhoneChanged?.call(
                        _selectedCountry.dialCode + _phoneController.text,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (widget.dropdownSelectedItemColor ??
                                Colors.blue.shade50)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Text(
                            country.flag,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              country.name,
                              style: widget.dropdownTextStyle ??
                                  TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                            ),
                          ),
                          Text(
                            country.dialCode,
                            style: widget.dropdownDialCodeStyle ??
                                TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size deviceSize = MediaQuery.of(context).size;
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.borderColor ?? Colors.grey.shade300,
            width: widget.borderWidth ?? 1,
          ),
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Alineación vertical
          children: [
            // Selector de país
            InkWell(
              onTap: _toggleDropdown,
              child: Container(
                width: widget.countrySelectorWidth ?? 70, // Ancho fijo mejorado
                padding: widget.padding ??
                    const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 0), // Ajuste vertical
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: widget.borderColor ?? Colors.grey.shade300,
                      width: widget.borderWidth ?? 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Centrado vertical
                  children: [
                    Text(
                      _selectedCountry.flag,
                      style: const TextStyle(fontSize: 20),
                    ),
                    widget.enabled
                        ? (widget.dropdownClosedIcon ??
                            Icon(
                              _isDropdownOpen
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.grey.shade600,
                              size: 20,
                            ))
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
            // Campo de texto para el número
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 0, right: 20), // Ajuste fino de alineación
                child: TextField(
                  controller: _phoneController,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.phone,
                  style: widget.textStyle?.copyWith(
                    height:
                        1.2, // Ajuste de altura de línea para mejor alineación
                  ),
                  enabled: widget.enabled,
                  decoration:
                      (widget.decoration ?? const InputDecoration()).copyWith(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, // Espaciado horizontal adecuado
                      vertical: 6, // Espaciado vertical uniforme
                    ),
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: true ? ColorSolid.grey1 : Colors.transparent,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: true ? ColorSolid.grey1 : Colors.transparent,
                      ),
                    ),
                    isDense: true, // Reduce el espacio interno adicional
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9+\-\s\(\)]')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
/*  @override
  Widget build(BuildContext context) {
    final Size deviceSize = MediaQuery.of(context).size;
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.borderColor ?? Colors.grey.shade300,
            width: widget.borderWidth ?? 1,
          ),
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Selector de país
            InkWell(
              onTap: _toggleDropdown,
              child: Container(
                width: widget.countrySelectorWidth ?? 20,
                padding: widget.padding ??
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: widget.borderColor ?? Colors.grey.shade300,
                      width: widget.borderWidth ?? 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCountry.flag,
                      style: const TextStyle(fontSize: 20),
                    ),
                    widget.enabled
                        ? (widget.dropdownClosedIcon ??
                            Icon(
                              _isDropdownOpen
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.grey.shade600,
                              size: 20,
                            ))
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
            // Campo de texto para el número
            Expanded(
              child: TextField(
                controller: _phoneController,
                focusNode: _focusNode,
                keyboardType: TextInputType.phone,
                style: widget.textStyle,
                enabled: widget.enabled,
                decoration:
                    (widget.decoration ?? const InputDecoration()).copyWith(
                  //hintText: 'Número de teléfono',
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(top: deviceSize.height * .022),
                  errorBorder: InputBorder.none,
                  //focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  //enabledBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: true ? ColorSolid.grey1 : Colors.transparent,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: true ? ColorSolid.grey1 : Colors.transparent,
                    ),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s\(\)]')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
*/
}
