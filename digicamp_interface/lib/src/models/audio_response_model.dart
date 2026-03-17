import 'package:flutter/material.dart';

class AudioResponseModel {
  int? currentPage;
  int? totalPages;
  List<AudioModel>? data;
  String? message;

  AudioResponseModel({
    this.currentPage,
    this.totalPages,
    this.data,
    this.message,
  });

  factory AudioResponseModel.fromJson(Map<String, dynamic> json) {
    return AudioResponseModel(
      currentPage: json['current_page'] as int?,
      totalPages: json['total_pages'] as int?,
      data: AudioModel.fromMapList(json['data']),
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

class AudioModel {
  int? id;
  String? voiceName;
  String? voiceDesc;
  String? path;
  ValueNotifier<int> status = ValueNotifier(1);
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);

  AudioModel({
    this.id,
    this.voiceName,
    this.voiceDesc,
    this.path,
  });

  factory AudioModel.fromJson(Map<String, dynamic> json) => AudioModel(
        id: json['id'] as int?,
        voiceName: json['voice_name'] as String?,
        voiceDesc: json['voice_desc'] as String?,
        path: json['path'] as String?,
      )..status = ValueNotifier(json['status'] ?? 1);

  static List<AudioModel> fromMapList(List? json) {
    if (json == null) {
      return [];
    }
    return List<AudioModel>.from(
      json.map((v) => AudioModel.fromJson(v)),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'voice_name': voiceName,
        'voice_desc': voiceDesc,
        'path': path,
        'status': status.value,
      };

  Map<String, String> toQueryParams() => {
        'id': id.toString(),
        'voice_name': voiceName ?? '',
        'voice_desc': voiceDesc ?? '',
        'path': path ?? '',
        'status': status.value.toString(),
      };
}
