import 'package:flutter/material.dart';
import 'package:digicamp_interface/src/models/models.dart';

class OperatorModel {
  int? id;
  String? description;
  String? operator;
  String? associatedNumber;
  int? userId;
  CampaignModel? campaignAssociated;
  ValueNotifier<int> status = ValueNotifier(0);
  String? managementId;

  OperatorModel({
    this.id,
    this.description,
    this.operator,
    this.associatedNumber,
    this.userId,
    this.campaignAssociated,
    this.managementId,
  });

  factory OperatorModel.fromJson(Map<String, dynamic> json) => OperatorModel(
        id: json['id'] as int?,
        description: json['description'] as String?,
        operator: json['operator'] as String?,
        associatedNumber: json['associated_number'] as String?,
        userId: json['user_id'] as int?,
        campaignAssociated: json['campaign_associated'] == null
            ? null
            : CampaignModel.fromJson(
                json['campaign_associated'] as Map<String, dynamic>),
        managementId: json['management_id'] as String?,
      )..status = ValueNotifier(json['status'] ?? 0);

  static List<OperatorModel> fromMapList(List? json) {
    if (json == null) {
      return [];
    }
    return List<OperatorModel>.from(
      json.map((v) => OperatorModel.fromJson(v)),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'operator': operator,
        'associated_number': associatedNumber,
        'user_id': userId,
        'campaign_associated': campaignAssociated?.toJson(),
        'status': status.value,
        'management_id': managementId,
      };
}
