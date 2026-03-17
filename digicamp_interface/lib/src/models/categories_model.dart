class CategoriesModel {
  List<String?> category1;
  List<String?> category2;
  List<String?> category3;
  List<String?> category4;
  List<String?> category5;

  CategoriesModel({
    this.category1 = const [],
    this.category2 = const [],
    this.category3 = const [],
    this.category4 = const [],
    this.category5 = const [],
  });

  factory CategoriesModel.fromJson(Map<String, dynamic> json) {
    List<String?> category1 =
        (json['category_1'] as List?)?.cast<String?>() ?? const <String?>[];
    List<String?> category2 =
        (json['category_2'] as List?)?.cast<String?>() ?? const <String?>[];
    List<String?> category3 =
        (json['category_3'] as List?)?.cast<String?>() ?? const <String?>[];
    List<String?> category4 =
        (json['category_4'] as List?)?.cast<String?>() ?? const <String?>[];
    List<String?> category5 =
        (json['category_5'] as List?)?.cast<String?>() ?? const <String?>[];

    category1 = category1..removeWhere((e) => e == null);
    category2 = category2..removeWhere((e) => e == null);
    category3 = category3..removeWhere((e) => e == null);
    category4 = category4..removeWhere((e) => e == null);
    category5 = category5..removeWhere((e) => e == null);

    return CategoriesModel(
      category1: category1,
      category2: category2,
      category3: category3,
      category4: category4,
      category5: category5,
    );
  }

  Map<String, List<String?>?> toJson() => {
        'category_1': category1,
        'category_2': category2,
        'category_3': category3,
        'category_4': category4,
        'category_5': category5,
      };
}
