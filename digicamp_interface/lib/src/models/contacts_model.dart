import 'package:equatable/equatable.dart';

class ContactsResponse {
  int? count;
  String? next;
  String? previous;
  List<ContactsModel>? results;

  ContactsResponse({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory ContactsResponse.fromJson(Map<String, dynamic> json) {
    return ContactsResponse(
      count: json['count'] as int?,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: ContactsModel.fromMapList(json['results']),
    );
  }

  Map<String, dynamic> toJson() => {
        'count': count,
        'next': next,
        'previous': previous,
        'results': results?.map((e) => e.toJson()).toList(),
      };
}

class ContactsModel extends Equatable {
  final int? id;
  final String? name;
  final String? namePronunciation;
  final String? phoneNumber;
  final int? userId;
  final String? category1;
  final String? category2;
  final String? category3;
  final String? category4;
  final String? category5;
  final int? status;

  const ContactsModel({
    this.id,
    this.name,
    this.namePronunciation,
    this.phoneNumber,
    this.userId,
    this.category1,
    this.category2,
    this.category3,
    this.category4,
    this.category5,
    this.status,
  });

  factory ContactsModel.fromJson(Map<String, dynamic> json) => ContactsModel(
        id: json['id'] as int?,
        name: json['name'] as String?,
        namePronunciation: json['name_pronunciation'] as String?,
        phoneNumber: json['phone_number'] as String?,
        userId: json['user_id'] as int?,
        category1: json['category_1'] as String?,
        category2: json['category_2'] as String?,
        category3: json['category_3'] as String?,
        category4: json['category_4'] as String?,
        category5: json['category_5'] as String?,
        status: json['status'] as int?,
      );

  static List<ContactsModel> fromMapList(List? json) {
    if (json == null) {
      return [];
    }
    return List<ContactsModel>.from(
      json.map((v) => ContactsModel.fromJson(v)),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'name_pronunciation': namePronunciation,
        'phone_number': phoneNumber,
        'user_id': userId,
        'category_1': category1,
        'category_2': category2,
        'category_3': category3,
        'category_4': category4,
        'category_5': category5,
        'status': status,
      };

  Map<String, dynamic> toRestJson() => {
        'name': name,
        'phone_number': phoneNumber,
        'category_1':
            category1 != null && category1!.isEmpty ? null : category1,
        'category_2':
            category2 != null && category2!.isEmpty ? null : category2,
        'category_3':
            category3 != null && category3!.isEmpty ? null : category3,
        'category_4':
            category4 != null && category4!.isEmpty ? null : category4,
        'category_5':
            category5 != null && category5!.isEmpty ? null : category5,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        namePronunciation,
        phoneNumber,
        userId,
        category1,
        category2,
        category3,
        category4,
        category5,
        status,
      ];
}
