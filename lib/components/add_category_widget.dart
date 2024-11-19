import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:receipt_manager/components/custom_input_field.dart';

import '../constants/app_colors.dart';
import '../logger.dart';
import '../services/category_service.dart';
import 'custom_button.dart';

class AddCategoryWidget extends StatefulWidget {
  final String userId; // Add userId parameter
  final VoidCallback
      onCategoryAdded; // Callback to trigger after adding category

  const AddCategoryWidget(
      {super.key, required this.userId, required this.onCategoryAdded});

  @override
  AddCategoryWidgetState createState() => AddCategoryWidgetState();
}

class AddCategoryWidgetState extends State<AddCategoryWidget> {
  String categoryName = '';
  String selectedIcon = '😊'; // Default icon
  bool showEmojiPicker = false; // Track whether to show emoji picker
  String? _errorMessage; // Error message for duplicate category names

  final CategoryService _categoryService = CategoryService();
  final FocusNode _textFieldFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Hide emoji picker when the text field is focused
    _textFieldFocusNode.addListener(() {
      if (_textFieldFocusNode.hasFocus) {
        setState(() {
          showEmojiPicker = false; // Hide emoji picker
        });
      }
    });
  }

  @override
  void dispose() {
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon selection
          GestureDetector(
            onTap: () {
              setState(() {
                showEmojiPicker = !showEmojiPicker; // Toggle emoji picker
                if (showEmojiPicker) {
                  _textFieldFocusNode
                      .unfocus(); // Remove focus if picker is opened
                }
              });
            },
            child: CircleAvatar(
              radius: 40,
              backgroundColor: light40,
              child: Text(
                selectedIcon,
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ),
          SizedBox(height: 10),

          // Show emoji picker if toggled
          if (showEmojiPicker)
            SizedBox(
              height: 200, // Adjust height as necessary
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  setState(() {
                    selectedIcon = emoji.emoji; // Update selected emoji
                  });
                },
                config: Config(
                  height: 256,
                  checkPlatformCompatibility: true,
                  viewOrderConfig: const ViewOrderConfig(),
                  emojiViewConfig: EmojiViewConfig(
                    emojiSizeMax: 28 *
                        (foundation.defaultTargetPlatform == TargetPlatform.iOS
                            ? 1.2
                            : 1.0),
                  ),
                ),
              ),
            ),
          SizedBox(height: 10),

          // Category name input field
          CustomTextFormField(
            focusNode: _textFieldFocusNode, // Attach focus node
            labelText: "Category name",
            onChanged: (value) {
              setState(() {
                categoryName = value;
                _errorMessage = null; // Reset error when input changes
              });
            },
          ),
          SizedBox(height: 10),

          // Add button
          CustomButton(
            text: "Add Category",
            backgroundColor: purple100,
            textColor: light80,
            onPressed: () async {
              if (categoryName.isNotEmpty) {
                try {
                  // Check if the category exists
                  bool categoryExists = await _categoryService.categoryExists(
                      widget.userId, categoryName);

                  if (categoryExists) {
                    logger.w("Category '$categoryName' already exists.");
                    // Show a toast or another dialog instead of using the closed context
                    setState(() {
                      _errorMessage =
                          "Category '$categoryName' already exists.";
                    });
                  } else {
                    if (mounted) {
                      Navigator.of(context).pop(); // Close dialog immediately
                    }

                    // Add category to Firestore
                    await _categoryService.addCategoryToFirestore(
                        widget.userId, categoryName, selectedIcon);

                    // Trigger the callback after adding the category
                    widget.onCategoryAdded();
                  }
                } catch (e) {
                  logger.e("An error occurred: ${e.toString()}");
                }
              } else {
                if (mounted) {
                  setState(() {
                    _errorMessage = "Category name cannot be empty.";
                  });
                }
              }
            },
          )
        ],
      ),
    );
  }
}
