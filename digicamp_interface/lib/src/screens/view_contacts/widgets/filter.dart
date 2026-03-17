import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/utils/extensions/size_extension.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class ContactsFilter extends StatefulWidget {
  const ContactsFilter({
    super.key,
    required this.setState,
    required this.cat1Filter,
    required this.cat2Filter,
    required this.cat3Filter,
    required this.cat4Filter,
    required this.cat5Filter,
    this.confirmText,
    this.cancelText,
  });

  final StateSetter setState;
  final List<String> cat1Filter;
  final List<String> cat2Filter;
  final List<String> cat3Filter;
  final List<String> cat4Filter;
  final List<String> cat5Filter;
  final String? confirmText;
  final String? cancelText;

  @override
  State<ContactsFilter> createState() => _ContactsFilterState();
}

class _ContactsFilterState extends State<ContactsFilter> {
  int _selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      clipBehavior: Clip.hardEdge,
      constraints: BoxConstraints(
        maxWidth: context.sw() - 20,
        minWidth: context.sw() - 20,
      ),
      showDragHandle: true,
      onClosing: () {},
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        "Category 1",
                        "Category 2",
                        "Category 3",
                        "Category 4",
                        "Category 5",
                      ].asMap().entries.map((entry) {
                        return ListTile(
                          onTap: () {
                            _selectedCategory = entry.key;
                            setState(() {});
                          },
                          title: Text(entry.value),
                          selectedTileColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                          selected: _selectedCategory == entry.key,
                        );
                      }).toList(),
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  Expanded(
                    flex: 2,
                    child: FutureBuilder<Data<CategoriesModel>>(
                      future: locator<ApiClient>().getUniqueCategories(
                        category1:
                            _selectedCategory == 0 ? [] : widget.cat1Filter,
                        category2:
                            _selectedCategory == 1 ? [] : widget.cat2Filter,
                        category3:
                            _selectedCategory == 2 ? [] : widget.cat3Filter,
                        category4:
                            _selectedCategory == 3 ? [] : widget.cat4Filter,
                        category5:
                            _selectedCategory == 4 ? [] : widget.cat5Filter,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.data == null ||
                            !snapshot.data!.isSuccess) {
                          return const Center(
                            child: Text("Categories not found"),
                          );
                        }

                        return _CategoryList(
                          cat1Filter: widget.cat1Filter,
                          cat2Filter: widget.cat2Filter,
                          cat3Filter: widget.cat3Filter,
                          cat4Filter: widget.cat4Filter,
                          cat5Filter: widget.cat5Filter,
                          selectedCategory: _selectedCategory,
                          categories: snapshot.data!.data!,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  if (widget.cancelText != null)
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(20.0),
                        ),
                        onPressed: () {
                          widget.cat1Filter.clear();
                          widget.cat2Filter.clear();
                          widget.cat3Filter.clear();
                          widget.cat4Filter.clear();
                          widget.cat5Filter.clear();
                          setState(() {});
                          widget.setState(() {});
                          context.pop();
                        },
                        child: Text(widget.cancelText!),
                      ),
                    ),
                  const Gap(10),
                  if (widget.confirmText != null)
                    Expanded(
                      child: ElevatedButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(20.0),
                        ),
                        onPressed: () {
                          widget.setState(() {});
                          context.pop();
                        },
                        child: Text(widget.confirmText!),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryList extends StatefulWidget {
  const _CategoryList({
    super.key,
    required this.cat1Filter,
    required this.cat2Filter,
    required this.cat3Filter,
    required this.cat4Filter,
    required this.cat5Filter,
    required this.selectedCategory,
    required this.categories,
  });
  final List<String> cat1Filter;
  final List<String> cat2Filter;
  final List<String> cat3Filter;
  final List<String> cat4Filter;
  final List<String> cat5Filter;
  final int selectedCategory;
  final CategoriesModel categories;

  @override
  State<_CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<_CategoryList> {
  @override
  Widget build(BuildContext context) {
    final isAllSelected = widget.categories
        .toJson()
        .values
        .toList()[widget.selectedCategory]!
        .every((element) {
      if (widget.selectedCategory == 0) {
        return widget.cat1Filter.contains(element);
      } else if (widget.selectedCategory == 1) {
        return widget.cat2Filter.contains(element);
      } else if (widget.selectedCategory == 2) {
        return widget.cat3Filter.contains(element);
      } else if (widget.selectedCategory == 3) {
        return widget.cat4Filter.contains(element);
      } else {
        return widget.cat5Filter.contains(element);
      }
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            if (isAllSelected) {
              switch (widget.selectedCategory) {
                case 0:
                  widget.cat1Filter.clear();
                  break;
                case 1:
                  widget.cat2Filter.clear();
                  break;
                case 2:
                  widget.cat3Filter.clear();
                  break;
                case 3:
                  widget.cat4Filter.clear();
                  break;
                case 4:
                  widget.cat5Filter.clear();
                  break;
              }
            } else {
              final values = widget.categories
                  .toJson()
                  .values
                  .toList()[widget.selectedCategory]!
                  .map((e) => e!)
                  .toList();

              switch (widget.selectedCategory) {
                case 0:
                  widget.cat1Filter.addAll(values);
                  break;
                case 1:
                  widget.cat2Filter.addAll(values);
                  break;
                case 2:
                  widget.cat3Filter.addAll(values);
                  break;
                case 3:
                  widget.cat4Filter.addAll(values);
                  break;
                case 4:
                  widget.cat5Filter.addAll(values);
                  break;
              }
            }
            setState(() {});
          },
          child: Text(
            isAllSelected ? "Deselect All" : "Select All",
          ),
        ),
        Expanded(
          child: ListView(
            children: widget.categories
                .toJson()
                .values
                .toList()[widget.selectedCategory]!
                .map((value) {
              return CheckboxListTile(
                onChanged: (_) => _onChanged(value),
                value: _value(value),
                title: Text(value!),
                selectedTileColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.2),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  bool _value(String? value) {
    if (widget.selectedCategory == 0) {
      return widget.cat1Filter.contains(value);
    } else if (widget.selectedCategory == 1) {
      return widget.cat2Filter.contains(value);
    } else if (widget.selectedCategory == 2) {
      return widget.cat3Filter.contains(value);
    } else if (widget.selectedCategory == 3) {
      return widget.cat4Filter.contains(value);
    } else {
      return widget.cat5Filter.contains(value);
    }
  }

  void _onChanged(String value) {
    switch (widget.selectedCategory) {
      case 0:
        if (widget.cat1Filter.contains(value)) {
          widget.cat1Filter.remove(value);
        } else {
          widget.cat1Filter.add(value);
        }
        widget.cat2Filter.clear();
        widget.cat3Filter.clear();
        widget.cat4Filter.clear();
        widget.cat5Filter.clear();
        break;
      case 1:
        if (widget.cat2Filter.contains(value)) {
          widget.cat2Filter.remove(value);
        } else {
          widget.cat2Filter.add(value);
        }
        widget.cat3Filter.clear();
        widget.cat4Filter.clear();
        widget.cat5Filter.clear();
        break;
      case 2:
        if (widget.cat3Filter.contains(value)) {
          widget.cat3Filter.remove(value);
        } else {
          widget.cat3Filter.add(value);
        }
        widget.cat4Filter.clear();
        widget.cat5Filter.clear();
        break;
      case 3:
        if (widget.cat4Filter.contains(value)) {
          widget.cat4Filter.remove(value);
        } else {
          widget.cat4Filter.add(value);
        }
        widget.cat5Filter.clear();
        break;
      case 4:
        if (widget.cat5Filter.contains(value)) {
          widget.cat5Filter.remove(value);
        } else {
          widget.cat5Filter.add(value);
        }
        break;
    }
    setState(() {});
  }
}
