import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:receipt_manager/providers/category_provider.dart';
import 'package:receipt_manager/providers/receipt_provider.dart';

import '../components/category_select_popup.dart';
import '../components/currency_roller_picker_popup.dart';
import '../components/custom_button.dart';
import '../components/custom_divider.dart';
import '../components/date_picker_popup.dart';
import '../components/payment_roller_picker_popup.dart';
import '../constants/app_colors.dart';
import '../providers/user_provider.dart';
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
  String? _selectedCurrencyCode;

  String? _uploadedImageUrl;
  XFile? _imageFile; // Store the selected image

  @override
  void initState() {
    super.initState();
    _loadUserCategories();
    _initializeFormFields();
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

      _selectedPaymentMethod = widget.existingReceipt!['paymentMethod'] ?? '';
      _dateController.text = widget.existingReceipt!['date']
              ?.toDate()
              .toLocal()
              .toString()
              .split(' ')[0] ??
          '';

      _selectedCurrencyCode = widget.existingReceipt!['currencyCode'];
      _totalController.text =
          widget.existingReceipt!['amount']?.toString() ?? '';

      _selectedCategoryId = widget.existingReceipt!['categoryId'];
      _selectedCategoryName = widget.existingReceipt!['categoryName'];
      _selectedCategoryIcon = widget.existingReceipt!['categoryIcon'];
      _itemNameController.text = widget.existingReceipt!['itemName'] ?? '';

      _descriptionController.text =
          widget.existingReceipt!['description'] ?? '';

      if (widget.existingReceipt!['imageUrl'] != null) {
        _uploadedImageUrl = widget.existingReceipt!['imageUrl'];
      }
    } else if (widget.extract != null) {
      // Populate fields if data is passed via extract
      _merchantController.text = widget.extract!['merchant'] ?? '';
      _dateController.text = widget.extract!['date'] ??
          DateTime.now().toLocal().toString().split(' ')[0];

      final extractCurrencyCode = widget.extract!['currency'] ?? '';
      final extractAmount = widget.extract!['amount'] ?? '';

      _selectedCurrencyCode = extractCurrencyCode;
      _totalController.text = extractAmount.toString();

      _imageFile = XFile(widget.extract!['imagePath']);
    } else {
      // New receipt mode
      _dateController.text = DateTime.now().toLocal().toString().split(' ')[0];

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _selectedCurrencyCode = userProvider.currencyCode;
    }

    // Fetch categories through CategoryProvider
    Provider.of<CategoryProvider>(context, listen: false).loadUserCategories();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        // Convert XFile to Image widget using Image.file
        _imageFile = image;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DatePickerPopup(
          initialDate: DateTime.now(),
          onConfirm: (DateTime selectedDate) {
            setState(() {
              _dateController.text = "${selectedDate.toLocal()}".split(' ')[0];
            });
            Navigator.pop(context);
          },
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
        SnackBar(
            content: Text('Please fill in all required fields with * mark')),
      );
      return;
    }

    // Pass the XFile (not the Image widget) to the upload method
    String? imageUrl = _imageFile != null
        ? await _storageService.uploadReceiptImage(_imageFile! as XFile?)
        : null;

    Map<String, dynamic> receiptData = {
      'merchant': _merchantController.text,
      'date': Timestamp.fromDate(DateTime.parse(_dateController.text)),
      'currencyCode': _selectedCurrencyCode,
      'amount': amount,
      'categoryId': _selectedCategoryId,
      'paymentMethod': _selectedPaymentMethod,
      'itemName': _itemNameController.text,
      'description': _descriptionController.text,
      'imageUrl': imageUrl ?? '',
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
      // Navigator.pushReplacementNamed(context, BasePage.id);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BasePage(),
          ));
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
    bool? confirm = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
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
              const CustomDivider(),
              SizedBox(height: 8),
              Text(
                'Delete Receipt?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Are you sure you want to delete this receipt?',
                style: TextStyle(
                  fontSize: 16,
                  color: purple200,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
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
                        onPressed: () {
                          Navigator.of(context).pop(false); // Return false
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: CustomButton(
                        text: "Delete",
                        backgroundColor: Colors.redAccent,
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.of(context).pop(true); // Return true
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );

    if (confirm == true) {
      // Perform delete operation
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

  Future<void> _showCurrencyPicker(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return CurrencyPicker(
          selectedCurrencyCode: 'EUR', // Provide a default,
          onCurrencyCodeSelected: (String newCurrencyCode) async {
            // Update the state to reflect the new currency immediately
            setState(() {
              _selectedCurrencyCode = newCurrencyCode;
            });
          },
        );
      },
    );
  }

  InputDecoration buildRequiredFieldDecoration(String label) {
    return InputDecoration(
      label: RichText(
        text: TextSpan(
          text: label,
          style: TextStyle(color: Colors.grey, fontSize: 16),
          children: [
            TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration buildDynamicLabelDecoration({
    required String label,
    required bool isSelected,
    String? selectedValue,
  }) {
    return InputDecoration(
      label: RichText(
        text: TextSpan(
          text: isSelected && selectedValue != null ? selectedValue : label,
          style: TextStyle(color: Colors.grey, fontSize: 16),
          children: [
            if (!isSelected) // Add red asterisk if not selected
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
          ],
        ),
      ),
      border: OutlineInputBorder(),
    );
  }

  void _showPaymentMethodPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return PaymentMethodPicker(
          selectedPaymentMethod: _selectedPaymentMethod ?? '',
          onPaymentMethodSelected: (String selectedMethod) {
            setState(() {
              _selectedPaymentMethod = selectedMethod;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.receiptId != null ? 'Update Receipt' : 'New Receipt',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Static Divider
          Divider(color: Colors.grey.shade300, thickness: 1, height: 1),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _merchantController,
                    decoration: InputDecoration(labelText: 'Merchant'),
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
                              onTap: () {
                                // Show payment method picker (you need to implement this)
                                _showPaymentMethodPicker(context);
                              },
                              child: AbsorbPointer(
                                child: TextField(
                                  decoration: buildDynamicLabelDecoration(
                                    label: 'Select Payment',
                                    isSelected:
                                        _selectedPaymentMethod != null &&
                                            _selectedPaymentMethod!.isNotEmpty,
                                    selectedValue: _selectedPaymentMethod,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: TextField(
                              controller: _dateController,
                              decoration: buildRequiredFieldDecoration('Date'),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                              onTap: () => _showCurrencyPicker(context),
                              child: AbsorbPointer(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText:
                                        _selectedCurrencyCode?.isNotEmpty ==
                                                true
                                            ? _selectedCurrencyCode
                                            : 'Select Currency',
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
                          controller: _totalController,
                          decoration: buildRequiredFieldDecoration('Total'),
                        ),
                      ),
                    ],
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
                                  decoration: buildDynamicLabelDecoration(
                                    label: 'Select Category',
                                    isSelected:
                                        _selectedCategoryId?.isNotEmpty == true,
                                    selectedValue: _selectedCategoryId
                                                ?.isNotEmpty ==
                                            true
                                        ? '$_selectedCategoryIcon $_selectedCategoryName'
                                        : null,
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
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: pickImage,
                      child: Text(
                          _imageFile == null ? 'Select Image' : 'Change Image'),
                    ),
                  ),
                  if (_imageFile != null || _uploadedImageUrl != null) ...[
                    // Display local image file for new receipts
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Column(
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  _imageFile =
                                      null; // Clear the image when tapped

                                  _uploadedImageUrl =
                                      null; // Clear the network image URL
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
                              child: _imageFile != null
                                  ? Image.file(File(_imageFile!
                                      .path)) // Display local image file
                                  : (_uploadedImageUrl != null
                                      ? Image.network(
                                          _uploadedImageUrl!) // Display network image
                                      : Container()), // Default empty container if both are null
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
                          padding: const EdgeInsets.symmetric(
                              horizontal:
                                  4.0), // Reduced spacing between buttons
                          child: CustomButton(
                            text: "Cancel",
                            backgroundColor: Colors.blueGrey,
                            textStyle: const TextStyle(
                              fontSize: 14, // Reduced font size
                              fontWeight: FontWeight.w500,
                              color: Colors
                                  .white, // Explicitly set text color to white
                            ),
                            onPressed: () => Navigator.pop(context),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12), // Adjust button padding
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal:
                                  4.0), // Reduced spacing between buttons
                          child: CustomButton(
                            text: widget.receiptId != null ? 'Update' : 'Save',
                            backgroundColor: purple100,
                            textStyle: const TextStyle(
                              fontSize: 14, // Reduced font size
                              fontWeight: FontWeight.w500,
                              color: Colors
                                  .white, // Explicitly set text color to white
                            ),
                            onPressed: _saveReceipt,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12), // Adjust button padding
                          ),
                        ),
                      ),
                      if (widget.receiptId != null) ...[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal:
                                    4.0), // Reduced spacing between buttons
                            child: CustomButton(
                              text: 'Delete',
                              backgroundColor: red100,
                              textStyle: const TextStyle(
                                fontSize: 14, // Reduced font size
                                fontWeight: FontWeight.w500,
                                color: Colors
                                    .white, // Explicitly set text color to white
                              ),
                              onPressed: _confirmDelete,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12), // Adjust button padding
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
        ],
      ),
    );
  }
}
