// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:quickalert/quickalert.dart';
// import 'package:digicamp_interface/injection_container.dart';
// import 'package:digicamp_interface/src/commons/general_dialogs.dart';
// import 'package:digicamp_interface/src/models/models.dart';
// import 'package:digicamp_interface/src/providers/providers.dart';
// import 'package:digicamp_interface/src/utils/services/rest_api.dart';

// class CategoryContactsDelete extends StatefulWidget {
//   const CategoryContactsDelete({
//     super.key,
//     required this.setState,
//   });
//   final StateSetter setState;

//   @override
//   State<CategoryContactsDelete> createState() => _CategoryContactsDeleteState();
// }

// class _CategoryContactsDeleteState extends State<CategoryContactsDelete> {
//   List<String> _selectedCategory1 = [];
//   List<String> _selectedCategory2 = [];
//   List<String> _selectedCategory3 = [];
//   List<String> _selectedCategory4 = [];
//   List<String> _selectedCategory5 = [];
//   final _categoriesFuture = locator<ApiClient>().getUniqueCategories();

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: FutureBuilder(
//         future: _categoriesFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircularProgressIndicator(),
//               ],
//             );
//           }
//           if (!snapshot.hasData || !snapshot.data!.isSuccess) {
//             return const Text("Category not found");
//           }
//           final categories = snapshot.data!.data as CategoriesModel;
//           return Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Category 1",
//                 style: Theme.of(context).textTheme.bodySmall,
//               ),
//               DropdownSearch<String>.multiSelection(
//                 items: categories.category1.map((e) => e!).toList(),
//                 selectedItems: _selectedCategory1,
//                 popupProps: PopupPropsMultiSelection.menu(
//                   fit: FlexFit.loose,
//                   emptyBuilder: (context, searchEntry) {
//                     return const Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Text("Category not found"),
//                     );
//                   },
//                 ),
//                 onChanged: (value) {
//                   _selectedCategory1 = value;
//                   setState(() {});
//                 },
//                 clearButtonProps: const ClearButtonProps(
//                   visualDensity: VisualDensity.compact,
//                 ),
//               ),
//               const Gap(10),
//               Text(
//                 "Category 2",
//                 style: Theme.of(context).textTheme.bodySmall,
//               ),
//               DropdownSearch<String>.multiSelection(
//                 items: categories.category2.map((e) => e!).toList(),
//                 selectedItems: _selectedCategory2,
//                 popupProps: PopupPropsMultiSelection.menu(
//                   fit: FlexFit.loose,
//                   emptyBuilder: (context, searchEntry) {
//                     return const Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Text("Category not found"),
//                     );
//                   },
//                 ),
//                 onChanged: (value) {
//                   _selectedCategory2 = value;
//                   setState(() {});
//                 },
//                 clearButtonProps: const ClearButtonProps(
//                   visualDensity: VisualDensity.compact,
//                 ),
//               ),
//               const Gap(10),
//               Text(
//                 "Category 3",
//                 style: Theme.of(context).textTheme.bodySmall,
//               ),
//               DropdownSearch<String>.multiSelection(
//                 items: categories.category3.map((e) => e!).toList(),
//                 selectedItems: _selectedCategory3,
//                 popupProps: PopupPropsMultiSelection.menu(
//                   fit: FlexFit.loose,
//                   emptyBuilder: (context, searchEntry) {
//                     return const Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Text("Category not found"),
//                     );
//                   },
//                 ),
//                 onChanged: (value) {
//                   _selectedCategory3 = value;
//                   setState(() {});
//                 },
//                 clearButtonProps: const ClearButtonProps(
//                   visualDensity: VisualDensity.compact,
//                 ),
//               ),
//               const Gap(10),
//               Text(
//                 "Category 4",
//                 style: Theme.of(context).textTheme.bodySmall,
//               ),
//               DropdownSearch<String>.multiSelection(
//                 items: categories.category4.map((e) => e!).toList(),
//                 selectedItems: _selectedCategory4,
//                 popupProps: PopupPropsMultiSelection.menu(
//                   fit: FlexFit.loose,
//                   emptyBuilder: (context, searchEntry) {
//                     return const Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Text("Category not found"),
//                     );
//                   },
//                 ),
//                 onChanged: (value) {
//                   _selectedCategory4 = value;
//                   setState(() {});
//                 },
//                 clearButtonProps: const ClearButtonProps(
//                   visualDensity: VisualDensity.compact,
//                 ),
//               ),
//               const Gap(10),
//               Text(
//                 "Category 5",
//                 style: Theme.of(context).textTheme.bodySmall,
//               ),
//               DropdownSearch<String>.multiSelection(
//                 items: categories.category5.map((e) => e!).toList(),
//                 selectedItems: _selectedCategory5,
//                 popupProps: PopupPropsMultiSelection.menu(
//                   fit: FlexFit.loose,
//                   emptyBuilder: (context, searchEntry) {
//                     return const Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Text("Category not found"),
//                     );
//                   },
//                 ),
//                 onChanged: (value) {
//                   _selectedCategory5 = value;
//                   setState(() {});
//                 },
//                 clearButtonProps: const ClearButtonProps(
//                   visualDensity: VisualDensity.compact,
//                 ),
//               ),
//               const Gap(10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   TextButton(
//                     onPressed: () => context.pop(),
//                     child: const Text("Cancel"),
//                   ),
//                   TextButton(
//                     onPressed: _delete,
//                     child: const Text("Delete"),
//                   ),
//                 ],
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   void _delete() async {
//     if (_selectedCategory1.isEmpty &
//         _selectedCategory2.isEmpty &
//         _selectedCategory3.isEmpty &
//         _selectedCategory4.isEmpty &
//         _selectedCategory5.isEmpty) {
//       QuickAlert.show(
//         context: context,
//         width: 200,
//         type: QuickAlertType.warning,
//         text: "Please select at least one category",
//       );
//       return;
//     }
//     final userConsent = await _userConsent();
//     if (mounted && userConsent == true) {
//       context.read<HudProvider>().showProgress();
//       final response = await locator<ApiClient>().categoryContactsDelete(
//         category1: _selectedCategory1,
//         category2: _selectedCategory2,
//         category3: _selectedCategory3,
//         category4: _selectedCategory4,
//         category5: _selectedCategory5,
//       );

//       if (mounted && response.isSuccess) {
//         QuickAlert.show(
//           context: context,
//           width: 200,
//           type: QuickAlertType.success,
//           text: response.message,
//         );
//         widget.setState(() {});
//         context.pop();
//       }
//       if (mounted) {
//         context.read<HudProvider>().hideProgress();
//       }
//     }
//   }

//   Future<bool?> _userConsent() {
//     return generalDialog<bool>(
//       context: context,
//       content: FutureBuilder(
//         future: locator<ApiClient>().countCategoryContacts(
//           category1: _selectedCategory1,
//           category2: _selectedCategory2,
//           category3: _selectedCategory3,
//           category4: _selectedCategory4,
//           category5: _selectedCategory5,
//         ),
//         builder: (context, snapshot) {
//           return Padding(
//             padding: const EdgeInsets.only(top: 24.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 if (snapshot.connectionState == ConnectionState.waiting)
//                   const CircularProgressIndicator()
//                 else if (snapshot.hasData &&
//                     snapshot.data!.isSuccess &&
//                     snapshot.data!.data! > 0) ...[
//                   Text(
//                     "Are you sure?\nYou want to delete ${snapshot.data!.data} contact(s).",
//                   ),
//                   const Gap(10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       TextButton(
//                         onPressed: () => context.pop(false),
//                         child: const Text("Close"),
//                       ),
//                       TextButton(
//                         onPressed: () => context.pop(true),
//                         child: const Text("Yes"),
//                       ),
//                     ],
//                   ),
//                 ] else
//                   const Text("Contacts not found"),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
