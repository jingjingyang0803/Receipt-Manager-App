import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:receipt_manager/providers/category_provider.dart';
import 'package:receipt_manager/providers/receipt_provider.dart';
import 'package:receipt_manager/screens/old/receipt_list_screen.dart';

import '../components/category_select_popup.dart';
import '../components/old/rounded_button.dart';
import '../services/storage_service.dart';

class AddOrUpdateReceiptPage extends StatefulWidget {
  static const String id = 'add_update_receipt_page';
  final Map<String, dynamic>? existingReceipt; // Store existing receipt data
  final String? receiptId; // Store the receipt ID when editing

  const AddOrUpdateReceiptPage({
    super.key,
    this.existingReceipt,
    this.receiptId,
  });

  @override
  AddOrUpdateReceiptPageState createState() => AddOrUpdateReceiptPageState();
}

class AddOrUpdateReceiptPageState extends State<AddOrUpdateReceiptPage> {
  final StorageService storageService = StorageService(); // Storage instance

  final TextEditingController merchantController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();

  List<Map<String, dynamic>> categories = [];
  String? selectedCategoryId;
  String? selectedCategoryIcon;
  String? selectedCategoryName;
  String? selectedPaymentMethod; // Added payment method field

  bool isLoading = true;
  String? uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _initializeFormFields();
  }

  void _initializeFormFields() {
    if (widget.existingReceipt != null) {
      // Populate fields if editing an existing receipt
      merchantController.text = widget.existingReceipt!['merchant'] ?? '';
      dateController.text = widget.existingReceipt!['date']
              ?.toDate()
              .toLocal()
              .toString()
              .split(' ')[0] ??
          '';
      totalController.text =
          widget.existingReceipt!['amount']?.toString() ?? '';
      itemNameController.text = widget.existingReceipt!['itemName'] ?? '';
      descriptionController.text = widget.existingReceipt!['description'] ?? '';
      selectedCategoryId = widget.existingReceipt!['categoryId'];
      selectedPaymentMethod = widget.existingReceipt!['paymentMethod'] ?? '';

      if (widget.existingReceipt!.containsKey('imageUrl')) {
        uploadedImageUrl = widget.existingReceipt!['imageUrl'];
      }
    } else {
      // New receipt mode
      dateController.text = DateTime.now().toLocal().toString().split(' ')[0];
    }

    // Fetch categories through CategoryProvider
    Provider.of<CategoryProvider>(context, listen: false).loadUserCategories();
  }

  Future<void> uploadReceiptImage() async {
    String? imageUrl = await storageService.uploadReceiptImage();
    if (imageUrl != null) {
      setState(() {
        uploadedImageUrl = imageUrl.trim();
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
                    dateController.text =
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

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          // child: AddCategoryWidget(
          //   onCategoryAdded: () {
          //     Provider.of<CategoryProvider>(context, listen: false)
          //         .loadCategories();
          //   },
          // ),
        );
      },
    );
  }

  Future<void> _saveReceipt() async {
    final messenger = ScaffoldMessenger.of(context);
    final receiptProvider =
        Provider.of<ReceiptProvider>(context, listen: false);

    double? amount = double.tryParse(totalController.text.replaceAll(',', '.'));

    if (dateController.text.isEmpty || amount == null) {
      messenger.showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    Map<String, dynamic> receiptData = {
      'merchant': merchantController.text,
      'date': Timestamp.fromDate(DateTime.parse(dateController.text)),
      'amount': amount,
      'categoryId': selectedCategoryId,
      'paymentMethod': selectedPaymentMethod,
      'itemName': itemNameController.text,
      'description': descriptionController.text,
      'imageUrl': uploadedImageUrl ?? '',
    };

    try {
      if (widget.receiptId != null) {
        await receiptProvider.updateReceipt(
          receiptId: widget.receiptId!,
          updatedData: receiptData,
        );
        messenger.showSnackBar(
          SnackBar(content: Text('Receipt updated successfully')),
        );
      } else {
        await receiptProvider.addReceipt(receiptData: receiptData);
        messenger.showSnackBar(
          SnackBar(content: Text('Receipt saved successfully')),
        );
        _clearForm();
      }
      Navigator.pushReplacementNamed(context, ReceiptListScreen.id);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to save receipt. Try again.')),
      );
    }
  }

  void _clearForm() {
    setState(() {
      merchantController.clear();
      dateController.text = DateTime.now().toLocal().toString().split(' ')[0];
      totalController.clear();
      descriptionController.clear();
      itemNameController.clear();
      selectedCategoryId = null;
      selectedPaymentMethod = null;
      uploadedImageUrl = null;
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
      Navigator.pop(context);
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
        // Handle the selected category ID
        print('Selected category ID: $selectedCategoryId');
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
                controller: merchantController,
                decoration: InputDecoration(labelText: 'Merchant'),
              ),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: dateController,
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
                                labelText: selectedCategoryId?.isNotEmpty ==
                                        true
                                    ? '$selectedCategoryIcon $selectedCategoryName'
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
                      controller: itemNameController,
                      decoration: InputDecoration(labelText: 'Item Name'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedPaymentMethod,
                items: ['Credit Card', 'Debit Card', 'Cash', 'Other']
                    .map((method) => DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        ))
                    .toList(),
                onChanged: (value) => setState(() {
                  selectedPaymentMethod = value;
                }),
                decoration: InputDecoration(labelText: 'Payment Method'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: totalController,
                decoration: InputDecoration(
                  labelText: 'Total',
                  hintText: 'e.g. 0.00',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: uploadReceiptImage,
                  child: Text('Upload Receipt Image'),
                ),
              ),
              if (uploadedImageUrl != null) ...[
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
                              uploadedImageUrl = null;
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
                          child: uploadedImageUrl!.startsWith('http')
                              ? Image.network(uploadedImageUrl!.trim())
                              : Image.file(File(uploadedImageUrl!)),
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
                    child: RoundedButton(
                      color: Colors.lightBlueAccent,
                      title: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: RoundedButton(
                      color: Colors.blueAccent,
                      title: widget.receiptId != null ? 'Update' : 'Save',
                      onPressed: _saveReceipt,
                    ),
                  ),
                ],
              ),
              if (widget.receiptId != null)
                RoundedButton(
                  color: Colors.redAccent,
                  title: 'Delete',
                  onPressed: _confirmDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
