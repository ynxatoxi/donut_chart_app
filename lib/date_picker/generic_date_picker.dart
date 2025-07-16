import 'package:flutter/material.dart';

enum DatePickerStyle { single, range }

class GenericDatePicker extends StatefulWidget {
  const GenericDatePicker({
    super.key,
    this.mode = DatePickerStyle.single,
    this.initialDate,
    this.finalDate,
    this.onDateSelected,
    this.onDateRangeSelected,
    this.dateFormat = 'dd/MM/yyyy',
    this.firstDate,
    this.lastDate,
    this.readOnly = false,
    this.borderColor,
    this.borderRadius = 8.0,
    this.width,
    this.height = 50.0,
    this.spacing = 16.0,
    this.layout = DatePickerLayout.horizontal,
    this.initialDateLabel = 'Fecha inicial',
    this.finalDateLabel = 'Fecha final',
    this.singleDateLabel = 'Seleccionar fecha',
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.enabled = true,
  });

  final DatePickerStyle mode;
  final DateTime? initialDate;
  final DateTime? finalDate;
  final Function(DateTime)? onDateSelected;
  final Function(DateTime, DateTime)? onDateRangeSelected;
  final String dateFormat;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool readOnly;
  final Color? borderColor;
  final double borderRadius;
  final double? width;
  final double height;
  final double spacing;
  final DatePickerLayout layout;
  final String initialDateLabel;
  final String finalDateLabel;
  final String singleDateLabel;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final bool enabled;

  @override
  State<GenericDatePicker> createState() => _GenericDatePickerState();
}

enum DatePickerLayout { horizontal, vertical }

class _GenericDatePickerState extends State<GenericDatePicker> {
  DateTime? _selectedInitialDate;
  DateTime? _selectedFinalDate;
  DateTime? _selectedSingleDate;

  @override
  void initState() {
    super.initState();
    _selectedInitialDate = widget.initialDate;
    _selectedFinalDate = widget.finalDate;
    _selectedSingleDate = widget.initialDate;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    switch (widget.dateFormat) {
      case 'dd/MM/yyyy':
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      case 'MM/dd/yyyy':
        return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
      case 'yyyy-MM-dd':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      case 'dd-MM-yyyy':
        return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
      default:
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  Future<void> _selectDate(BuildContext context,
      {required bool isInitialDate}) async {
    if (!widget.enabled || widget.readOnly) return;

    final DateTime firstDate = widget.firstDate ?? DateTime(1900);
    final DateTime lastDate = widget.lastDate ?? DateTime.now();

    DateTime? initialDate;

    if (widget.mode == DatePickerStyle.single) {
      initialDate = _selectedSingleDate ?? DateTime.now();
    } else {
      if (isInitialDate) {
        initialDate = _selectedInitialDate ?? DateTime.now();
      } else {
        initialDate =
            _selectedFinalDate ?? _selectedInitialDate ?? DateTime.now();
      }
    }

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: widget.mode == DatePickerStyle.range && !isInitialDate
          ? (_selectedInitialDate ?? firstDate)
          : firstDate,
      lastDate: widget.mode == DatePickerStyle.range && isInitialDate
          ? (_selectedFinalDate ?? lastDate)
          : lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              surface: widget.backgroundColor ?? Colors.white,
              primary: widget.borderColor ?? Colors.blue,
              onPrimary: Colors.white,
              onSurface: widget.textColor ?? Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        if (widget.mode == DatePickerStyle.single) {
          _selectedSingleDate = selectedDate;
          widget.onDateSelected?.call(selectedDate);
        } else {
          if (isInitialDate) {
            _selectedInitialDate = selectedDate;
            // Si la fecha final es menor que la inicial, la ajustamos
            if (_selectedFinalDate != null &&
                _selectedFinalDate!.isBefore(selectedDate)) {
              _selectedFinalDate = selectedDate;
            }
          } else {
            _selectedFinalDate = selectedDate;
            // Si la fecha inicial es mayor que la final, la ajustamos
            if (_selectedInitialDate != null &&
                _selectedInitialDate!.isAfter(selectedDate)) {
              _selectedInitialDate = selectedDate;
            }
          }

          if (_selectedInitialDate != null && _selectedFinalDate != null) {
            widget.onDateRangeSelected
                ?.call(_selectedInitialDate!, _selectedFinalDate!);
          }
        }
      });
    }
  }

  Widget _buildDatePickerButton({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
    double? width,
  }) {
    return Container(
      width: width,
      height: widget.height,
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.borderColor ?? Colors.blue,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: widget.backgroundColor ?? Colors.transparent,
      ),
      child: InkWell(
        onTap: widget.enabled && !widget.readOnly ? onTap : null,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  selectedDate != null ? _formatDate(selectedDate) : label,
                  style: TextStyle(
                    color: selectedDate != null
                        ? (widget.textColor ?? Colors.black)
                        : (widget.textColor ?? Colors.grey),
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.calendar_month,
                color: widget.iconColor ?? widget.borderColor ?? Colors.blue,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == DatePickerStyle.single) {
      return _buildDatePickerButton(
        label: widget.singleDateLabel,
        selectedDate: _selectedSingleDate,
        onTap: () => _selectDate(context, isInitialDate: true),
        width: widget.width,
      );
    }

    // Modo range
    if (widget.layout == DatePickerLayout.horizontal) {
      return SizedBox(
        width: widget.width,
        child: Row(
          children: [
            Expanded(
              child: _buildDatePickerButton(
                label: widget.initialDateLabel,
                selectedDate: _selectedInitialDate,
                onTap: () => _selectDate(context, isInitialDate: true),
              ),
            ),
            SizedBox(width: widget.spacing),
            Icon(
              Icons.double_arrow_rounded,
              color: widget.iconColor ?? Colors.black,
              size: 24,
            ),
            SizedBox(width: widget.spacing),
            Expanded(
              child: _buildDatePickerButton(
                label: widget.finalDateLabel,
                selectedDate: _selectedFinalDate,
                onTap: () => _selectDate(context, isInitialDate: false),
              ),
            ),
          ],
        ),
      );
    } else {
      // Layout vertical
      return SizedBox(
        width: widget.width,
        child: Column(
          children: [
            _buildDatePickerButton(
              label: widget.initialDateLabel,
              selectedDate: _selectedInitialDate,
              onTap: () => _selectDate(context, isInitialDate: true),
              width: widget.width,
            ),
            SizedBox(height: widget.spacing),
            _buildDatePickerButton(
              label: widget.finalDateLabel,
              selectedDate: _selectedFinalDate,
              onTap: () => _selectDate(context, isInitialDate: false),
              width: widget.width,
            ),
          ],
        ),
      );
    }
  }
}

// Clase auxiliar para obtener las fechas en diferentes formatos
class DatePickerResult {
  final DateTime? singleDate;
  final DateTime? initialDate;
  final DateTime? finalDate;

  DatePickerResult({
    this.singleDate,
    this.initialDate,
    this.finalDate,
  });

  // Obtener fecha individual como string
  String getSingleDateAsString([String format = 'dd/MM/yyyy']) {
    if (singleDate == null) return '';
    return _formatDate(singleDate!, format);
  }

  // Obtener fecha inicial como string
  String getInitialDateAsString([String format = 'dd/MM/yyyy']) {
    if (initialDate == null) return '';
    return _formatDate(initialDate!, format);
  }

  // Obtener fecha final como string
  String getFinalDateAsString([String format = 'dd/MM/yyyy']) {
    if (finalDate == null) return '';
    return _formatDate(finalDate!, format);
  }

  // Obtener rango como string
  String getRangeAsString(
      [String format = 'dd/MM/yyyy', String separator = ' - ']) {
    if (initialDate == null || finalDate == null) return '';
    return '${_formatDate(initialDate!, format)}$separator${_formatDate(finalDate!, format)}';
  }

  String _formatDate(DateTime date, String format) {
    switch (format) {
      case 'dd/MM/yyyy':
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      case 'MM/dd/yyyy':
        return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
      case 'yyyy-MM-dd':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      case 'dd-MM-yyyy':
        return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
      default:
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }
}
