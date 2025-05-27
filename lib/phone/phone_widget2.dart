import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  final Widget? suffixIcon;

  final TextAlign? textAlign;

  final String? countryHint;

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
    this.suffixIcon,
    this.textAlign,
    this.countryHint,
  });

  @override
  State<PhoneWidget> createState() => _PhoneWidgetState();
}

class _PhoneWidgetState extends State<PhoneWidget> {
  late TextEditingController _phoneController;
  late TextEditingController _controller;

  late CountryData _selectedCountry;
  bool _isModalOpen = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  late FocusNode _focusNode;
  late List<CountryData> _countries;
  bool _changingCountryManually = false;
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
    _phoneController = TextEditingController();
    _controller = widget.controller ??
        TextEditingController(text: widget.initialPhone ?? '');

    _focusNode = widget.focusNode ?? FocusNode();

    // Si el número inicial incluye código de país, detectar el país
    if (widget.initialPhone?.startsWith('+') ?? false) {
      _selectedCountry = _detectCountryFromPhone(widget.initialPhone!) ??
          _countries.firstWhere(
            (country) => country.code == (widget.initialCountryCode ?? 'US'),
            orElse: () => _countries.first,
          );
    } else {
      _selectedCountry = _countries.firstWhere(
        (country) => country.code == (widget.initialCountryCode ?? 'US'),
        orElse: () => _countries.first,
      );
    }

    _phoneController.text = _controller.text;

    _phoneController.addListener(_onPhoneChanged);
    _focusNode.addListener(_onFocusChanged);
  }

// Método auxiliar para detectar país desde número con código
  CountryData? _detectCountryFromPhone(String phone) {
    for (CountryData country in _countries) {
      if (phone.startsWith(country.dialCode)) {
        return country;
      }
    }
    return null;
  }

  void _onCountrySelected2(CountryData newCountry) {
    final currentText = _phoneController.text.trim();
    String newText = currentText;

    // Verificar si el texto actual comienza con algún código de país conocido
    bool hasInternationalCode = currentText.startsWith('+');
    bool hasKnownCode = false;

    if (hasInternationalCode) {
      for (CountryData country in _countries) {
        if (currentText.startsWith(country.dialCode)) {
          // Reemplazar solo el código manteniendo el resto del número
          newText = newCountry.dialCode +
              currentText.substring(country.dialCode.length);
          hasKnownCode = true;
          break;
        }
      }

      // Si tiene código internacional pero no coincide con ningún país conocido
      if (!hasKnownCode) {
        final match = RegExp(r'^\+\d+').firstMatch(currentText);
        if (match != null) {
          newText = newCountry.dialCode +
              currentText.substring(match.group(0)!.length);
        }
      }
    }
    // Si no tiene código internacional, no hacemos ningún cambio al número

    // Actualizar el controlador de texto
    _phoneController.value = _phoneController.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );

    // Actualizar el país seleccionado
    setState(() {
      _selectedCountry = newCountry;
    });

    // Notificar los cambios
    widget.onCountryChanged?.call(newCountry);
    widget.onPhoneChanged?.call(newText);
  }

  void _onCountrySelected(CountryData newCountry) {
    final currentText = _phoneController.text;
    String numberPart = currentText;

    // 1. Extraer solo los dígitos (incluyendo + inicial)
    final digitsOnly = currentText.replaceAll(RegExp(r'[^\d+]'), '');

    // 2. Buscar coincidencia con códigos conocidos
    for (CountryData country in _countries) {
      final codeDigits = country.dialCode.replaceAll(RegExp(r'[^\d+]'), '');
      if (digitsOnly.startsWith(codeDigits)) {
        // Preservar el formato original después del código
        numberPart = currentText.substring(country.dialCode.length);
        break;
      }
    }

    // 3. Si no se encontró código conocido pero empieza con +
    if (digitsOnly.startsWith('+') && numberPart == currentText) {
      final codeMatch = RegExp(r'^\+\d+').firstMatch(digitsOnly);
      if (codeMatch != null) {
        final codeLength = codeMatch.group(0)!.length;
        // Preservar formato después del código desconocido
        numberPart = currentText.substring(codeLength);
      }
    }

    // 4. Construir nuevo número conservando el formato
    final newText = newCountry.dialCode + numberPart;

    // 5. Actualizar el texto manteniendo la posición del cursor
    _phoneController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );

    // 6. Actualizar estado y notificar
    setState(() => _selectedCountry = newCountry);
    widget.onCountryChanged?.call(newCountry);
    widget.onPhoneChanged?.call(newText);
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
    //_removeOverlay();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      //_removeOverlay();
    }
  }

  void _onPhoneChanged() {
    String phone = _phoneController.text;
    String fullNumber = '';

    // Detectar código de país automáticamente
    if (!_changingCountryManually && phone.startsWith('+')) {
      for (CountryData country in _countries) {
        if (phone.startsWith(country.dialCode)) {
          if (_selectedCountry != country) {
            setState(() {
              _selectedCountry = country;
            });
            widget.onCountryChanged?.call(country);
          }

          // Si el número ya incluye el código, no lo dupliques
          fullNumber = phone;
          break;
        }
      }
    }

    // Si no se detectó código o no empieza con +, usa el código seleccionado
    if (fullNumber.isEmpty) {
      fullNumber = _selectedCountry.dialCode + phone;
    }

    _controller.text = fullNumber;
    if (phone.isEmpty) {
      // Si el campo está vacío, no notificar el cambio
      widget.onPhoneChanged?.call('');
      return;
    }

    // Notificar el cambio con el número completo
    widget.onPhoneChanged?.call(fullNumber);
  }

  void _onPhoneChanged1() {
    final phone = _phoneController.text;

    // Solo detectar automáticamente si el número comienza con +
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

    // Notificar el cambio (enviamos el texto tal cual)
    widget.onPhoneChanged?.call(phone);
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;

    setState(() {
      _isModalOpen = !_isModalOpen; // Cambia el estado al tocar
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildCountrySelectorModal(),
    ).whenComplete(() {
      // Esto se ejecuta cuando el modal se cierra
      if (mounted) {
        setState(() {
          _isModalOpen = false;
        });
      }
    });
  }

  Widget _buildCountrySelectorModal() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.dropdownBackgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cabecera del modal
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.countryHint ?? 'Select Country',
                  style: widget.dropdownTextStyle?.copyWith(
                        fontWeight: FontWeight.bold,
                      ) ??
                      TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Lista de países
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _countries.length,
              itemBuilder: (context, index) {
                final country = _countries[index];
                final isSelected = country.code == _selectedCountry.code;

                return ListTile(
                  leading: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    country.name,
                    style: widget.dropdownTextStyle ??
                        TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade800,
                        ),
                  ),
                  trailing: Text(
                    country.dialCode,
                    style: widget.dropdownDialCodeStyle ??
                        TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                  ),
                  onTap: () {
                    _onCountrySelected(country);
                    Navigator.pop(context);
                    /*setState(() {
                      _selectedCountry = country;
                    });
                    widget.onCountryChanged?.call(country);
                   
                    widget.onPhoneChanged?.call(
                      _selectedCountry.dialCode + _phoneController.text,
                    );*/
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showOverlay() {
    _overlayEntry = _createOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isModalOpen = true;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isModalOpen = false;
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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.borderColor ?? Colors.grey.shade300,
          width: widget.borderWidth ?? 1,
        ),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Botón de bandera (ahora abre modal)
          InkWell(
            onTap: _toggleDropdown,
            child: Container(
              width: widget.countrySelectorWidth ?? 70,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
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
                  Icon(
                    _isModalOpen
                        ? Icons
                            .arrow_drop_up // ← Ícono hacia arriba cuando está abierto
                        : Icons
                            .arrow_drop_down, // ← Ícono hacia abajo cuando está cerrado
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          // Campo de texto (se mantiene igual)
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
              child: TextField(
                controller: _phoneController,
                focusNode: _focusNode,
                keyboardType: TextInputType.phone,
                style: widget.textStyle,
                enabled: widget.enabled,
                textAlign: widget.textAlign ?? TextAlign.start,
                decoration:
                    (widget.decoration ?? const InputDecoration()).copyWith(
                  border: InputBorder.none,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s\(\)]')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
