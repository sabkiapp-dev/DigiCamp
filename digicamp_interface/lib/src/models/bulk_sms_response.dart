import 'package:flutter/material.dart';
import 'package:digicamp_interface/src/models/sms_response_model.dart';

class BulkSmsResponse {
  int? currentPage;
  int? totalPages;
  List<BulkSmsModel>? data;
  String? message;

  BulkSmsResponse({
    this.currentPage,
    this.totalPages,
    this.data,
    this.message,
  });

  factory BulkSmsResponse.fromJson(Map<String, dynamic> json) {
    return BulkSmsResponse(
      currentPage: json['current_page'] as int?,
      totalPages: json['total_pages'] as int?,
      data: BulkSmsModel.fromMapList(json['data']),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'total_pages': totalPages,
        'data': data?.map((e) => e.toJson()).toList(),
        'message': message,
      };
}

class BulkSmsModel {
  int? id;
  String? name;
  String? description;
  int? priority;
  String? startTime;
  String? endTime;
  DateTime? startDate;
  DateTime? endDate;
  int? contactCount;
  SMSTemplateModel? template;
  String? category1;
  String? category2;
  String? category3;
  String? category4;
  String? category5;
  ValueNotifier<int> status = ValueNotifier(1);

  BulkSmsModel({
    this.id,
    this.name,
    this.description,
    this.priority,
    this.startTime,
    this.endTime,
    this.startDate,
    this.endDate,
    this.contactCount,
    this.template,
    this.category1,
    this.category2,
    this.category3,
    this.category4,
    this.category5,
  });

  factory BulkSmsModel.fromJson(Map<String, dynamic> json) => BulkSmsModel(
        id: json['id'] as int?,
        name: json['name'] as String?,
        description: json['description'] as String?,
        priority: json['priority'] as int?,
        startTime: json['start_time'] as String?,
        endTime: json['end_time'] as String?,
        startDate: json['start_date'] != null
            ? DateTime.parse(json['start_date'] as String)
            : null,
        endDate: json['end_date'] != null
            ? DateTime.parse(json['end_date'] as String)
            : null,
        contactCount: json['contact_count'] as int?,
        template: json['template'] != null
            ? SMSTemplateModel.fromJson(json['template'])
            : null,
        category1: json['category1'] as String?,
        category2: json['category2'] as String?,
        category3: json['category3'] as String?,
        category4: json['category4'] as String?,
        category5: json['category5'] as String?,
      )..status = ValueNotifier(json['status'] ?? 1);

  static List<BulkSmsModel> fromMapList(List? json) {
    if (json == null) {
      return [];
    }
    return List<BulkSmsModel>.from(
      json.map((v) => BulkSmsModel.fromJson(v)),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'priority': priority,
        'start_time': startTime,
        'end_time': endTime,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'contact_count': contactCount,
        'template': template?.toJson(),
        'category1': category1,
        'category2': category2,
        'category3': category3,
        'category4': category4,
        'category5': category5,
        'status': status.value,
      };
}
