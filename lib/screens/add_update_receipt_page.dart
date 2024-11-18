import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:receipt_manager/providers/category_provider.dart';
import 'package:receipt_manager/providers/receipt_provider.dart';

import '../components/category_select_popup.dart';
import '../components/custom_button.dart';
import '../constants/app_colors.dart';
import '../services/storage_service.dart';
import 'base_page.dart';

class AddOrUpdateReceiptPage extends StatefulWidget {
  static const String id = 'add_update_receipt_page';
  final Map<String, dynamic>? existingReceipt; // Store existing receipt data
  final String? receiptId; // Store the receipt ID when editing
  final Map<String, dynamic>? extract; // New parameter to pass extracted data

  const AddOrUpdateReceiptPage({
    super.key,
    this.existingReceipt,
    this.receiptId,
    this.extract,
  });

  @override
  AddOrUpdateReceiptPageState createState() => AddOrUpdateReceiptPageState();
}

class AddOrUpdateReceiptPageState extends State<AddOrUpdateReceiptPage> {
  final StorageService _storageService = StorageService(); // Storage instance

  final TextEditingController _merchantController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();

  List<Map<String, dynamic>> _userCategories = [];
  String? _selectedCategoryId;
  String? _selectedCategoryIcon;
  String? _selectedCategoryName;
  String? _selectedPaymentMethod; // Added payment method field

  String? _uploadedImageUrl;

  String currencySymbol = ' ';

  @override
  void initState() {
    super.initState();
    _loadUserCategories();
    _initializeFormFields();

    final receiptProvider =
        Provider.of<ReceiptProvider>(context, listen: false);

    currencySymbol = receiptProvider.currencySymbol ?? '€'; // Fetch the symbol
  }

  Future<void> _loadUserCategories() async {
    // Fetch categories from the provider
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    await categoryProvider.loadUserCategories();
    setState(() {
      _userCategories = categoryProvider.categories;
    });
  }

  void _initializeFormFields() {
    if (widget.existingReceipt != null) {
      // Populate fields if editing an existing receipt
      _merchantController.text = widget.existingReceipt!['merchant'] ?? '';
      _dateController.text = widget.existingReceipt!['date']
              ?.toDate()
              .toLocal()
              .toString()
              .split(' ')[0] ??
          '';
      _totalController.text =
          widget.existingReceipt!['amount']?.toString() ?? '';
      _itemNameController.text = widget.existingReceipt!['itemName'] ?? '';
      _descriptionController.text =
          widget.existingReceipt!['description'] ?? '';
      _selectedCategoryId = widget.existingReceipt!['categoryId'];
      _selectedCategoryName = widget.existingReceipt!['categoryName'];
      _selectedCategoryIcon = widget.existingReceipt!['categoryIcon'];
      _selectedPaymentMethod = widget.existingReceipt!['paymentMethod'] ?? '';

      if (widget.existingReceipt!.containsKey('imageUrl')) {
        _uploadedImageUrl = widget.existingReceipt!['imageUrl'];
      }
    } else if (widget.extract != null) {
      // Populate fields if data is passed via extract
      _merchantController.text = widget.extract!['merchant'] ?? '';
      _dateController.text = widget.extract!['date'] ??
          DateTime.now().toLocal().toString().split(' ')[0];

      final extractCurrency = widget.extract!['currency'] ?? '';
      final extractAmount = widget.extract!['amount'] ?? '';

      if (extractCurrency != currencySymbol) {
        _descriptionController.text =
            'Converted from $extractCurrency $extractAmount';
      } else {
        _totalController.text = extractAmount.toString();
      }

      _uploadedImageUrl = widget.extract!['imagePath'] ?? '';
    } else {
      // New receipt mode
      _dateController.text = DateTime.now().toLocal().toString().split(' ')[0];
    }

    // Fetch categories through CategoryProvider
    Provider.of<CategoryProvider>(context, listen: false).loadUserCategories();
  }

  Future<void> uploadReceiptImage() async {
    String? imageUrl = await _storageService.uploadReceiptImage();
    if (imageUrl != null) {
      setState(() {
        _uploadedImageUrl = imageUrl.trim();
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        DateTime tempPickedDate = initialDate;

        return Container(
          height: 300,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Select Date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  initialDateTime: initialDate,
                  mode: CupertinoDatePickerMode.date,
                  minimumDate: DateTime(2000),
                  maximumDate: DateTime(2101),
                  onDateTimeChanged: (DateTime newDate) {
                    tempPickedDate = newDate;
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _dateController.text =
                        "${tempPickedDate.toLocal()}".split(' ')[0];
                  });
                  Navigator.pop(context);
                },
                child: Text('DONE'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveReceipt() async {
    final messenger = ScaffoldMessenger.of(context);
    final receiptProvider =
        Provider.of<ReceiptProvider>(context, listen: false);

    double? amount =
        double.tryParse(_totalController.text.replaceAll(',', '.'));

    if (_dateController.text.isEmpty ||
        amount == null ||
        _selectedPaymentMethod == null) {
      messenger.showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    Map<String, dynamic> receiptData = {
      'merchant': _merchantController.text,
      'date': Timestamp.fromDate(DateTime.parse(_dateController.text)),
      'amount': amount,
      'categoryId': _selectedCategoryId,
      'paymentMethod': _selectedPaymentMethod,
      'itemName': _itemNameController.text,
      'description': _descriptionController.text,
      'imageUrl': _uploadedImageUrl ?? '',
    };

    try {
      if (widget.receiptId != null) {
        await receiptProvider.updateReceipt(
          receiptId: widget.receiptId!,
          updatedData: receiptData,
        );
        await receiptProvider.fetchAllReceipts(); // Refresh the list
        messenger.showSnackBar(
          SnackBar(content: Text('Receipt updated successfully')),
        );
      } else {
        await receiptProvider.addReceipt(receiptData: receiptData);
        await receiptProvider.fetchAllReceipts(); // Refresh the list
        messenger.showSnackBar(
          SnackBar(content: Text('Receipt saved successfully')),
        );
        _clearForm();
      }
      Navigator.pushReplacementNamed(context, BasePage.id);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to save receipt. Try again.')),
      );
    }
  }

  void _clearForm() {
    setState(() {
      _merchantController.clear();
      _dateController.text = DateTime.now().toLocal().toString().split(' ')[0];
      _totalController.clear();
      _descriptionController.clear();
      _itemNameController.clear();
      _selectedCategoryId = null;
      _selectedPaymentMethod = null;
      _uploadedImageUrl = null;
    });
  }

  Future<void> _confirmDelete() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Receipt'),
          content: Text('Are you sure you want to delete this receipt?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _deleteReceipt();
    }
  }

  Future<void> _deleteReceipt() async {
    final receiptProvider =
        Provider.of<ReceiptProvider>(context, listen: false);
    if (widget.receiptId != null) {
      await receiptProvider.deleteReceipt(widget.receiptId!);
      Navigator.pushReplacementNamed(context, BasePage.id);
    }
  }

  void _showCategoryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ChangeNotifierProvider.value(
          value: Provider.of<CategoryProvider>(context, listen: false),
          child: CategorySelectPopup(),
        );
      },
    ).then((selectedCategoryId) {
      if (selectedCategoryId != null) {
        final selectedCategory = _userCategories.firstWhere(
          (category) => category['id'] == selectedCategoryId,
          orElse: () => {},
        );

        if (selectedCategory.isNotEmpty) {
          setState(() {
            _selectedCategoryId = selectedCategoryId;
            _selectedCategoryName = selectedCategory['name'];
            _selectedCategoryIcon = selectedCategory['icon'];
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.receiptId != null ? 'Update Receipt' : 'New Receipt'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // RoundedButton(
              //   color: Colors.lightBlueAccent,
              //   title: 'Scan Receipt',
              //   onPressed: scanReceiptData,
              // ),
              TextField(
                controller: _merchantController,
                decoration: InputDecoration(labelText: 'Merchant'),
              ),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _dateController,
                    decoration: InputDecoration(labelText: 'Date'),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => _showCategoryBottomSheet(context),
                          child: AbsorbPointer(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: _selectedCategoryId?.isNotEmpty ==
                                        true
                                    ? '$_selectedCategoryIcon $_selectedCategoryName'
                                    : 'Select Category',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      controller: _itemNameController,
                      decoration: InputDecoration(labelText: 'Item Name'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                items: [
                  'Credit Card',
                  'Debit Card',
                  'Cash',
                  'PayPal',
                  'MobilePay',
                  'Apple Pay',
                  'Google Pay',
                  'Bank Transfer',
                  'Others'
                ]
                    .map((method) => DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        ))
                    .toList(),
                onChanged: (value) => setState(() {
                  _selectedPaymentMethod = value;
                }),
                decoration: InputDecoration(labelText: 'Payment Method'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _totalController,
                decoration: InputDecoration(
                  labelText: 'Total',
                  hintText: 'e.g. 0.00',
                  prefixText: currencySymbol, // Add your currency symbol here
                  prefixStyle: TextStyle(
                    color: Colors
                        .grey, // Optional: customize the style of the prefix
                    fontSize: 16, // Adjust font size to match your text field
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: uploadReceiptImage,
                  child: Text('Upload Receipt Image'),
                ),
              ),
              if (_uploadedImageUrl != null) ...[
                SizedBox(height: 20),
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _uploadedImageUrl = null;
                            }),
                            child: Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 24,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: _uploadedImageUrl!.startsWith('http')
                              ? Image.network(_uploadedImageUrl!.trim())
                              : Image.file(File(_uploadedImageUrl!)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: CustomButton(
                        text: "Cancel",
                        backgroundColor: purple20,
                        textColor: purple100,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: CustomButton(
                        text: widget.receiptId != null ? 'Update' : 'Save',
                        backgroundColor: purple100,
                        textColor: light80,
                        onPressed: _saveReceipt,
                      ),
                    ),
                  ),
                  if (widget.receiptId != null) ...[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: CustomButton(
                          text: 'Delete',
                          backgroundColor: red100,
                          textColor: light80,
                          onPressed: _confirmDelete,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
