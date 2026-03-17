class SmsCampaignModel {
  int? id;
  String? name;
  String? description;
  int? priority;
  String? startTime;
  String? endTime;
  int? templateId;
  String? category1;
  String? category2;
  String? category3;
  String? category4;
  String? category5;
  int? status;

  SmsCampaignModel({
    this.id,
    this.name,
    this.description,
    this.priority,
    this.startTime,
    this.endTime,
    this.templateId,
    this.category1,
    this.category2,
    this.category3,
    this.category4,
    this.category5,
    this.status,
  });

  factory SmsCampaignModel.fromJson(Map<String, dynamic> json) {
    return SmsCampaignModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      priority: json['priority'] as int?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      templateId: json['template_id'] as int?,
      category1: json['category1'] as String?,
      category2: json['category2'] as String?,
      category3: json['category3'] as String?,
      category4: json['category4'] as String?,
      category5: json['category5'] as String?,
      status: json['status'] as int?,
    );
  }

  static List<SmsCampaignModel> fromMapList(List? json) {
    if (json == null) {
      return [];
    }
    return List<SmsCampaignModel>.from(
      json.map((v) => SmsCampaignModel.fromJson(v)),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'priority': priority,
        'start_time': startTime,
        'end_time': endTime,
        'template_id': templateId,
        'category1': category1,
        'category2': category2,
        'category3': category3,
        'category4': category4,
        'category5': category5,
        'status': status,
      };
}
