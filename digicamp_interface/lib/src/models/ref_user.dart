class RefUserModel {
  int? id;
  String? name;
  String? mobileNumber;
  int? status;
  List<HostModel>? hosts;
  DateTime? createdAt;

  RefUserModel({
    this.id,
    this.name,
    this.mobileNumber,
    this.status,
    this.hosts,
    this.createdAt,
  });

  factory RefUserModel.fromJson(Map<String, dynamic> json) => RefUserModel(
        id: json['id'] as int?,
        name: json['name'] as String?,
        mobileNumber: json['mobile_number'] as String?,
        status: json['status'] as int?,
        hosts: HostModel.fromMapList(json['hosts'] as List?),
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'] as String),
      );

  static List<RefUserModel> fromMapList(List? json) {
    if (json == null) {
      return [];
    }
    return List<RefUserModel>.from(
      json.map((v) => RefUserModel.fromJson(v)),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mobile_number': mobileNumber,
        'status': status,
        'hosts': hosts?.map((e) => e.toJson()).toList(),
        'created_at': createdAt?.toIso8601String(),
      };
}

class HostModel {
  int? id;
  String? host;
  String? systemPassword;
  int? userId;
  int? priority;
  int? allowSms;
  int? status;

  HostModel({
    this.id,
    this.host,
    this.systemPassword,
    this.userId,
    this.priority,
    this.allowSms,
    this.status,
  });

  factory HostModel.fromJson(Map<String, dynamic> json) => HostModel(
        id: json['id'] as int?,
        host: json['host'] as String?,
        systemPassword: json['system_password'] as String?,
        userId: json['user_id'] as int?,
        priority: json['priority'] as int?,
        allowSms: json['allow_sms'] as int?,
        status: json['status'] as int?,
      );

  static List<HostModel> fromMapList(List? json) {
    if (json == null) {
      return [];
    }
    return List<HostModel>.from(
      json.map((v) => HostModel.fromJson(v)),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'host': host,
        'system_password': systemPassword,
        'user_id': userId,
        'priority': priority,
        'allow_sms': allowSms,
        'status': status,
      };
}
