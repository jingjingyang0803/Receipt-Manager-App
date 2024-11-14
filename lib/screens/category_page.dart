import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receipt_manager/components/category_delete_popup.dart';

import '../components/add_category_widget.dart';
import '../constants/app_colors.dart';
import '../providers/authentication_provider.dart';
import '../providers/category_provider.dart';

class CategoryPage extends StatefulWidget {
  static const String id = 'category_page';

  const CategoryPage({super.key});

  @override
  CategoryPageState createState() => CategoryPageState();
}

class CategoryPageState extends State<CategoryPage> {
  @override
  void initState() {
    super.initState();
    loadCategoriesForUser();
  }

  void loadCategoriesForUser() {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);

    final userEmail = authProvider.user?.email;
    if (userEmail != null) {
      categoryProvider.loadUserCategories(userEmail);
    }
  }

  void _showAddCategoryDialog() {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    final userEmail = authProvider.user?.email;

    if (userEmail != null) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: AddCategoryWidget(
              userId: userEmail,
              onCategoryAdded: () {
                Provider.of<CategoryProvider>(context, listen: false)
                    .loadUserCategories(userEmail);
              },
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Categories', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(children: [
        // Thin, subtle divider line under the AppBar
        Divider(
          color: Colors.grey.shade300,
          thickness: 1,
          height: 1,
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Consumer<CategoryProvider>(
              builder: (context, categoryProvider, _) {
                final categories = categoryProvider.categories;

                return ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    String categoryId = categories[index]['id'] ?? '';
                    String categoryName =
                        categories[index]['name']?.trim() ?? '';

                    return ListTile(
                      leading: Text(
                        categories[index]['icon'] ?? '',
                        style: TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        categoryName,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, color: purple100),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return CategoryDeletePopup(
                                onConfirm: () {
                                  Navigator.of(context).pop();
                                },
                                onCancel: () {
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            ),
          ),
        )
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        backgroundColor: purple100,
        elevation: 6,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
