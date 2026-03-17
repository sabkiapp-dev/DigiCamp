class MissCallResponseModel {
  int? currentPage;
  int? totalPages;
  List<MissCallModel>? data;
  String? message;

  MissCallResponseModel({
    this.currentPage,
    this.totalPages,
    this.data,
    this.message,
  });

  factory MissCallResponseModel.fromJson(Map<String, dynamic> json) {
    return MissCallResponseModel(
      currentPage: json['current_page'] as int?,
      totalPages: json['total_pages'] as int?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => MissCallModel.fromJson(e as Map<String, dynamic>))
          .toList(),
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

class MissCallModel {
  int? id;
  String? phoneNumber;
  DateTime? datetime;
  int? misscallManagement;
  int? campaign;
  String? operator;

  MissCallModel({
    this.id,
    this.phoneNumber,
    this.datetime,
    this.misscallManagement,
    this.campaign,
    this.operator,
  });

  factory MissCallModel.fromJson(Map<String, dynamic> json) => MissCallModel(
        id: json['id'] as int?,
        phoneNumber: json['phone_number'] as String?,
        datetime: json['datetime'] == null
            ? null
            : DateTime.parse(json['datetime'] as String),
        misscallManagement: json['misscall_management'] as int?,
        campaign: json['campaign'] as int?,
        operator: json['operator'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone_number': phoneNumber,
        'datetime': datetime?.toIso8601String(),
        'misscall_management': misscallManagement,
        'campaign': campaign,
        'operator': operator,
      };
}
