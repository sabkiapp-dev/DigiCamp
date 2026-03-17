import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'audio_response_model.dart';
import 'ref_user.dart';

class CampaignResponse {
  int? currentPage;
  int? totalPages;
  List<CampaignModel>? data;

  CampaignResponse({
    this.currentPage,
    this.totalPages,
    this.data,
  });

  factory CampaignResponse.fromJson(Map<String, dynamic> json) {
    return CampaignResponse(
      currentPage: json['current_page'] as int?,
      totalPages: json['total_pages'] as int?,
      data: CampaignModel.fromMapList(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'total_pages': totalPages,
        'data': data?.map((e) => e.toJson()).toList(),
      };
}

class CampaignModel {
  int? id;
  String? name;
  String? description;
  int? callCutTime;
  String? startTime;
  String? endTime;
  DateTime? startDate;
  DateTime? endDate;
  int? campaignPriority;
  int? status;
  AudioModel? wrongKeyAudio;
  AudioModel? noKeyAudio;
  String? language;
  int? allowRepeat;
  DateTime? modifiedAt;
  DateTime? createdAt;
  int? user;
  int? contactCount;
  List<HostModel> hosts = [];

  CampaignModel({
    this.id,
    this.name,
    this.description,
    this.callCutTime,
    this.startTime,
    this.endTime,
    this.startDate,
    this.endDate,
    this.campaignPriority,
    this.status,
    this.wrongKeyAudio,
    this.noKeyAudio,
    this.language,
    this.allowRepeat,
    this.modifiedAt,
    this.createdAt,
    this.user,
    this.contactCount,
    this.hosts = const [],
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) => CampaignModel(
        id: json['id'] as int?,
        name: json['name'] as String?,
        description: json['description'] as String?,
        callCutTime: json['call_cut_time'] as int?,
        startTime: json['start_time'] as String?,
        endTime: json['end_time'] as String?,
        startDate: json['start_date'] == null
            ? null
            : DateTime.parse(json['start_date'] as String),
        endDate: json['end_date'] == null
            ? null
            : DateTime.parse(json['end_date'] as String),
        campaignPriority: json['campaign_priority'] as int?,
        status: json['status'] as int?,
        wrongKeyAudio: json['wrong_key_voice'] == null
            ? null
            : AudioModel.fromJson(
                json['wrong_key_voice'] as Map<String, dynamic>),
        noKeyAudio: json['no_key_voice'] == null
            ? null
            : AudioModel.fromJson(json['no_key_voice'] as Map<String, dynamic>),
        language: json['language'] as String?,
        allowRepeat: json['allow_repeat'] as int?,
        modifiedAt: json['modified_at'] == null
            ? null
            : DateTime.parse(json['modified_at'] as String),
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'] as String),
        user: json['user'] as int?,
        contactCount: json['contacts_count'] as int?,
        hosts: HostModel.fromMapList(json['hosts'] as List?),
      );

  static List<CampaignModel> fromMapList(List? json) {
    if (json == null) {
      return [];
    }
    return List<CampaignModel>.from(
      json.map((v) => CampaignModel.fromJson(v)),
    );
  }

  Map<String, dynamic> toJson() {
    final now = DateTime.now();
    final formattedNow = DateFormat("yyyy-MM-dd").format(now);
    return {
      'id': id,
      'name': name,
      'description': description,
      'call_cut_time': callCutTime?.toString(),
      "start_time": TimeOfDay.fromDateTime(
          DateFormat("yyyy-MM-dd HH:mm:ss").parse("$formattedNow $startTime")),
      "end_time": TimeOfDay.fromDateTime(
          DateFormat("yyyy-MM-dd HH:mm:ss").parse("$formattedNow $endTime")),
      'start_date': DateFormat("dd-MM-yyyy").format(startDate!),
      'end_date': DateFormat("dd-MM-yyyy").format(endDate!),
      'campaign_priority': campaignPriority?.toString(),
      'status': status,
      'wrong_key_voice': wrongKeyAudio?.toJson(),
      'no_key_voice': noKeyAudio?.toJson(),
      'language': language,
      'allow_repeat': allowRepeat,
      'modified_at': modifiedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'user': user,
      'contacts_count': contactCount,
      'hosts': hosts.map((e) => e.toJson()).toList(),
    };
  }
}
