import 'package:flutter/material.dart';

class SmsResponseModel {
  int? currentPage;
  int? totalPages;
  List<SMSTemplateModel>? templates;

  SmsResponseModel({this.currentPage, this.totalPages, this.templates});

  factory SmsResponseModel.fromJson(Map<String, dynamic> json) =>
      SmsResponseModel(
        currentPage: json['current_page'] as int?,
        totalPages: json['total_pages'] as int?,
        templates: (json['templates'] as List<dynamic>?)
            ?.map((e) => SMSTemplateModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'total_pages': totalPages,
        'templates': templates?.map((e) => e.toJson()).toList(),
      };
}

class SMSTemplateModel {
  int? id;
  String? templateName;
  String? template;
  ValueNotifier<int> status = ValueNotifier(1);

  SMSTemplateModel({
    this.id,
    this.templateName,
    this.template,
  });

  factory SMSTemplateModel.fromJson(Map<String, dynamic> json) =>
      SMSTemplateModel(
        id: json['id'] as int?,
        templateName: json['template_name'] as String?,
        template: json['template'] as String?,
      )..status = ValueNotifier(json['status']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'template_name': templateName,
        'template': template,
      };
}
