import 'package:flutter/material.dart';

class GenericDatePicker extends StatefulWidget {
  const GenericDatePicker({
    super.key,
    this.initialDate,
    this.finalDate,
    this.isRange = false,
    this.readOnly = false,
    this.dateFormat = 'dd-MM-yyyy',
    this.onDateChanged,
    this.labelInitial = 'Select Initial Date',
    this.labelFinal = 'Select Final Date',
    this.labelSingle = 'Select Date',
  });

  final DateTime? initialDate;
  final DateTime? finalDate;
  final bool isRange;
  final bool readOnly;
  final String dateFormat;
  final String labelInitial;
  final String labelFinal;
  final String labelSingle;
  final void Function(
      String singleDate, String? initialDate, String? finalDate)? onDateChanged;

  @override
  State<GenericDatePicker> createState() => _GenericDatePickerState();
}

class _GenericDatePickerState extends State<GenericDatePicker> {
  late DateTime _initialDate;
  late DateTime _finalDate;
  late String _initialDateStr;
  late String _finalDateStr;
  late String _singleDateStr;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _initialDate = widget.initialDate ?? DateTime(now.year, now.month, 1);
    _finalDate = widget.finalDate ?? now;
    _initialDateStr = _formatDate(_initialDate);
    _finalDateStr = _formatDate(_finalDate);
    _singleDateStr = _formatDate(_initialDate);
    if (widget.onDateChanged != null) {
      if (widget.isRange) {
        widget.onDateChanged!('', _initialDateStr, _finalDateStr);
      } else {
        widget.onDateChanged!(_singleDateStr, null, null);
      }
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    String format = widget.dateFormat;

    // Reemplazar los marcadores de formato
    format = format.replaceAll('dd', day);
    format = format.replaceAll('MM', month);
    format = format.replaceAll('yyyy', year);
    format = format.replaceAll('yy', year.substring(2));
    return format;
  }

  Future<void> _showDatePickerDialog(BuildContext context,
      {required bool isFinal}) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: isFinal ? _finalDate : _initialDate,
      firstDate: DateTime(1920),
      lastDate: isFinal
          ? DateTime.now()
          : (widget.isRange ? _finalDate : DateTime.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue, // Color del borde y botones
              onPrimary: Colors.white,
              onSurface: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        if (widget.isRange) {
          if (isFinal) {
            _finalDate = selectedDate;
            _finalDateStr = _formatDate(_finalDate);
          } else {
            _initialDate = selectedDate;
            _initialDateStr = _formatDate(_initialDate);
            // Asegurar que la fecha inicial no sea posterior a la final
            if (_initialDate.isAfter(_finalDate)) {
              _finalDate = _initialDate;
              _finalDateStr = _formatDate(_finalDate);
            }
          }
          widget.onDateChanged?.call('', _initialDateStr, _finalDateStr);
        } else {
          _initialDate = selectedDate;
          _singleDateStr = _formatDate(_initialDate);
          widget.onDateChanged?.call(_singleDateStr, null, null);
        }
      });
    }
  }

  Widget _buildDateContainer(
      BuildContext context, String label, String date, VoidCallback? onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        border:
            const Border(bottom: BorderSide(color: Colors.blue, width: 2.0)),
        borderRadius: BorderRadius.circular(8.0),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.white,
      ),
      child: InkWell(
        onTap: widget.readOnly ? null : onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$label: $date',
              style: TextStyle(
                fontSize: 16.0,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: widget.readOnly
                  ? Colors.grey
                  : Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isRange) ...[
          _buildDateContainer(
            context,
            widget.labelInitial,
            _initialDateStr,
            () => _showDatePickerDialog(context, isFinal: false),
          ),
          _buildDateContainer(
            context,
            widget.labelFinal,
            _finalDateStr,
            () => _showDatePickerDialog(context, isFinal: true),
          ),
        ] else ...[
          _buildDateContainer(
            context,
            widget.labelSingle,
            _singleDateStr,
            () => _showDatePickerDialog(context, isFinal: false),
          ),
        ],
      ],
    );
  }
}
