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
}

// Widget principal para el selector de teléfono internacional
class PhoneWidget extends StatefulWidget {
  final Function(String)? onPhoneChanged;
  final Function(CountryData)? onCountryChanged;
  final String? initialPhone;
  final String? initialCountryCode;
  final InputDecoration? decoration;
  final TextStyle? textStyle;

  const PhoneWidget({
    super.key,
    this.onPhoneChanged,
    this.onCountryChanged,
    this.initialPhone,
    this.initialCountryCode,
    this.decoration,
    this.textStyle,
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
  final FocusNode _focusNode = FocusNode();

  // Lista de países con sus códigos y banderas (usando emojis)
  static const List<CountryData> _countries = [
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
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');

    // Seleccionar país inicial
    _selectedCountry = _countries.firstWhere(
      (country) => country.code == (widget.initialCountryCode ?? 'US'),
      orElse: () => _countries.first,
    );

    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
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

    widget.onPhoneChanged?.call(phone);
  }

  void _toggleDropdown() {
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
      builder:
          (context) => Positioned(
            width: 300,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 4),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
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
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue.shade50 : null,
                          ),
                          child: Row(
                            children: [
                              Text(
                                country.flag,
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  country.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                              Text(
                                country.dialCode,
                                style: TextStyle(
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
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Selector de país
            InkWell(
              onTap: _toggleDropdown,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_selectedCountry.flag, style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Icon(
                      _isDropdownOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
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
                decoration: (widget.decoration ?? InputDecoration()).copyWith(
                  hintText: 'Número de teléfono',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
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
}
