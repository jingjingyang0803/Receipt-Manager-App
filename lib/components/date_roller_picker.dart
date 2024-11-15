import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import 'custom_button.dart';

class CalendarFilterWidget extends StatefulWidget {
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final Function(DateTime, DateTime) onApply;

  const CalendarFilterWidget({
    super.key,
    required this.initialStartDate,
    required this.initialEndDate,
    required this.onApply,
  });

  @override
  CalendarFilterWidgetState createState() => CalendarFilterWidgetState();
}

class CalendarFilterWidgetState extends State<CalendarFilterWidget> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  void _updateRange(int days) {
    setState(() {
      if (_endDate != null) {
        _startDate = _endDate!.subtract(Duration(days: days));
      } else if (_startDate != null) {
        _endDate = _startDate!.add(Duration(days: days));
      }
    });
  }

  Future<void> _showRollingDatePicker(
      BuildContext context, bool isStartDate) async {
    DateTime initialDate = isStartDate
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? DateTime.now());
    DateTime maximumDate = DateTime.now();

    if (initialDate.isAfter(maximumDate)) {
      initialDate = maximumDate;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext builder) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  minimumDate: isStartDate
                      ? DateTime(2000)
                      : (_startDate ?? DateTime(2000)),
                  maximumDate:
                      isStartDate ? _endDate ?? maximumDate : maximumDate,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      if (isStartDate) {
                        _startDate = newDate;
                      } else {
                        _endDate = newDate;
                      }
                    });
                  },
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('DONE', style: TextStyle(color: purple100)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(
            thickness: 3,
            color: purple40,
            endIndent: 165,
            indent: 165,
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text('Wk'),
                selected: false,
                onSelected: (_) => _updateRange(7),
                backgroundColor: light40,
                selectedColor: purple20,
                labelStyle: TextStyle(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                      color: Colors.transparent, width: 0), // Remove border
                ),
              ),
              ChoiceChip(
                label: Text('30D'),
                selected: false,
                onSelected: (_) => _updateRange(30),
                backgroundColor: light40,
                selectedColor: purple20,
                labelStyle: TextStyle(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                      color: Colors.transparent, width: 0), // Remove border
                ),
              ),
              ChoiceChip(
                label: Text('90D'),
                selected: false,
                onSelected: (_) => _updateRange(90),
                backgroundColor: light40,
                selectedColor: purple20,
                labelStyle: TextStyle(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                      color: Colors.transparent, width: 0), // Remove border
                ),
              ),
              ChoiceChip(
                label: Text('Year'),
                selected: false,
                onSelected: (_) => _updateRange(365),
                backgroundColor: light40,
                selectedColor: purple20,
                labelStyle: TextStyle(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                      color: Colors.transparent, width: 0), // Remove border
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDatePickerButton('From', _startDate, true),
              _buildDatePickerButton('To', _endDate, false),
            ],
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CustomButton(
                  text: "Cancel",
                  backgroundColor: purple20,
                  textColor: purple100,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: CustomButton(
                  text: "Apply",
                  backgroundColor: purple100,
                  textColor: light80,
                  onPressed: () {
                    if (_startDate != null && _endDate != null) {
                      widget.onApply(_startDate!, _endDate!);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerButton(
      String label, DateTime? date, bool isStartDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: dark50)),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showRollingDatePicker(context, isStartDate),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: light40,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              date != null ? DateFormat.yMMMd().format(date) : 'Select',
              style: TextStyle(fontSize: 16, color: dark50),
            ),
          ),
        ),
      ],
    );
  }
}
